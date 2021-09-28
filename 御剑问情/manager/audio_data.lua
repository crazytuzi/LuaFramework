AudioData = AudioData or BaseClass()

function AudioData:__init()
	if AudioData.Instance then
		print_error("[AudioData] Attemp to create a singleton twice !")
	end
	AudioData.Instance = self
end

function AudioData:__delete()

end

function AudioData:GetAudioConfig()
	if not self.audio_config then
		self.audio_config = ConfigManager.Instance:GetAutoConfig("audio_auto")
	end
	return self.audio_config
end