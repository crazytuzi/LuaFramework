require("game/logingift7/login_gift7_view")
require("game/logingift7/login_gift7_data")

LoginGift7Ctrl = LoginGift7Ctrl or BaseClass(BaseController)

function LoginGift7Ctrl:__init()
	if nil ~= LoginGift7Ctrl.Instance then
		print_error("[LoginGift7Ctrl] Attemp to create a singleton twice !")
		return
	end
	LoginGift7Ctrl.Instance = self

	self.login_gift7_view = LoginGift7View.New(ViewName.LoginGift7View)
	self.login_gift7_data = LoginGift7Data.New()

	self:RegisterAllProtocols()
end

function LoginGift7Ctrl:__delete()
	if self.login_gift7_view ~= nil then
		self.login_gift7_view:DeleteMe()
		self.login_gift7_view = nil
	end

	if self.login_gift7_data ~= nil then
		self.login_gift7_data:DeleteMe()
		self.login_gift7_data = nil
	end

	LoginGift7Ctrl.Instance = nil
end

function LoginGift7Ctrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSevenDayLoginRewardInfo, "OnFetchSevenDayLoginReward")
	self:RegisterProtocol(CSFetchSevenDayLoginReward)
end

function LoginGift7Ctrl:OnFetchSevenDayLoginReward(protocol)
	self.login_gift7_data:OnFetchSevenDayLoginReward(protocol)
	ViewManager.Instance:FlushView(ViewName.Main, "login_gift_icon", {self.login_gift7_data:GetLoginAllReward()})
	if self.login_gift7_view:IsOpen() then
		self.login_gift7_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SevenLogin)
end

function LoginGift7Ctrl:SendSevenDayLoginRewardReq(fetch_day)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchSevenDayLoginReward)
	send_protocol.fetch_day = fetch_day
	send_protocol:EncodeAndSend()
end

