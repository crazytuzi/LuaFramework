require("scripts/game/openserviceacitivity/openserver_race_standard_data")
require("scripts/game/openserviceacitivity/openserver_race_standard_view")
-- 开服活动达标比拼
OpenSerRaceStandardCtrl = OpenSerRaceStandardCtrl or BaseClass(BaseController)

function OpenSerRaceStandardCtrl:__init()
	if	OpenSerRaceStandardCtrl.Instance then
		ErrorLog("[OpenSerRaceStandardCtrl]:Attempt to create singleton twice!")
	end
	OpenSerRaceStandardCtrl.Instance = self

	self.data = OpenSerRaceStandardData.New()
	self.view = OpenSerRaceStandardView.New(ViewName.OpenSerRaceStandard)

	self:RegisterAllProtocols()
	self:RegisterAllRemind()
	self.is_first_login = true
	self.tick = 0
end

function OpenSerRaceStandardCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil
	if RoleData.Instance and self.role_attr_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_callback)
	end

	if ItemData.Instance and self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
	end

	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil
	end	

	if self.strengthen_evt then
		GlobalEventSystem:UnBind(self.strengthen_evt)
		self.strengthen_evt = nil
	end
	if self.diamond_evt then
		GlobalEventSystem:UnBind(self.diamond_evt)
		self.diamond_evt = nil
	end
	OpenSerRaceStandardCtrl.Instance = nil
end

function OpenSerRaceStandardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpenServerRaceStandardAwardInfo, "OnOpenServerRaceStandardAwardInfo")
	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetOpenServerMsg, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.GetOpenServerMsg, self))
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	-- self.strengthen_evt = GlobalEventSystem:Bind(OtherEventType.EQUIP_STRENGTHEN_SUCC, BindTool.Bind(self.OnEqupStrengthenSucc, self))
	self.diamond_evt = GlobalEventSystem:Bind(SoulStoneEventType.GET_MY_SOUL_STONE_INFO, BindTool.Bind(self.OnDiamondChange, self))
end

function OpenSerRaceStandardCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenSerTenDayRace)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceBoss,true)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceLevel)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceWing)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceGem)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceSaintball)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceCharge)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceSuperGPur)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OpenServiceDailyCharge)
	
	self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_attr_change_callback)
	-- self.item_data_change_callback = BindTool.Bind(self.ItemDataChangeCallback, self)
	-- ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
end

function OpenSerRaceStandardCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.OpenSerTenDayRace then
		return self.data:GetRemindNum()
	end
end

function OpenSerRaceStandardCtrl:RoleDataChangeCallback(key, value, old_vlaue)
	if key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Level)
	elseif key == OBJ_ATTR.ACTOR_SWING_ID then 
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Wing)
	elseif key == OBJ_ATTR.HERO_FUWEN_LEVEL then 
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.FuWen)
	elseif key == OBJ_ATTR.ACTOR_MERIDIAND_LEVEL then 
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Meridian)
	elseif key == OBJ_ATTR.ACTOR_VIP_GRADE then 
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Vip)
	elseif key == OBJ_ATTR.ACTOR_INJECT_POWER then
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Strong)
	end
end

--监听装备变化
function OpenSerRaceStandardCtrl:EquipmentDataChangeCallback(bool, change_item_id, change_item_index, change_reason)
	if EquipData.IsComposeEquipByEqIndex(change_item_index) then
		local act_type = OpenSerRaceStandardData.ComposeEqToActType[change_item_index]
		if act_type then
			OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(act_type)
		end
	end
end

function OpenSerRaceStandardCtrl:OnDiamondChange()
	OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Diamond)
end

-- function OpenSerRaceStandardCtrl:OnEqupStrengthenSucc()
-- 	OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(OPEN_SER_RACE_STANDARD_TYPE.Strong)
-- end

function OpenSerRaceStandardCtrl:OnOpenServerRaceStandardAwardInfo(protocol)
	self.data:SetActAwardData(protocol)
	RemindManager.Instance:DoRemind(RemindName.OpenSerTenDayRace)
	self.tick = self.tick + 1
	if self.tick == 1 then
		self.view:Flush(0, "all")
		GlobalEventSystem:Fire(OpenServerActivityEventType.OPENSERVER_RACE_STAND_ACT_OPEN_UPDATE)
		-- if self.tick == 10 then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
		-- end
	end
end

function OpenSerRaceStandardCtrl:GetOpenServerMsg()
	self.data:InitOpenSerRaceStandardData()
	self.tick = 0
	for k, v in pairs(OPEN_SER_RACE_STANDARD_TYPE) do
		OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(v)
	end
end

function OpenSerRaceStandardCtrl:PassDayHandler()
	if self.is_first_login then
		self.is_first_login = false
		return
	end
	self:GetOpenServerMsg()
end

-- 请求获得开服竞技活动奖励信息(返回 139 134)
function OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(act_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenSerRaceStandardReq)
	protocol.act_type = act_type
	protocol:EncodeAndSend()
end

-- 请求领取开服活动奖励(返回 139 134)
function OpenSerRaceStandardCtrl.OpenSerRaceStandardAwardReq(act_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenSerRaceStandardAwardReq)
	protocol.act_type = act_type
	protocol.index = index
	protocol:EncodeAndSend()
end

function OpenSerRaceStandardCtrl.OpenLinkWnd(view_type)
	local link_cfg = RichTextUtil.GetOpenLinkCfg(view_type)
	if nil ~= link_cfg then
		ViewManager.Instance:Open(link_cfg.view_name, link_cfg.view_index)
	end
end