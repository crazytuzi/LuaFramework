require("game/price_lottery/price_lottery_data")
require("game/price_lottery/price_lottery_view")

TallPriceLotteryCtrl = TallPriceLotteryCtrl or BaseClass(BaseController)

function TallPriceLotteryCtrl:__init()
	if TallPriceLotteryCtrl.Instance ~= nil then
		print_error("[TallPriceLotteryCtrl] attempt to create singleton twice!")
		return
	end	
	TallPriceLotteryCtrl.Instance = self
	self.data = TallPriceLotteryData.New()
	self.view = TallPriceLotteryView.New(ViewName.PriceLottery)
	self:RegisterAllProtocols()	
end

function TallPriceLotteryCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALotteryInfo, "SyncLotteryInfo")
	self:RegisterProtocol(SCRALotteryRank, "SyncLotteryRank")	
end

function TallPriceLotteryCtrl:SyncLotteryInfo(protocol)
	self.data:GetLotteryInfo(protocol)
	if self.view then
		self.view:Flush()
	end
end

function TallPriceLotteryCtrl:SendLotteryInfo(operate_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	send_protocol.rand_activity_type = 2197
	send_protocol.opera_type = operate_type or 0
	send_protocol.param_1 = param1 or 0
	send_protocol.param_2 = param2 or 0
	send_protocol:EncodeAndSend()	
end

function TallPriceLotteryCtrl:SyncLotteryRank(protocol)
	self.data:GetLotteryRank(protocol)	
	TipsCtrl.Instance:FlushCommonInputView()
end