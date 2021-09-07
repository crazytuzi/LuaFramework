require("game/logingift7/login_gift7_view")
require("game/logingift7/login_gift7_data")

SevenLoginGiftCtrl = SevenLoginGiftCtrl or BaseClass(BaseController)

function SevenLoginGiftCtrl:__init()
	if nil ~= SevenLoginGiftCtrl.Instance then
		print_error("[SevenLoginGiftCtrl] Attemp to create a singleton twice !")
		return
	end
	SevenLoginGiftCtrl.Instance = self

	self.login_gift7_view = SevenLoginGiftView.New(ViewName.SevenLoginGiftView)
	self.login_gift7_data = SevenLoginGiftData.New()

	self:RegisterAllProtocols()
end

function SevenLoginGiftCtrl:__delete()
	if self.login_gift7_view ~= nil then
		self.login_gift7_view:DeleteMe()
		self.login_gift7_view = nil
	end

	if self.login_gift7_data ~= nil then
		self.login_gift7_data:DeleteMe()
		self.login_gift7_data = nil
	end

	SevenLoginGiftCtrl.Instance = nil
end

function SevenLoginGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSevenDayLoginRewardInfo, "OnFetchSevenDayLoginReward")
	self:RegisterProtocol(CSFetchSevenDayLoginReward)
end

function SevenLoginGiftCtrl:OnFetchSevenDayLoginReward(protocol)
	self.login_gift7_data:OnFetchSevenDayLoginReward(protocol)
	self.login_gift7_view:Flush()
	RemindManager.Instance:Fire(RemindName.SevenLogin)
end

function SevenLoginGiftCtrl:SendSevenDayLoginRewardReq(fetch_day)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchSevenDayLoginReward)
	send_protocol.fetch_day = fetch_day
	send_protocol:EncodeAndSend()
end

