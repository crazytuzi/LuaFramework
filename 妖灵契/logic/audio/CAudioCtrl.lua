local CAudioCtrl = class("CAudioCtrl", CCtrlBase)
define.Audio = {
	SoundPath = {
		Btn = "UI/ui_sound_001.wav",
		Tab = "UI/ui_sound_002.wav",
		ClickItem = "UI/ui_sound_003.wav",
		SellItem = "UI/ui_sound_004.wav",
	},
	PlaySoundForType = {
		SellItem = 1,
	},
	Event = {
		LoadDone = 1,
	}
}
--音频播放管理
function CAudioCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_SoloPlayer = AudioTools.CreateAudioPlayer("solo")
	self.m_MusicPlayer = AudioTools.CreateAudioPlayer("music") --背景音乐
	self.m_MusicPlayer:SetLoop(true)
	self.m_SoundPlayerList = {}	--音效播放控件列表
	self.m_MusicRate = 1 --音乐
	self.m_SoundEffectRate = 1 --音效	
	self.m_SoloResumeRate = 1 --单独播放(聊天语音)
	self:CheckAuidoAll()
end

--根据系统设置检测所有音频
function CAudioCtrl.CheckAuidoAll(self)
	self:CheckMusic()
	self:CheckSoundEffect()
	self:CheckSoloResume()
end

function CAudioCtrl.CheckMusic(self)
	local volume = 0
	local bEnabled = g_SysSettingCtrl:IsMusicEnabled()
	if bEnabled then
		volume = g_SysSettingCtrl:GetMusicPercentage()
	end
	self.m_MusicRate = volume
	self.m_MusicPlayer:SetVolume(volume)
end

function CAudioCtrl.SetMusicRate(self, volume)
	self.m_MusicRate = volume
	self.m_MusicPlayer:SetVolume(volume)
end

function CAudioCtrl.GetMusicRate(self)
	return self.m_MusicRate
end

function CAudioCtrl.CheckSoundEffect(self)
	local volume = 0
	local bEnabled = g_SysSettingCtrl:IsSoundEffectEnabled()
	if bEnabled then
		volume = g_SysSettingCtrl:GetSoundEffectPercentage()
	end 
	self.m_SoundEffectRate = volume
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:SetVolume(volume)
	end
end

function CAudioCtrl.CheckSoloResume(self)
	local volume = 0
	local bEnabled = g_SysSettingCtrl:IsDubbingEnabled()
	if bEnabled then
		volume = g_SysSettingCtrl:GetDubbingPercentage()
	end 
	self.m_SoloResumeRate = volume
	self.m_SoloPlayer:SetVolume(volume)
end

--根据系统设置刷新全部音频
function CAudioCtrl.RefreshAllVolume(self)
	--音乐
	self.m_MusicPlayer:SetVolume(self.m_MusicRate)
	--音效
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:SetVolume(self.m_SoundEffectRate)
	end
	--单独
	self.m_SoloPlayer:SetVolume(self.m_SoloResumeRate)
end

--单独播放
function CAudioCtrl.SoloPath(self, path, iRate, cb)
	local function onStop()
		if cb then cb() end
		self:RefreshAllVolume()
	end
	self.m_SoloPlayer:Play(path)
	self.m_SoloPlayer:SetStopCb(onStop)
	iRate = iRate or 0
	self:SetVolumeRate(iRate, self.m_SoloPlayer)
end

--单独播放
function CAudioCtrl.PlaySingle(self, path, cb)
	local function onStop()
		if cb then 
			cb() 
		end
	end
	self.m_SoloPlayer:Play(path)
	self.m_SoloPlayer:SetStopCb(onStop)
end
 
--单独播放
function CAudioCtrl.SoloClip(self, oClip, iRate, cb)
	local function onStop()
		if cb then cb() end
		self:RefreshAllVolume()
	end
	self.m_SoloPlayer:SetClip(oClip)
	self.m_SoloPlayer:SetStopCb(onStop)
	iRate = iRate or 0
	self:SetVolumeRate(iRate, self.m_SoloPlayer)
end

--音乐
function CAudioCtrl.PlayMusic(self, sPath, bFade)
	local sABPath = "Audio/Music/"..sPath
	self.m_MusicPlayer:FadePlay(sABPath)
end

function CAudioCtrl.PlayNormalMusic(self, filename)
	local sABPath = "Audio/Music/"..filename..".ogg"
	self.m_MusicPlayer:FadePlay(sABPath)
end

function CAudioCtrl.PlayWarMusic(self, filename)
	local sABPath = "Audio/Music/"..filename..".ogg"
	self.m_MusicPlayer:FadePlay(sABPath)
end

function CAudioCtrl.StopMusic(self)
	self.m_MusicPlayer:OnStopPlay()
end

--音效

function CAudioCtrl.PlaySound(self, sPath, bScaled, iRate)
	local bEnabled = g_SysSettingCtrl:IsSoundEffectEnabled()
	if not bEnabled then
		return
	end
	local sABPath = "Audio/Sound/"..sPath
	local oAudioPlayer = self:GetSoundPlayer()
	oAudioPlayer:SetScaledTime(bScaled==true)
	if iRate then
		oAudioPlayer:SetRate(self.m_SoundEffectRate * iRate)
	end
	
	oAudioPlayer:Play(sABPath)
	return oAudioPlayer
end

--剧情对话
function CAudioCtrl.PlayVoice(self, voceId)
	local bEnabled = g_SysSettingCtrl:IsSoundEffectEnabled()
	if not bEnabled then
		return
	end
	local function endCb()		
		self.m_MusicPlayer:SetVolumeFade(self.m_MusicRate)	
	end
	self.m_MusicPlayer:SetVolumeFade(self.m_MusicRate * 0.5)
	self.m_SoloPlayer:SetStopCb(endCb)
	local sABPath = "Audio/Sound/Story/sound_story_"..voceId..".wav"
	self.m_SoloPlayer:Play(sABPath, true)
end

function CAudioCtrl.OnStopPlay(self)
	self.m_MusicPlayer:SetVolume(self.m_MusicRate)	
	self.m_SoloPlayer:OnStopPlay()
end

--引导语音
function CAudioCtrl.PlayGuideVoice(self, voice)
	local bEnabled = g_SysSettingCtrl:IsSoundEffectEnabled()
	if not bEnabled then
		return
	end
	local sABPath = "Audio/Sound/Live2D/1003/sound_"..voice..".wav"
	self.m_SoloPlayer:Play(sABPath)
end

function CAudioCtrl.PlaySoundForType(self, type)
	local sPath
	if type == define.Audio.PlaySoundForType.SellItem then
		sPath = define.Audio.SoundPath.SellItem
	end
	self:PlaySound(sPath)
end

--音量
function CAudioCtrl.SetVolumeRate(self, iRate, oExclude)
	local list = {self.m_MusicPlayer, self.m_SinglePlayer}
	list = table.extend(list, self.m_SoundPlayerList)
	for i, oCachePlayer in ipairs(list) do
		if not oExclude or oExclude ~= oCachePlayer then
			oCachePlayer:SetVolume(iRate)
		end
	end
end

--静音
function CAudioCtrl.SetSlience(self)
	self:SetVolumeRate(0)
end

function CAudioCtrl.ExitSlience(self)
	self:RefreshAllVolume()
end

function CAudioCtrl.GetSoundPlayer(self)
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		if oCachePlayer:IsReuse() then
			return oCachePlayer
		end
	end
	local oAudioPlayer = AudioTools.CreateAudioPlayer("sound"..tostring(#self.m_SoundPlayerList+1))
	oAudioPlayer:SetRate(self.m_SoundEffectRate)
	table.insert(self.m_SoundPlayerList, oAudioPlayer)
	return oAudioPlayer
end

function CAudioCtrl.StopSound(self)
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:Stop()
	end
end

return CAudioCtrl