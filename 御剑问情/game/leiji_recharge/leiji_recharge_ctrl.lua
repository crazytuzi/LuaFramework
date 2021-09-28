-- require ("game/leiji_recharge/leiji_recharge_data")
require ("game/leiji_recharge/leiji_recharge_view")

LeiJiRechargeCtrl = LeiJiRechargeCtrl or BaseClass(BaseController)

function LeiJiRechargeCtrl:__init()
	if 	LeiJiRechargeCtrl.Instance ~= nil then
		print("[LeiJiRechargeCtrl] attempt to create singleton twice!")
		return
	end
	LeiJiRechargeCtrl.Instance = self
	self.view = LeiJiRechargeView.New(ViewName.LeiJiRechargeView)
	-- self.data = LeiJiRechargeData.New()
	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function LeiJiRechargeCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	LeiJiRechargeCtrl.Instance = nil
end

function LeiJiRechargeCtrl:RegisterAllProtocols()

end

function LeiJiRechargeCtrl:MainuiOpen()
	-- if GameVoManager.Instance:GetMainRoleVo().level > 1 then
		self.view:Open()
	-- end
end

function LeiJiRechargeCtrl:LeiJiRechargeFlushNext()
	if self.view:IsOpen() then
		self.view:FlusNextCanGet()
	end
end

function LeiJiRechargeCtrl:MainuiOpenCreate()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, 0)
	end
end
