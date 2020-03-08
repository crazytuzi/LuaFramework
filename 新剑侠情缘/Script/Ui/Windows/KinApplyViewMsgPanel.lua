local tbUi = Ui:CreateClass("KinApplyViewMsgPanel")

tbUi.tbOnClick = 
{
	BtnSure = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	Message = function(self)
		if not self:HasVoice() then
			return
		end
		ChatMgr:PlayVoice(ChatMgr.nChannelKinApply, self.tbVoice[1], self.tbVoice[2])
	end,

}

function tbUi:RegisterEvent()
	return {
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
	}
end

function tbUi:OnOpen(szName, szMsg, tbVoice)
	self:PlayVoiceAni("VoiceBig4")
	self.tbVoice = tbVoice
	self.pPanel:Label_SetText("Title", string.format("%s的留言", szName))
	self.pPanel:Label_SetText("MessageTxt", szMsg)

	local voiceSize = {x = 0, y = 0}
	local bHasVoice = self:HasVoice()
	self.pPanel:SetActive("VoiceNode", bHasVoice)
	if bHasVoice then
		self.pPanel:Label_SetText("TxtVoiceTime", Lib:TimeDesc4(math.floor(tbVoice[3] / 1000)))

		local speakerSize = self.pPanel:Sprite_GetSize("Speaker")
		local voiceTimeSize = self.pPanel:Label_GetPrintSize("TxtVoiceTime")
		voiceSize.x = speakerSize.x + voiceTimeSize.x
		voiceSize.y = math.max(speakerSize.y, voiceTimeSize.y)
	end

	local msgPos = self.pPanel:GetPosition("MessageTxt");
	self.pPanel:ChangePosition("MessageTxt", msgPos.x, -voiceSize.y-10)
end

function tbUi:HasVoice()
	return #(self.tbVoice or {}) >= 2 and self.tbVoice[3] > 0 and GetTime() - self.tbVoice[4] < 24 * 3600
end

function tbUi:OnVoiceStart(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoice[1] or uFileIdLow ~= self.tbVoice[2] then
		return
	end
	self:PlayVoiceAni("VoiceBig")
end

function tbUi:OnVoiceEnd(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoice[1] or uFileIdLow ~= self.tbVoice[2] then
		return
	end
	self:PlayVoiceAni("VoiceBig4")
end

function tbUi:PlayVoiceAni(szAni)
	self.pPanel:Sprite_Animation("Speaker", szAni, nil, 4)
end