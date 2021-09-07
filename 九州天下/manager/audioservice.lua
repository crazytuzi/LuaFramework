require("manager/audio_data")
-- 音频管理
AudioService = AudioService or BaseClass()

function AudioService:__init()
	if AudioService.Instance ~= nil then
		print_error("AudioService to create singleton twice!")
	end
	AudioService.Instance = self

	self.data = AudioData.New()

	AssetManager.LoadObject(
		"audios/mixers",
		"Audio Main",
		typeof(UnityEngine.Audio.AudioMixer),
		BindTool.Bind(self.OnLoadComplete, self))

	self.music_volume = 1.0
	self.sfx_volume = 1.0
	self.master_volume = 1.0
	self.audio_mixer = nil
end

function AudioService:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.audio_player then
		self:StopBgm()
		self.audio_player = nil
	end
	if self.audio_item then
		ScriptablePool.Instance:Free(self.audio_item)
		self.audio_item = nil
	end
end

function AudioService:OnLoadComplete(mixer)
	self.audio_mixer = mixer
	self.audio_mixer:SetFloat("MusicVolume", self.music_volume)
	self.audio_mixer:SetFloat("SFXVolume", self.sfx_volume)
	self.audio_mixer:SetFloat("MasterVolume", self.master_volume)
end

function AudioService:SetMusicVolume(volume)
	self.music_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("MusicVolume", 80 * self.music_volume - 80)
	end
end

function AudioService:SetSFXVolume(volume)
	self.sfx_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("SFXVolume", 80 * self.sfx_volume - 80)
	end
end

-- 播放领取奖励的音效
function AudioService:PlayRewardAudio()
	local audio_config = AudioData.Instance:GetAudioConfig()
	if audio_config then
		AudioManager.PlayAndForget(AssetID("audios/sfxs/other", audio_config.other[1].Rewards))
	end
end

-- 播放进阶成功的音效
function AudioService:PlayAdvancedAudio()
	local audio_config = AudioData.Instance:GetAudioConfig()
	if audio_config then
		AudioManager.PlayAndForget(AssetID("audios/sfxs/uis", audio_config.other[1].Advanced))
	end
end

-- 得到当前音效音量
function AudioService:GetSFXVolume()
	return self.sfx_volume
end

--关闭所有声音
function AudioService:SetMasterVolume(volume)
	self.master_volume = volume
	if self.audio_mixer ~= nil then
		self.audio_mixer:SetFloat("MasterVolume", 80 * self.master_volume - 80)
	end
end

--得到当前总音量
function AudioService:GetMasterVolume()
	return self.master_volume
end

-- 播放背景音乐
function AudioService:PlayBgm(bundle, asset)
	ScriptablePool.Instance:Load(AssetID(bundle, asset), function(audio_item)
		if nil == audio_item then
			return
		end
		if self.audio_player then
			self:StopBgm()
		end
		if self.audio_item then
			ScriptablePool.Instance:Free(self.audio_item)
		end
		self.audio_item = audio_item
		self.audio_player = AudioManager.Play(audio_item)
	end)
end

function AudioService:StopBgm()
	UtilU3d.StopAudioPlayer(self.audio_player)
end