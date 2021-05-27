
local GameCondHandle = {}
GameCondHandle[GameCondType.RoleLevel] = {func = function(param)
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= param then
		return true
	else
		return false
	end
end}
GameCondHandle[GameCondType.RoleCircle] = {func = function(param)
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) >= param then
		return true
	else
		return false
	end
end}
GameCondHandle[GameCondType.HaveGuild] = {func = function(param)
	local have_guild = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) > 0
	if param then
		return have_guild
	else
		return not have_guild
	end
end}
GameCondHandle[GameCondType.RoleLevelRange] = {func = function(param)
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if role_level >= param[1] and role_level <= param[2] then
		return true
	else
		return false
	end
end}
GameCondHandle[GameCondType.IsOnCrossserver] = {func = function(param)
	if IS_ON_CROSSSERVER then
		return param
	else
		return true
	end
end}
GameCondHandle[GameCondType.IsActBrilliantOpen] = {func = function(view_index)
	local is_show = ActivityBrilliantData.Instance:IsMainuiActivityIconShow(view_index)
	return is_show
end}
-- GameCondHandle[GameCondType.IsYuanBaoZPOpen] = {func = function(param)
-- 	local is_show = ActivityBrilliantData.Instance:IsMainuiTurntableIconShow()
-- 	if is_show == param then
-- 		return false
-- 	else
-- 		return true
-- 	end
-- end}
GameCondHandle[GameCondType.IsActCanbaogeOpen] = {func = function(param)
	local is_show = ActivityBrilliantData.Instance:IsActCanbaogeOpen()
	if param then
		return is_show
	else
		return false
	end
end}
GameCondHandle[GameCondType.IsActBabelTowerOpen] = {func = function(param)
	local is_show = ActivityBrilliantData.Instance:IsActBabelTowerOpen()
	if param then
		return is_show
	else
		return false
	end
end}
GameCondHandle[GameCondType.IsLimitChargeOpen] = {func = function(param)
	local is_show = ActivityBrilliantData.Instance:IsMainuiActIconShowByActId(ACT_ID.XSCZ)

	if is_show == param then
		return false
	else
		local bool = false
		local charge_list = ActivityBrilliantData.Instance:GetLimitChargeList()
		for i,v in ipairs(charge_list) do
			if v.sign == 0 then
				bool = true
				break
			end
		end

		return bool
	end
end}
GameCondHandle[GameCondType.IsChargeFLOpen] = {func = function(param)
	local is_show = ActivityBrilliantData.Instance:IsMainuiActIconShowByActId(ACT_ID.CZFL)
	if is_show == param then
		return false
	else
		return true
	end
end}
GameCondHandle[GameCondType.IsHunHuanOpen] = {func = function(param)
	local is_show = HunHuanData.GetIsOpen()
	if is_show == param then
		return false
	else
		return true
	end
end}

GameCondHandle[GameCondType.IsChargeGiftOpen] = {func = function(param)
	local is_show = ChargeGiftData.GetIconOpen()
	if is_show == param then
		return false
	else
		return true
	end
end}

GameCondHandle[GameCondType.IsWelfreTurnbelOpen] = {func = function(param)
	local is_show = WelfareTurnbelData.Instance:IsShow()
	if is_show == param then
		return false
	else
		return true
	end
end}

GameCondHandle[GameCondType.IsZsTaskAllGet] = {func = function(param)
	local is_show = ZsTaskData.Instance:CheckIsZsTaskAllGet()
	if is_show == param then
		return false
	else
		return true
	end
end}
-- 游戏条件管理器
GameCondMgr = GameCondMgr or BaseClass()
function GameCondMgr:__init()
	if nil ~= GameCondMgr.Instance then
		ErrorLog("[GameCondMgr]:Attempt to create singleton twice!")
	end
	GameCondMgr.Instance = self

	self.check_cache_list = {}
	self.delay_check_list = {}

	--[[
		{
			cond_type = {cond0, cond1, cond2},
			cond_type2 = {cond0, cond1, cond2},
			cond_type3 = {cond0, cond1, cond2, ...},
			...
		}
	--]]
	self.cond_type_key_t = {}
	for id, cond in pairs(GameCond) do
		for k, cond_type in pairs(GameCondType) do
			if nil ~= cond[cond_type] then
				if nil == self.cond_type_key_t[cond_type] then
					self.cond_type_key_t[cond_type] = {}
				end
				self.cond_type_key_t[cond_type][id] = cond
			end
		end
	end

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function GameCondMgr:__delete()
	self.check_cache_list = {}
	self.delay_check_list = {}
	self.cond_type_key_t = {}
end

function GameCondMgr:OnRecvMainRoleInfo()
	Runner.Instance:AddRunObj(self, 16)

	self:CheckCondType(GameCondType.RoleLevel)
	self:CheckCondType(GameCondType.RoleLevelRange)
	self:CheckCondType(GameCondType.RoleCircle)
	self:CheckCondType(GameCondType.InnerLevel)
	self:CheckCondType(GameCondType.HaveGuild)

	RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
end

function GameCondMgr:OnRoleDataChange(vo)
	local key = vo.key
	if OBJ_ATTR.CREATURE_LEVEL == key then
		self:CheckCondType(GameCondType.RoleLevel)
		self:CheckCondType(GameCondType.RoleLevelRange)
	elseif OBJ_ATTR.ACTOR_CIRCLE == key then
		self:CheckCondType(GameCondType.RoleCircle)
	elseif OBJ_ATTR.ACTOR_INNER_LEVEL == key then
		self:CheckCondType(GameCondType.InnerLevel)
	elseif OBJ_ATTR.ACTOR_GUILD_ID == key then
		self:CheckCondType(GameCondType.HaveGuild)
	end
end

-- 注册条件检查的函数
function GameCondMgr:ResgisterCheckFunc(id, func)
	if nil == id then
		ErrorLog("remind check event id need a value, not nil")
	end
	if GameCondHandle[id] == nil then
		GameCondHandle[id] = {}
	end
	GameCondHandle[id].func = func
end

-- 获取条件的说明
function GameCondMgr:GetTip(id)
	return GameCond[id] and GameCond[id].Tip
end

-- 条件值
function GameCondMgr:GetValue(id)
	if nil == self.check_cache_list[id] then
		self:Check(id)
	end
	return self.check_cache_list[id] or false
end

-- 检查条件是否成立
function GameCondMgr:Check(id)
	if nil == GameCond[id] then
		return
	end
	
	local is_all_ok = true
	local cond = GameCond[id]

	-- 忽略检查，强制使用给定的值
	if nil ~= cond["ForceValue"] then
		self.check_cache_list[id] = cond.ForceValue
		return
	end

	-- 检查所有判断 &&
	for cond_type, param in pairs(cond) do
		local handle = GameCondHandle[cond_type]
		if handle and handle.func then
			is_all_ok = is_all_ok and handle.func(param)
			if not is_all_ok then
				break
			end
		end
	end
	local old_val = self.check_cache_list[id]
	if old_val ~= is_all_ok then
		self.check_cache_list[id] = is_all_ok
		GlobalEventSystem:FireNextFrame(OtherEventType.GAME_COND_CHANGE, id, is_all_ok)
	end
end

-- 延时检查
function GameCondMgr:DelayCheck(id, time)
	if nil ~= self.delay_check_list[id] then
		return
	end
	self.delay_check_list[id] = time or (0.1 + math.random() * 0.6)
end

-- 以条件类型检查所有相关的条件是否成立
function GameCondMgr:CheckCondType(cond_type)
	for id, cond in pairs(self.cond_type_key_t[cond_type] or {}) do
		self:DelayCheck(id)
	end
end

function GameCondMgr:Update(now_time, elapse_time)
	-- 更新延时检查
	for id, time in pairs(self.delay_check_list) do
		if time <= 0 then
			self.delay_check_list[id] = nil
			self:Check(id)
		else
			self.delay_check_list[id] = time - elapse_time
		end
	end
end
