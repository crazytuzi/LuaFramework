require("scripts/game/charge/charge_everyday_data")
require("scripts/game/charge/charge_everyday_view")
ChargeEveryDayCtrl = ChargeEveryDayCtrl or BaseClass(BaseController)

function ChargeEveryDayCtrl:__init()
	if	ChargeEveryDayCtrl.Instance then
		ErrorLog("[ChargeEveryDayCtrl]:Attempt to create singleton twice!")
	end
	ChargeEveryDayCtrl.Instance = self

	self.data = ChargeEveryDayData.New()
    self.everyday_view = ChargeEveryDayView.New(ViewName.ChargeEveryDay) 
    self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_attr_change_callback)
	self:RegisterAllProtocols()
end

function ChargeEveryDayCtrl:__delete()
	self.everyday_view:DeleteMe()
	self.everyday_view = nil

	self.data:DeleteMe()
	self.data = nil

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_callback)
	end
	ChargeEveryDayCtrl.Instance = nil
end

function ChargeEveryDayCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetEveryDaysGiftIdentification, "OnGetEveryDaysGiftIdentification")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendInfoReq))
end

function ChargeEveryDayCtrl:OnGetEveryDaysGiftIdentification(protocol)
	self.data:SetChargeEveryDay(protocol)
	self.everyday_view:Flush()
end

function ChargeEveryDayCtrl:CloseAct()
	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
end

--------------------------------------
-- 每日充值
--------------------------------------
function ChargeEveryDayCtrl:SendInfoReq()
	ChargeEveryDayCtrl.Instance:SendGetEveryDayGiftBagTagReq()
end

-- 请求获取领取礼包标示
function ChargeEveryDayCtrl:SendGetEveryDayGiftBagTagReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetEveryDayGiftInfoReq)
	protocol:EncodeAndSend()
end

-- 请求领取每日充值大礼包
function ChargeEveryDayCtrl:SendGetEveryDayGiftBagReq(gift_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetEveryDayGiftBagReq)
	protocol.gift_id = gift_id
	protocol:EncodeAndSend()
end

function ChargeEveryDayCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		 ChargeEveryDayCtrl.Instance:SendGetEveryDayGiftBagTagReq()
	end
end

