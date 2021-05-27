
require("scripts/game/compose/compose_data")
require("scripts/game/compose/compose_items")
require("scripts/game/compose/compose_view")
require("scripts/game/compose/compose_look_view")

------------------------------------------------------------
-- 神炉Ctrl
------------------------------------------------------------
ComposeCtrl = ComposeCtrl or BaseClass(BaseController)

function ComposeCtrl:__init()
	if ComposeCtrl.Instance then
		ErrorLog("[ComposeCtrl]:Attempt to create singleton twice!")
	end
	ComposeCtrl.Instance = self

	self.data = ComposeData.New()
	self.view = ComposeView.New(ViewName.Compose)

	self.broswerView = ComposeLookView.New(ViewName.ComposeBroswer)

	self:RegisterAllProtocls()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.XFUpLv, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.ShieldUpGrade, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.DiamondUpLv, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.SoulBeadUpLv, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.MBRingUpLv, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.FTRingUpLv, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindSign, self), RemindName.FHRingUpLv, true, 1)

	self.role_data_change_back = BindTool.Bind1(self.RoleDataChangeCallback,self)	
	RoleData.Instance:NotifyAttrChange(BindTool.Bind1(self.role_data_change_back, self))

	self.item_data_change_back = BindTool.Bind1(self.ItemDataChangeCallback,self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_back)

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
end

function ComposeCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	if self.role_data_change_back then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change_back)
		self.role_data_change_back = nil 
	end

	if self.item_data_change_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_back)
		self.item_data_change_back = nil 
	end
	
	ComposeCtrl.Instance = nil
end

function ComposeCtrl:RegisterAllProtocls()
	self:RegisterProtocol(SCGodArmInfoIss, "OnGodArmInfoIss")
	self:RegisterProtocol(SCGodArmLightIss, "OnGodArmLightIss")
	self:RegisterProtocol(SCGodArmActiveIss, "OnGodArmActiveIss")
end

function ComposeCtrl:OnGodArmInfoIss(protocol)
	-- print("所有神兵信息")
	-- PrintTable(protocol)
	self.data:SetGodArmData(protocol)
	GlobalEventSystem:Fire(ComposeEvent.GOD_ARM_DATA_CHANGE)
end

function ComposeCtrl:OnGodArmLightIss(protocol)
	self.data:UpdateOneGodArmLightNum(protocol)
	GlobalEventSystem:Fire(ComposeEvent.GOD_ARM_DATA_CHANGE)
end

function ComposeCtrl:OnGodArmActiveIss(protocol)
	self.data:UpdateOneGodArmActive(protocol)
	GlobalEventSystem:Fire(ComposeEvent.GOD_ARM_DATA_CHANGE)
end

function ComposeCtrl:GetRemindSign(remind_name)
	if remind_name == RemindName.XFUpLv then
		return self.data:GetXFUpLvData()
	elseif remind_name == RemindName.ShieldUpGrade then
		return self.data:GetShieldUpGradeData()
	elseif remind_name == RemindName.DiamondUpLv then
		return self.data:GetDiamondUpLvData()
	elseif remind_name == RemindName.SoulBeadUpLv then
		return self.data:GetSoulBeadUpLvData()
	elseif remind_name == RemindName.MBRingUpLv then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if prof == 1 then
			return self.data:GetMbRingUpLv()
		else
			return 0
		end
	elseif remind_name == RemindName.FTRingUpLv then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if prof == 2 or prof == 3 then
			return self.data:GetFTRingUpLv()
		else
			return 0
		end
	elseif remind_name == RemindName.FHRingUpLv then
		return self.data:GetFHRingUpLv()
	end
end

function ComposeCtrl:OnRecvMainRoleInfo()
	self.data:InitComposeGodArmData()
	ComposeCtrl.AllGodArmInfoReq()
end

--激活请求
function ComposeCtrl:SendActiveReq(equipType)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipmentShenLuReq)
	protocol.type = 1 
	protocol.equipId = equipType 
	protocol:EncodeAndSend()
end

--升级请求
function ComposeCtrl:SendUpLevelReq(equipType)

	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipmentShenLuReq)
	protocol.type = 2 
	protocol.equipId = equipType 
	protocol:EncodeAndSend()
end

-- 请求所有神兵信息
function ComposeCtrl.AllGodArmInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGodArmInfo)
	protocol:EncodeAndSend()
end

-- 点亮一件神兵请求
function ComposeCtrl.LightOneGodArmReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGodArmLight)
	protocol.index = index
	protocol:EncodeAndSend()
end

-- 激活一件神兵请求
function ComposeCtrl.ActiveOneGodArmReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGodArmActive)
	protocol.index = index
	protocol:EncodeAndSend()
end

function ComposeCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemind(RemindName.XFUpLv)
		RemindManager.Instance:DoRemind(RemindName.ShieldUpGrade)
		RemindManager.Instance:DoRemind(RemindName.DiamondUpLv)
		RemindManager.Instance:DoRemind(RemindName.SoulBeadUpLv)
		self:DoRingRemind()
	elseif key == OBJ_ATTR.ACTOR_MAGIC_SOUL then
		RemindManager.Instance:DoRemind(RemindName.XFUpLv)
	elseif key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT then
		RemindManager.Instance:DoRemind(RemindName.ShieldUpGrade)
	elseif key == OBJ_ATTR.ACTOR_GEM_CRYSTAL then
		RemindManager.Instance:DoRemind(RemindName.DiamondUpLv)
	elseif key == OBJ_ATTR.ACTOR_PEARL_CHIP then
		RemindManager.Instance:DoRemind(RemindName.SoulBeadUpLv)
	elseif key == OBJ_ATTR.ACTOR_RING_CRYSTAL  then
		self:DoRingRemind()
	end
end

function ComposeCtrl:ItemDataChangeCallback()
	self:DoRingRemind()
end


function ComposeCtrl:DoRingRemind()
	RemindManager.Instance:DoRemind(RemindName.FHRingUpLv)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if prof == 2 or prof == 3 then
		RemindManager.Instance:DoRemind(RemindName.FTRingUpLv)
	else
		RemindManager.Instance:DoRemind(RemindName.MBRingUpLv)
	end
end