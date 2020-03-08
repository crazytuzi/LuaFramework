
local tbVoice = Ui:CreateClass("VoiceRecord");

function tbVoice:OnOpen()
	self:ChangeVoiceState()
	self.pPanel:ProgressBar_SetValue("VolumeIcon", 0)
end

function tbVoice:ChangeVoiceState(bCancel)
	if bCancel then
		self.pPanel:SetActive("RecordingCancel", true)
		self.pPanel:SetActive("VoiceRecording", false)
	else
		self.pPanel:SetActive("RecordingCancel", false)
		self.pPanel:SetActive("VoiceRecording", true)
	end

end

function tbVoice:OnVolumeChange(nVolume)
	self.pPanel:ProgressBar_SetValue("VolumeIcon", nVolume/30)
end

function tbVoice:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG, self.OnVolumeChange},
    };
end
