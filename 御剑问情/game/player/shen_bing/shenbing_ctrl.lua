require("game/player/shen_bing/shenbing_data")
ShenBingCtrl = ShenBingCtrl or BaseClass(BaseController)

function ShenBingCtrl:__init()
	if ShenBingCtrl.Instance then
		print_error("[ShenBingCtrl] Attemp to create a singleton twice !")
	end
	ShenBingCtrl.Instance = self
	self.data = ShenBingData.New()
	self:RegisterAllProtocols()
end

function ShenBingCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	ShenBingCtrl.Instance = nil
end

function ShenBingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllShenBingInfo, "OnSCAllShenBingInfo")
end

function ShenBingCtrl:OnSCAllShenBingInfo(protocol)
	local play_effect = self.data:CheckPlayEffect(protocol.level)
	self.data:SetShenBingInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Advance, "shenbing", {flag = play_effect})
	--[[local player_view = PlayerCtrl.Instance:GetView()
	if player_view:IsOpen() then
		player_view:Flush("shen_bing")
		if play_effect == true then player_view:GetShenBingView():PlayUpStarEffect() end
	end--]]
	AdvanceCtrl.Instance:FlushZiZhiTips()
end

function ShenBingCtrl:OnUpgradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		ViewManager.Instance:FlushView(ViewName.Advance, "upgraderesult", {result == 1 and true or false})
	end
end

function ShenBingCtrl.SentShenBingUpLevel(stuff_index, is_auto)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenBingUpLevel)
	send_protocol.stuff_index = stuff_index
	send_protocol.is_auto = is_auto or 0

	local shenbing_info = ShenBingData.Instance:GetShenBingInfo()
	if nil ~= next(shenbing_info) then
		send_protocol.auto_uplevel_times = ShenBingData.Instance:GetPackNumByLevel(shenbing_info.level)
	else
		send_protocol.auto_uplevel_times = 1
	end

	send_protocol:EncodeAndSend()
end

function ShenBingCtrl.SentShenBingUseImage(use_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenBingUseImage)
	send_protocol.use_image = use_image
	send_protocol.resevre = 0
	send_protocol:EncodeAndSend()
end
