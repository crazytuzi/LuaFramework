require("scripts/game/title/title_data")
require("scripts/game/title/title_tip_wear")
--------------------------------------------------------------
--角色称号
--------------------------------------------------------------
TitleCtrl = TitleCtrl or BaseClass(BaseController)
function TitleCtrl:__init()
	if TitleCtrl.Instance then
		ErrorLog("[TitleCtrl] Attemp to create a singleton twice !")
	end
	TitleCtrl.Instance = self

	self.data = TitleData.New()
	self:RegisterAllProtocols()
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self.role_data_listener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self.get_main_role_info_time = 0

	self.n_title_act_t = {} --记录当前称号激活序列

	self.title_tip_wear = TitleTipWear.New(ViewDef.WearTitleTip)

end

function TitleCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	if self.title_tip_wear then
		self.title_tip_wear:DeleteMe()
		self.title_tip_wear = nil
	end

	if self.role_data_listener_h and RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.role_data_listener_h)
	end
	
	TitleCtrl.Instance = nil
end

function TitleCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCTitle, "OnTitle")
	self:RegisterProtocol(SCAchieveAddTitle, "OnAchieveAddTitle")
	self:RegisterProtocol(SCAchieveLoseTitle, "OnAchieveLoseTitle")
	self:RegisterProtocol(SCTimeLimitTitleInfo, "OnTimeLimitTitleInfo")
	self:RegisterProtocol(SC_139_227, "OnTitleLevelData")
end

function TitleCtrl:OnRecvMainRoleInfo()
	self.get_main_role_info_time =Status.NowTime
	local act_flag_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURTITLE))
	local act_flag_ex_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HEAD_TITLE))
	local n_title_act_t = {}

	-- 1 - 32
	for i = 1, 32 do
		n_title_act_t[33 - i] = act_flag_t[i]
	end
	-- 33 - 64
	for i = 1, 32 do
		n_title_act_t[32 + 33 - i] = act_flag_ex_t[i]
	end
	self.data:SetTitleActList(n_title_act_t)
end

-- 角色属性改变回调
function TitleCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_CURTITLE or vo.key == OBJ_ATTR.ACTOR_HEAD_TITLE then
		local title_act_t = self.data:GetTitleActList()
		local act_flag_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURTITLE))
		local act_flag_ex_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HEAD_TITLE))
		local n_title_act_t = {}
		-- 1 - 32
		for i = 1, 32 do
			n_title_act_t[33 - i] = act_flag_t[i]
		end
		-- 33 - 64
		for i = 1, 32 do
			n_title_act_t[32 + 33 - i] = act_flag_ex_t[i]
		end

		local index = 0
		for i = 1, #n_title_act_t do
			if self.n_title_act_t[i] == 0 and n_title_act_t[i] == 1 then --获取已激活的称号Index
				index = i 
				break
			end
		end
		if index > 0 and index ~= 8 then
			if not SettingData.Instance:GetOneSysSetting(SETTING_TYPE.WEAR_TITLE_TIP) then
				ViewManager.Instance:OpenViewByDef(ViewDef.WearTitleTip)
				ViewManager.Instance:FlushViewByDef(ViewDef.WearTitleTip, 0, "title_change", {titleId = index})
			end
		end
		self.n_title_act_t = n_title_act_t
		self.data:SetTitleActList(n_title_act_t)

		if Status.NowTime < self.get_main_role_info_time + 3 then
			return 
		end

		-- 夺宝奇兵-持宝人称号特殊处理
		local title_id = StdActivityCfg[DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING].titleId
		if n_title_act_t[title_id] == 1 and (title_act_t[title_id] == nil or title_act_t[title_id] == 0) and TITLE_CLIENT_CONFIG[title_id] then
			local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
			local title_1 = bit:_and(head_title, 0x000000ff)
			local title_2 = 0
			if title_1 == 0 then
				title_1 = title_id
				title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
			else
				title_2 = title_id
			end
			-- 获得持宝人称号时,请求配带持宝人称号
			self.SendTitleReq(title_1, title_2)	
		end
	elseif vo.key == OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE then
		self.data:SortTitle()

	end
end

-- 激活一个称号
function TitleCtrl:OnAchieveAddTitle(protocol)
	self.data:SetTitleOverTime(protocol.title_id, protocol.over_time)
end

-- 称号过期
function TitleCtrl:OnAchieveLoseTitle(protocol)
	self.data:SetTitleOverTime(protocol.title_id, -1)
end

-- 限时称号时间
function TitleCtrl:OnTimeLimitTitleInfo(protocol)
	self.data:SetTitleOverTime(protocol.title_id, protocol.over_time)
end

-- 接收称号等级数据
function TitleCtrl:OnTitleLevelData(protocol)
	self.data:SetTitleLevelData(protocol)
end

-- 选择称号
function TitleCtrl.SendTitleReq(title1, title2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTitleReq)
	protocol.title1 = title1 or 0
	protocol.title2 = title2 or 0
	protocol:EncodeAndSend()
end

-- 请求升级称号等级
function TitleCtrl.SendUpgradeTitleReq(title_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CS_139_222)
	protocol.title_id = title_id or 0
	protocol:EncodeAndSend()
end