
require("scripts/audio/audio_def")
require("scripts/audio/audio_adapter")

AudioManager = AudioManager or BaseClass()

AudioManager.CACHE_AUDIO = {
	1, 2, 11, 12, 18, 22, 29, 35, 39, 41, 44, 48, 49, 53, 55, 56, 57,
	61, 62, 63
}

function AudioManager:__init()
	if AudioManager.Instance then
		ErrorLog("[AudioManager] Attempt to create singleton twice!")
		return
	end
	AudioManager.Instance = self

	self.bg_music_path = ""							-- 背景音乐
	self.bg_music_on_off = (2 ~= cc.UserDefault:getInstance():getIntegerForKey("bg_music_on_off"))	-- 背景音乐开关

	self.effect_list = {}							-- 音效列表
	self.effect_on_off = (2 ~= cc.UserDefault:getInstance():getIntegerForKey("effect_on_off"))	-- 音效开关

	self.music_volume = cc.UserDefault:getInstance():getIntegerForKey("bg_music_per") - 1
	self.music_volume = self.music_volume >= 0 and self.music_volume or 30
	self.voice_volume = cc.UserDefault:getInstance():getIntegerForKey("effect__per") - 1
	self.voice_volume = self.voice_volume >= 0 and self.voice_volume or 60
	self.effect_playtime_list = {}
	self.is_scene_loading = false					-- 是否场景加载中
	self.is_recording = false						-- 是否录音中

	self.chat_record_time_quest = nil				-- 语音定时器
	self.pause_count = 0							-- 暂停次数

	self:RegisterAllEvents()
end

function AudioManager:__delete()
	self:StopMusic()
	self:ClearAllEffect()

	AudioManager.Instance = nil
end

function AudioManager:RegisterAllEvents()
	GlobalEventSystem:Bind(SettingEventType.SYSTEM_SETTING_CHANGE, BindTool.Bind1(self.OnSysSettingChange, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.OnEnterSceneLoading, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnQuitSceneLoading, self))
	GlobalEventSystem:Bind(LoginEventType.LOADING_COMPLETED, BindTool.Bind1(self.OnLoadingComplete, self))
end

function AudioManager:SetDefault()
	cc.UserDefault:getInstance():setIntegerForKey("bg_music_on_off", self.bg_music_on_off and 1 or 2)
	cc.UserDefault:getInstance():setIntegerForKey("effect_on_off", self.effect_on_off and 1 or 2)
	cc.UserDefault:getInstance():setIntegerForKey("bg_music_per", self.music_volume + 1)
	cc.UserDefault:getInstance():setIntegerForKey("effect__per", self.voice_volume + 1)
end

function AudioManager:OnSysSettingChange(setting_type, flag)
	if setting_type == SETTING_TYPE.CLOSE_BG_MUSIC then
		self:SetBgMusicOnOff(not flag)
	elseif setting_type == SETTING_TYPE.CLOSE_SOUND_EFFECT then
		self:SetEffectOnOff(not flag)
	end
end

function AudioManager:GetBgMusicOnOff()
	return self.bg_music_on_off
end

function AudioManager:GetEffectOnOff()
	return self.effect_on_off
end

-- 是否正在加载场景
function AudioManager:IsSceneLoading()
	return self.is_scene_loading
end

function AudioManager:GetPauseCount()
	return self.pause_count
end

function AudioManager:OnEnterSceneLoading()
	self.is_scene_loading = true
	AudioAdapter.StopAllEffects()
end

function AudioManager:OnQuitSceneLoading()
	self.is_scene_loading = false
end

function AudioManager:OnLoadingComplete()
	for k,v in pairs(AudioManager.CACHE_AUDIO) do
		AudioAdapter.PreloadEffect(ResPath.GetAudioEffectResPath(v))
	end
end

function AudioManager:PlayMusic(res_path)
	if "" ~= res_path and res_path ~= self.bg_music_path then
		self:StopMusic() --先停掉当前的
		if self.bg_music_on_off then
			AudioAdapter.PlayMusic(res_path, true)
			if self:IsPause() then
				AudioAdapter.PauseMusic()
			end
			AudioAdapter.SetMusicVolume(self.music_volume / 100)
		end
		self.bg_music_path = res_path
	end
end

function AudioManager:StopMusic()
	if "" ~= self.bg_music_path then
		AudioAdapter.StopMusic(true)
		self.bg_music_path = ""
	end
end

function AudioManager:SetBgMusicOnOff(on_off)
	if self.bg_music_on_off ~= on_off then
		self.bg_music_on_off = on_off
		self:SetDefault()

		if on_off then
			AudioAdapter.PlayMusic(self.bg_music_path, true)
		else
			AudioAdapter.StopMusic(false)
		end
	end
end

function AudioManager:SetMusicVolume(volume)
	if self.music_volume ~= volume * 100 then
		self.music_volume = volume * 100
		self:SetDefault()
		AudioAdapter.SetMusicVolume(volume)
	end
end

-- 播放音效，@res_path 音效路径， @interval 最小播放间隔
function AudioManager:PlayEffect(res_path, interval)
	if not self.effect_on_off or self:IsSceneLoading() or self:IsPause() then
		return
	end

	if FpsSampleUtil.Instance:GetFps() < 50 then
		return
	end
	interval = interval or AudioInterval.Common
	if "" ~= res_path then
		AudioAdapter.SetEffectsVolume(self.voice_volume / 100)
		
		local t = self.effect_list[res_path]
		if nil == t then
			t = {play_time = 0, handle = 0}
			self.effect_list[res_path] = t
		end

		if t.play_time + interval > Status.NowTime then
			return
		end

		if #self.effect_playtime_list >= 3 then
			if Status.NowTime - self.effect_playtime_list[1] < 1 then
				return
			end
			table.remove(self.effect_playtime_list, 1)
		end
		table.insert(self.effect_playtime_list, Status.NowTime)

		t.play_time = Status.NowTime
		t.handle = AudioAdapter.PlayEffect(res_path, false)
	end
end

function AudioManager:StopEffect(res_path)
	for k,v in pairs(self.effect_list) do
		if k == res_path then
			AudioAdapter.StopEffect(v.handle)
		end
	end
end

function AudioManager:ClearAllEffect()
	for k, v in pairs(self.effect_list) do
		AudioAdapter.UnloadEffect(k)
	end
	self.effect_list = {}
end

function AudioManager:SetEffectOnOff(on_off)
	if self.effect_on_off ~= on_off then
		self.effect_on_off = on_off
		self:SetDefault()

		if not on_off then
			AudioAdapter.StopAllEffects()
		end
	end
end

function AudioManager:SetEffectsVolume(volume)
	if self.voice_volume ~= volume * 100 then
		self.voice_volume = volume * 100
		self:SetDefault()
		AudioAdapter.SetEffectsVolume(volume)
	end
end

-- 播放打开界面通用音效
function AudioManager:PlayOpenCloseUiEffect()
	self:PlayEffect(ResPath.GetAudioEffectResPath(1), AudioInterval.Common)
end

-- 播放语音
function AudioManager:PlayChatRecord(res_path, time, stop_callback)
	self:StopChatRecord()

	self:Pause()

	AudioAdapter.PlayEffect(res_path)

	local function timer_callback()
		self.chat_record_time_quest = nil

		self:Resume()

		AudioAdapter.UnloadEffect(res_path)

		if nil ~= stop_callback then
			stop_callback()
		end
	end
	self.chat_record_time_quest = GlobalTimerQuest:AddDelayTimer(timer_callback, time)
end

-- 停止播放语音
function AudioManager:StopChatRecord()
	if nil ~= self.chat_record_time_quest then
		GlobalTimerQuest:EndQuest(self.chat_record_time_quest)
		self.chat_record_time_quest = nil
	end
end

-- 开始录音
function AudioManager:StartMediaRecord()
	if self.is_recording then
		return false
	end

	if "false" == PlatformBinder:JsonCall("call_start_media_record") then
		return false
	end

	self.is_recording = true
	self:Pause()

	return true
end

-- 结束录音，return文件路径
function AudioManager:StopMediaRecord()
	if not self.is_recording then
		return ""
	end

	self.is_recording = false
	self:Resume()
	return PlatformBinder:JsonCall("call_stop_media_record")
end

-- 是否暂停中
function AudioManager:IsPause()
	return self.pause_count > 0
end

-- 暂停
function AudioManager:Pause()
	self.pause_count = self.pause_count + 1
	if self.bg_music_on_off then
		AudioAdapter.PauseMusic()
	end
	AudioAdapter.StopAllEffects()
end

-- 恢复
function AudioManager:Resume(is_force)
	if is_force then
		self.pause_count = 0
	else
		self.pause_count = self.pause_count - 1
		if self.pause_count < 0 then self.pause_count = 0 end
	end

	if self.bg_music_on_off and self.pause_count <= 0 then
		AudioAdapter.ResumeMusic()
	end
end
