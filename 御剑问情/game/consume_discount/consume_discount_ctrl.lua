require("game/consume_discount/consume_discount_view")
require("game/consume_discount/consume_discount_data")

ConsumeDiscountCtrl = ConsumeDiscountCtrl or BaseClass(BaseController)

function ConsumeDiscountCtrl:__init()
	if ConsumeDiscountCtrl.Instance ~= nil then
		print_error("[ConsumeDiscountCtrl]error:create a singleton twice")
	end
	ConsumeDiscountCtrl.Instance = self

	self.view = ConsumeDiscountView.New(ViewName.ConsumeDiscountView)
	self.data = ConsumeDiscountData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenComplete, self))
end

function ConsumeDiscountCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
	end
	if nil ~= self.data then
		self.data:DeleteMe()
	end

	ConsumeDiscountCtrl.Instance = nil
end

function ConsumeDiscountCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAContinueConsumeInfo, "OnRAContinueConsumeInfo")
end

function ConsumeDiscountCtrl:MainuiOpenComplete()
	-- local param_t = {
	-- 	rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
	-- 	opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO,
	-- }
	-- KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
end

function ConsumeDiscountCtrl:OnRAContinueConsumeInfo(protocol)
	self.data:SetRAContinueConsumeInfo(protocol)
	self.view:Flush()

	RemindManager.Instance:Fire(RemindName.ConsumeDiscount)
end