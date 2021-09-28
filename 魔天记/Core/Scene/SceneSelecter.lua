require "Core.Role.Controller.AbsController";
SceneSelecter = class("SceneSelecter")
SceneSelecter._instance = nil;
function SceneSelecter:GetInstance()
	return SceneSelecter._instance
end
local layerMask = 0 -- 响应点选层
local MAP_MAX_HEIGHT = 500 -- 射线长度
local MAX_ATTACK_DISTANCE = 10 -- 最大攻击距离
local insert = table.insert
local _sortfunc = table.sort

function SceneSelecter:New()
	layerMask = LayerMask.GetMask(Layer.Player, Layer.Monster, Layer.NPC)
	self = {};
	setmetatable(self, {__index = SceneSelecter});
	SceneSelecter._instance = self;
	self._timer = nil
	-- 检查点选计时器
	self._lastRole = nil
	-- 上次点选对象
	self._MapRoleList = nil
	-- 地图角色列表
	self._lastEnemy = nil
	-- 上次点选敌人
	self:_SetTimer()
	return self;
end

function SceneSelecter:ResetLastSelectRole()
	if self._lastRole then
		self._lastRole:SetSelect(false)
		self._lastRole = nil
	end
	self._lastEnemy = nil
end

function SceneSelecter:SetMapRoleList(MapRoleList)
	self._MapRoleList = MapRoleList
	-- logTrace("SceneSelecter:New:" .. tostring(self._MapRoleList).. tostring(MapRoleList))
end
function SceneSelecter:_SetTimer()
	if(self._timer == nil) then
		self._timer = CoTimer.New(function(val) self:Update(val) end, 0, - 1, false);
	end
	if(not self._timer.running) then
		self._timer:Start()
	end
end

-- 更新检测点击
function SceneSelecter:Update(val)
	--  log("SceneSelecter:Update,overUI=" .. tostring(UICamera.isOverUI) .. ",currentTouch=" .. tostring(UICamera.currentTouch))
	if UICamera.isOverUI then
		return
	end
	
	if GuideManager.isForceGuiding then
		return
	end
	
	if Input.GetKeyDown(KeyCode.Mouse0) then
		local p = Input.mousePosition
		-- if UICamera.Raycast(p) then return end
		self:Raycast(p)
		return
	end
	-- logTrace("SceneSelecter:Update,touchCount=" .. Input.touchCount)
	if Input.touchCount ~= 1 then return end
	local t = Input.GetTouch(0)
	if t.phase ~= TouchPhase.Began then return end
	local p = t.position;
	-- log("SceneSelecter:Update,touchPos=" .. tostring(p) .. ",RaycastUI=" .. tostring(UICamera.Raycast(p)))
	if UICamera.Raycast(p) then return end
	self:Raycast(p)
end
-- 发射线返回点击目标
function SceneSelecter:Raycast(pos)
	-- logTrace(tostring( MainCameraController.camera) .. "___" .. tostring(pos))
	if MainCameraController.camera == nil then MainCameraController.camera = Camera.main end
	if MainCameraController.camera == nil then return end
	local ray = MainCameraController.camera:ScreenPointToRay(pos)
	local raycastHits = Physics.RaycastAll(ray, MAP_MAX_HEIGHT, layerMask)
	local len = raycastHits.Length;
	-- logTrace("SceneSelecter:Raycast,len=" .. len )
	if len == 0 then return end
	local cs = {}
	for i = 0, len - 1, 1 do
		local trf = raycastHits[i].collider.transform.root
		local name = trf.name
		local id = string.split(name, "_") [2]
		local controller = self._MapRoleList:GetRole(id)
		if controller == nil then controller = self._MapRoleList:GetRole(tonumber(id)) end
		-- npc的id是数字类型
		-- logTrace("SceneSelecter:Raycast,i=" .. i .. ",h=" .. name .. ",id=" .. id .. ",controller=" .. type(controller))
		if controller ~= nil and not controller:IsDie() then insert(cs, controller) end
	end
	if #cs > 0 then self:Select(cs) end
end
-- 选择优先目标
local function _SortSelect(r, r2)
	-- npc,player,boss,big monster, puppet,monster
	local f = false
	local t = r.roleType
	local t2 = r2.roleType
	if t == ControllerType.NPC then
		f = true
	elseif t == ControllerType.PLAYER then
		if t2 == ControllerType.PLAYER then
			f = false
		else
			f = t2 ~= ControllerType.NPC
		end
	elseif t == ControllerType.MONSTER and t2 == ControllerType.MONSTER then
		f = r.info.type > r2.info.type
	elseif t == ControllerType.MONSTER then
		if t2 == ControllerType.NPC or t2 == ControllerType.PLAYER then
			f = false
		elseif t2 == ControllerType.PUPPET then
			f = r.info.type > MonsterInfoType.NORMAL
		end
	elseif t == ControllerType.PUPPET then
		if t2 == ControllerType.NPC or t2 == ControllerType.PLAYER then
			f = false
		elseif t2 == ControllerType.MONSTER then
			f = r2.info.type <= MonsterInfoType.NORMAL
		end
		-- ]]
	end
	-- log(r.info.name .. ":" .. r2.info.name .. ":" .. tostring(f))
	return f
end
function SceneSelecter:Select(ls)
	if #ls > 1 then _sortfunc(ls, _SortSelect) end
	self:Selected(ls[1])
end
-- 选择操作
function SceneSelecter:Selected(s)	
	--Warning(tostring(s) .. '----' .. tostring(self._lastRole))
	if self._lastRole then
		self._lastRole:SetSelect(false)
		self._lastRole = nil
	end
	--if s == self._lastRole then return end
	if not s then return end	
	if(s.__cname == "NpcController") then
		if(s.transform) then
			if(Vector3.Distance2(s.transform.position, HeroController:GetInstance().transform.position) <= 3) then
				ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, s.id)
			end
		end
	end	
    self._lastRole = s
	self:RefreshSelect(true)
end
function SceneSelecter:RefreshSelect(send)
    if not self._lastRole or not self._lastRole.info then return end
    local s = self._lastRole
    local relation = self:GetRelation(s)
	self._lastEnemy = relation == 1 and s or nil
	local st = self:GetRelationSources(relation)
	--Warning(s.transform.name .. "__" .. relation)
	if send then SequenceManager.TriggerEvent(SequenceEventType.Guide.GUIDE_CLICK_TARGET, s) end
	HeroController.GetInstance():SetTarget(s, st, true)
end

-- 返回与主角关系, 1 敌人, 2友人, 3中立
function SceneSelecter:GetRelation(r)
	local t = r.roleType
	if TabooProxy.InTaboo() and TabooProxy.CanAttack(r) then
		return 1
	end
	if t == ControllerType.MONSTER then
		return(not r:IsDie() and r.info.camp ~= 0) and 1 or 3
		-- 0任务怪
	elseif t == ControllerType.PLAYER then
		if r:IsDie() then return 3 end
		return SceneSelecter.PlayerIsEnemy(r) and 1 or 2
	elseif t == ControllerType.PUPPET then
		if r:IsDie() then return 3 end
		local rp = r:GetMaster() Warning(tostring(rp))
		if not rp then return 2 end
		return SceneSelecter.PlayerIsEnemy(rp) and 1 or 2
	elseif t == ControllerType.HERO or t == ControllerType.HEORPET
	or t == ControllerType.HEROPUPPET then
		return 2
	end
	return 3
end
-- 返回与主角关系对应的资源名字, 1 敌人, 2友人, 3中立
function SceneSelecter:GetRelationSources(relation)
	local st = "select"
	if relation ~= 1 then st =(relation == 2 and "select_02" or "select_03") end
	return st
end
-- 选择优先敌对目标
local function _SortEnemy(r, r2)
	-- player,boss,big monster, puppet,monster
	local f = false
	local t = r.roleType
	local t2 = r2.roleType
	if t ~= t2 then
		if t == ControllerType.PLAYER then
			f = true
		elseif t == ControllerType.MONSTER then
			f = t2 == ControllerType.PUPPET and r.info.type > MonsterInfoType.NORMAL
		elseif t == ControllerType.PUPPET then
			f = t2 == ControllerType.MONSTER and r2.info.type <= MonsterInfoType.NORMAL
		end
	elseif t == ControllerType.MONSTER then
		f = r.info.type > r2.info.type
	end
	return f
end
-- 改变主角敌人
function SceneSelecter:ChangeEnemy()
	local es = self:GetAllEnemy()
	local elen = #es
	local enemy = nil
	local hero = HeroController.GetInstance()
	-- Warning(tostring(self._lastEnemy) .."__" .. tostring(self._lastRole))
	-- if self._lastEnemy == nil and self._lastRole == nil then
	-- 	local minDis = MAX_ATTACK_DISTANCE;
	-- 	local hpos = hero.transform.position
	-- 	for i = 1, elen, 1 do
	-- 		local e = es[i]
	-- 		-- logTrace(e.transform.name)
	-- 		local epos = e.transform.position
	-- 		local dis = Vector3.Distance2(hpos, epos)
	-- 		if(dis < minDis) then
	-- 			enemy = e
	-- 			minDis = dis
	-- 		end
	-- 	end
	-- elseif elen > 0 then
	-- 	enemy = es[math.random(1, elen)]
	-- end
	local minDis = MAX_ATTACK_DISTANCE;
	local hpos = hero.transform.position
	for i = elen, 1, - 1 do
		local e = es[i]
		local epos = e.transform.position
		local dis = Vector3.Distance2(hpos, epos)
		--if (dis > minDis) or e == self._lastEnemy then
		if(dis > minDis) then
			table.remove(es, i)
		end
	end
	elen = #es
	if elen > 0 then
		table.sort(es, _SortEnemy)
		local ft = es[1].roleType
		local ftt = es[1].info.type
		local tlen = - 1
		for i = 2, elen do
			local e = es[i]
			--Warning(i ..'---'.. e.roleType .. '-'..tostring(e.info.type))
			if e.roleType ~= ft or(e.info.type ~= ftt) then
				tlen = i - 1
				break
			end
		end
		if tlen == - 1 then tlen = elen end
		--Warning(tlen ..'-______--'.. elen)
		if tlen == 1 then enemy = es[1]
		else
			while true do
				enemy = es[math.random(1, tlen)]
				if enemy ~= self._lastEnemy then break end
			end
		end
	end
	
	if enemy then
		self:Selected(enemy)
	else
		self:Selected(hero)
	end
end
-- 返回所有敌人
function SceneSelecter:GetAllEnemy()
	local roles = self._MapRoleList:GetAllRoles()
	local items = {};
	local index = 1
	for id, r in pairs(roles) do
		--if r and r.visible and self:GetRelation(r) == 1 then
		if r and self:GetRelation(r) == 1 then
			items[index] = r;
			index = index + 1;
		end
	end
	return items
end
-- 清理
function SceneSelecter:Clear()
	self._lastRole = nil
	self._MapRoleList = nil
	self._lastEnemy = nil
end

-- 销毁
function SceneSelecter:Dispose()
	self:Clear()
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
end

-- 判断目标是否敌对
function SceneSelecter.PlayerIsEnemy(target)
	local role = PlayerManager.hero;
	local pkType = role.info.pkType;
	-- Warning(tostring(role.info.tgn) .. " - " .. tostring(target.info.tgn))
	if(PartData.IsMyTeammate(target.id) or GuildDataManager.IsSameGuild(role.info.tgn, target.info.tgn) or target.info.level < 20) then
		-- 目标为队友，盟友
		return false;
	else
		-- Warning(pkType .. " -- " .. role.info.camp .. "#" ..target.info.camp .. " -- ".. target.info.pkType .. ":" ..  target.info.pkState);
		if(pkType == PlayerPKType.Peace) then
			if(target.info.camp ~= role.info.camp) then
				return true;
			end
		elseif(pkType == PlayerPKType.GoodEvil) then
			if(target.info.pkState ~= PlayerPKState.White) then
				return true;
			end
		elseif(pkType == PlayerPKType.Guild) then
			if(target.info.pkState ~= PlayerPKState.White or target.info.pkType > PlayerPKType.GoodEvil) then
				return true;
			end
		elseif(pkType == PlayerPKType.Killing) then
			return true;
		end
	end
	
	return false;
end
