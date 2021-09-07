require("game/single_recharge/single_recharge_view")
require("game/single_recharge/single_recharge_data")

SingleRechargeCtrl = SingleRechargeCtrl or BaseClass(BaseController)
function SingleRechargeCtrl:__init()
	if SingleRechargeCtrl.Instance then
		print_error("[SingleRechargeCtrl] Attemp to create a singleton twice !")
	end
	SingleRechargeCtrl.Instance = self

	self.single_recharge_data = SingleRechargeData.New()
	self.singlerecharge_view = SingleRechargeView.New(ViewName.SingleRechargeView)

	self:RegisterAllProtocols()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SingleRecharge)
end

function SingleRechargeCtrl:__delete()
	SingleRechargeCtrl.Instance = nil

	if self.singlerecharge_view then
		self.singlerecharge_view:DeleteMe()
		self.singlerecharge_view = nil
	end

	if self.single_recharge_data then
		self.single_recharge_data:DeleteMe()
		self.single_recharge_data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function SingleRechargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRASingleChongZhiInfo, "OnSCRASingleChongZhiInfo")
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 主界面创建
function SingleRechargeCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI)
	if is_open then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_INFO)
	end
end

function SingleRechargeCtrl:OnSCRASingleChongZhiInfo(protocol)
	self.single_recharge_data:SetRewardFlag(protocol)
	RemindManager.Instance:Fire(RemindName.SingleRecharge)
	self.singlerecharge_view:Flush()
end

function SingleRechargeCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.SingleRecharge then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHONGZHI, num > 0)
	end
end