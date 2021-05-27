require("scripts/game/charge_fashion/charge_fashion_data")
require("scripts/game/charge_fashion/charge_fashion_view")

ChargeFashionCtrl = ChargeFashionCtrl or BaseClass(BaseController)

function ChargeFashionCtrl:__init()
	if ChargeFashionCtrl.Instance then
		ErrorLog("[ChargeFashionCtrl] attempt to create singleton twice!")
		return
	end
	ChargeFashionCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function ChargeFashionCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	ChargeFashionCtrl.Instance = nil
end	

function ChargeFashionCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self:RegisterProtocol(SCChargeFashionInfo, "OnChargeFashionData")
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ChargeFashion)
end

function ChargeFashionCtrl:CreateRelatedObjs()
	self.data = ChargeFashionData.New()
	self.view = ChargeFashionView.New(ViewName.ChargeFashion)
end

function ChargeFashionCtrl:OnRecvMainRoleInfo()
	
end

function ChargeFashionCtrl:OnChargeFashionData(protocol)
	self.data:setChargeInfo(protocol.charge_num,protocol.oper_get)
	GlobalEventSystem:Fire(OtherEventType.RECHARGE_FASHION,protocol)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
	RemindManager.Instance:DoRemind(RemindName.ChargeFashion)
	self.view:Flush()
end

function ChargeFashionCtrl:ReqFashionReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChargeFashionData)
	protocol:EncodeAndSend()
end

function ChargeFashionCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ChargeFashion then
		return self.data:GetRechargeFashionNum() or 0
	end
end

