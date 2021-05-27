require("scripts/game/charge/charge_first_data")
require("scripts/game/charge/charge_first_view")
require("scripts/game/charge/charge_first_data")
require("scripts/game/charge/charge_first_note")
ChargeFirstCtrl = ChargeFirstCtrl or BaseClass(BaseController)

function ChargeFirstCtrl:__init()
	if	ChargeFirstCtrl.Instance then
		ErrorLog("[ChargeFirstCtrl]:Attempt to create singleton twice!")
	end
	ChargeFirstCtrl.Instance = self

	self.data = ChargeFirstData.New()
	self.view = ChargeFirstView.New(ViewName.ChargeFirst)
	self.charge_first_note_view = ChargeFirstNoteView.New(ViewName.ChargeFirstNode)
	self:RegisterAllProtocols()
	self:RegisterAllRemind()
end

function ChargeFirstCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.charge_first_note_view:DeleteMe()
	self.charge_first_note_view = nil 
	
	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_callback)
	end

	ChargeFirstCtrl.Instance = nil
end

function ChargeFirstCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFirstChargeInformation, "OnFirstChargeInformation")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendChargeInfo))
end

function ChargeFirstCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ChargeFirst)

	self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_attr_change_callback)
end

function ChargeFirstCtrl:SendChargeInfo()
	ChargeFirstCtrl.SendFirstChargeGiftBagInformationReq(0)
end

function ChargeFirstCtrl:OpenChargeFirstNote()
	if ViewManager.Instance:CanShowUi(ViewName.ChargeFirst, index) then
		if self.charge_first_note_view then
			self.charge_first_note_view:Open()
		end
	end
end

function ChargeFirstCtrl:SetMainUiIconPosChargeFirst(pos_x, pos_y)
	if self.charge_first_note_view:IsOpen() then
		self.charge_first_note_view:SetPos(pos_x, pos_y)
	end
end
--------------------------------------
-- 首充
--------------------------------------
-- 请求首充礼包信息
function ChargeFirstCtrl.SendFirstChargeGiftBagInformationReq(info)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFirstChargeGiftBagInformationReq)
	protocol.require_info = info
	protocol:EncodeAndSend()
end

function ChargeFirstCtrl:OnFirstChargeInformation(protocol)
	self.data:SetFirstChargeInformation(protocol)
	self.view:Flush()

	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
	RemindManager.Instance:DoRemind(RemindName.ChargeFirst)
end

function ChargeFirstCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		ChargeFirstCtrl.SendFirstChargeGiftBagInformationReq(0)
	end
end

function ChargeFirstCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ChargeFirst then
		return self.data:GetFirstChargeRemindNum() or 0
	end
end
