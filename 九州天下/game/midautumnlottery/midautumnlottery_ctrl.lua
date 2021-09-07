require("game/midautumnlottery/midautumnlottery_data")
require("game/midautumnlottery/midautumnlottery_view")
require("game/midautumnlottery/midautumnlottery_rewardview")

MidAutumnLotteryCtrl = MidAutumnLotteryCtrl or BaseClass(BaseController)

function MidAutumnLotteryCtrl:__init()
	if MidAutumnLotteryCtrl.Instance then
		print_error("[MidAutumnLotteryCtrl] Attempt to create singleton twice")
	end
	MidAutumnLotteryCtrl.Instance = self

	self.lottery_view = MidAutumnLotteryView.New(ViewName.MidAutumnLottery)
	self.lottery_data = MidAutumnLotteryData.New()

	self:RegisterAllProtocols()
end

function MidAutumnLotteryCtrl:__delete()
	if self.lottery_view then
		self.lottery_view:DeleteMe()
		self.lottery_view = nil
	end

	if self.lottery_data then
		self.lottery_data:DeleteMe()
		self.lottery_data = nil
	end

	MidAutumnLotteryCtrl.Instance = nil
end

function MidAutumnLotteryCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAHappyDraw2RareRankInfo,"OnSCRAHappyDraw2RareRankInfo")
	self:RegisterProtocol(SCRAHappyDraw2Info,"OnSCRAHappyDraw2Info")
end

function MidAutumnLotteryCtrl:OnSCRAHappyDraw2RareRankInfo(protocol)
	self.lottery_data:SetRareItemList(protocol)    
	if self.lottery_view:IsOpen() then
		self.lottery_view:Flush()
	end 
end

function MidAutumnLotteryCtrl:OnSCRAHappyDraw2Info(protocol)
	self.lottery_data:SetOperaTypeInfo(protocol)
	if self.lottery_view:IsOpen() then
		self.lottery_view:Flush()
	end
end

function MidAutumnLotteryCtrl:DelayOpenRewardView(protocol)
	self.lottery_view:DelayOpenRewardView(protocol)
end

function MidAutumnLotteryCtrl:SetIsTenClick()
	self.lottery_view:SetIsTenClick()
end