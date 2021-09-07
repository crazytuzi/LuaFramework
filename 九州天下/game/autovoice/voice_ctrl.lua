require("game/autovoice/voice_view")
require("game/autovoice/chat_record_mgr")

AutoVoiceCtrl = AutoVoiceCtrl or BaseClass(BaseController)

function AutoVoiceCtrl:__init()
	if AutoVoiceCtrl.Instance then
		print_error("[AutoVoiceCtrl]:Attempt to create singleton twice!")
	end
	AutoVoiceCtrl.Instance = self

	self.view = AutoVoiceView.New()
end

function AutoVoiceCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	AutoVoiceCtrl.Instance = nil
end

function AutoVoiceCtrl:ShowVoiceView(channel_type)
	self.view:SetChannelType(channel_type)
	self.view:Open()
end