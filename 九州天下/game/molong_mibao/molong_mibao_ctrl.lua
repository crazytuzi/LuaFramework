require("game/molong_mibao/molong_mibao_data")
require("game/molong_mibao/molong_mibao_view")

MolongMibaoCtrl = MolongMibaoCtrl or  BaseClass(BaseController)

function MolongMibaoCtrl:__init()
	if MolongMibaoCtrl.Instance ~= nil then
		print_error("[MolongMibaoCtrl] attempt to create singleton twice!")
		return
	end
	MolongMibaoCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = MolongMibaoData.New()
	self.view = MolongMibaoView.New(ViewName.MolongMibaoView)
end

function MolongMibaoCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	MolongMibaoCtrl.Instance = nil
end

function MolongMibaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendMagicalPreciousInfo, "OnSendMagicalPreciousInfo")
end

function MolongMibaoCtrl:OnSendMagicalPreciousInfo(protocol)
	self.data:SetMibaoChapterFlag(protocol.mibao_chapter_flag_t)
	self.view:Flush()
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, MainUIData.RemindingName.MolongMibao, self.data:IsShowMolongMibao())
	RemindManager.Instance:Fire(RemindName.MoLongMiBao)
end

function MolongMibaoCtrl.SendFetchMagicalPreciousRewardReq(chapter, reward_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchMagicalPreciousRewardReq)
	send_protocol.chapter = chapter
	send_protocol.reward_index = reward_index
	send_protocol:EncodeAndSend()
end