_G.classlist['SoundManager'] = 'SoundManager'
_G.SoundManager = CSingle:new()
_G.SoundManager.objName = 'SoundManager'

CSingleManager:AddSingle(SoundManager)

SoundManager.EffectDelayTime = 1500;--允许的加载延迟时间
SoundManager.sfxLoadMap = {};
SoundManager.lastEffectName = "";
SoundManager.lastSfxName = "";
local isFadeBg = false;
function SoundManager:Create()
    self.objBackSfxPlayer = _SoundGroup.new()   	--背景音播放器
	self.objBackSfxStoryPlayer = _SoundGroup.new() 	--剧情背景音乐播放器
	self.objSfxPlayer = _SoundGroup.new()       	--播放能停止的音效播放器
    self.objEffectPlayer = _SoundGroup.new()    	--播放一次不需要停止音效播放器
    self.objSkillPlayer = _SoundGroup.new()         --播放技能音效播放器
    self.objBackSfxPlayer.volume = 1
	self.objBackSfxStoryPlayer.volume = 1
    self.objSfxPlayer.volume = 1
    self.objEffectPlayer.volume = 1
    self.objSkillPlayer.volume = 1
    _sd.fadeTime = 2000
    self.loaderlist = {}
    self.currBackSfxPlayerFile = nil
    self.currBackSfxStoryPlayerFile = nil
    CControlBase:RegControl(self, true)
    return true
end
local oldBackSoundVol = 0;
function SoundManager:TurnDownBackSoundVolume()
	oldBackSoundVol = self.objBackSfxPlayer.volume;
	local targetVol = self.objSfxPlayer.volume * 100 * 0.2;
	local params = {val1=oldBackSoundVol * 100, _target="sdparams"};
	Tween:To(params,1,{val1=targetVol},{onUpdate=function()
		self:SetBackSoundVolume(params.val1);
	end});
end

function SoundManager:RecoverBackSoundVolume()
	local targetVol = oldBackSoundVol * 100;
	local params = {val1=self.objBackSfxPlayer.volume * 100, _target="sdparams"};
	Tween:To(params,1,{val1=targetVol},{onUpdate=function()
		self:SetBackSoundVolume(params.val1);
	end});
end

function SoundManager:GetSoundInfo(soundID)
	local sfxCfg = t_music[soundID]
	if not sfxCfg then
		Error("not sfxCfg by", soundID)
		return nil
	end
	return _sd:getSoundInfo(sfxCfg.sound_file);
end

function SoundManager:SetBackSoundVolume(backSoundVolume)
    self.objBackSfxPlayer.volume = backSoundVolume/100;
end

function SoundManager:SetBackSoundStoryVolume(backSoundVolume)
    self.objBackSfxStoryPlayer.volume = backSoundVolume/100
end

function SoundManager:SetMusicVolume(musicVolume)
    self.objSfxPlayer.volume = musicVolume/100
    self.objEffectPlayer.volume = musicVolume/100
    self.objSkillPlayer.volume = musicVolume/100
end

function SoundManager:SetBackSoundMute(flag)
    self.objBackSfxPlayer.mute = flag
end

function SoundManager:SetBackSoundStoryMute(flag)
    self.objBackSfxStoryPlayer.mute = flag
end

function SoundManager:SetMusicMute(flag)  
    self.objSfxPlayer.mute = flag
    self.objEffectPlayer.mute = flag
    self.objSkillPlayer.mute = flag
end

--播放背景音
function SoundManager:PlayBackSfx(soundID)
    local sfxCfg = t_music[soundID]
    if not sfxCfg then
        Error("not sfxCfg by", soundID)
        return nil
    end


	local has = self:SoundFileExist(sfxCfg.sound_file);
	if not has then
		WriteLog(LogType.Normal,true,'PlayBackSfx时声音文件不存在'..sfxCfg.sound_file);
		return;
	end
	
    local loopType = nil
    if sfxCfg.loop == 1 then
        loopType = _SoundDevice.Loop + _SoundDevice.FadeIn
    else
        loopType = _SoundDevice.FadeIn
    end
    local loader = _Loader.new()
    self.loaderlist[sfxCfg.sound_file] = loader
    self.currBackSfxPlayerFile = sfxCfg.sound_file
    loader:load("resfile/sound/" .. sfxCfg.sound_file)
	--把主城背景音乐的优先级降低
	if soundID == 1012 then
		loader.lowPriority = true;
	end
    loader:onFinish(function()
        if self.currBackSfxPlayerFile == sfxCfg.sound_file then
            self.objBackSfxPlayer:stop(_SoundDevice.FadeOut)
            self.objBackSfxPlayer:play(sfxCfg.sound_file, loopType)
			self:RecoverBackSoundVolume()
			isFadeBg = false;
            self.currBackSfxPlayerFile = nil
        end
        self.loaderlist[sfxCfg.sound_file] = nil
    end)
end

--停止播放背景音乐
function SoundManager:StopBackSfx()
    self.currBackSfxPlayerFile = nil
    self.objBackSfxPlayer:stop(_SoundDevice.FadeOut)
end

--播放剧情的背景音
function SoundManager:PlayStoryBackSfx(soundID)
    local sfxCfg = t_music[soundID]
    if not sfxCfg then
        Error("not sfxCfg by", soundID)
        return nil
    end

	local has = self:SoundFileExist(sfxCfg.sound_file);
	if not has then
		WriteLog(LogType.Normal,true,'PlayStoryBackSfx时声音文件不存在'..sfxCfg.sound_file);
		return;
	end
	
    local loopType = nil
    if sfxCfg.loop == 1 then
        loopType = _SoundDevice.Loop + _SoundDevice.FadeIn
    else
        loopType = _SoundDevice.FadeIn
    end
	self:SetBackSoundMute(true)
	
    local loader = _Loader.new()
    self.currBackSfxStoryPlayerFile = sfxCfg.sound_file
    self.loaderlist[sfxCfg.sound_file] = loader
    loader:load("resfile/sound/" .. sfxCfg.sound_file)
    loader:onFinish(function()
        if self.currBackSfxStoryPlayerFile == sfxCfg.sound_file then
            self.objBackSfxStoryPlayer:stop(_SoundDevice.FadeOut)
            self.objBackSfxStoryPlayer:play(sfxCfg.sound_file, loopType)
            self.currBackSfxStoryPlayerFile = nil
        end
        self.loaderlist[sfxCfg.sound_file] = nil
    end)
end

--停止播放剧情背景音乐
function SoundManager:StopStoryBackSfx()
    self.currBackSfxStoryPlayerFile = nil
    self.objBackSfxStoryPlayer:stop(_SoundDevice.FadeOut)
	if SetSystemModel:LoadAudioMute() == 1 then
		self:SetBackSoundMute(false)
	end

	--[[
	if not SetSystemModel:GetMusicIsOpen() then
		self:SetBackSoundMute(false)
	end
	]]
end

--播放音效
function SoundManager:PlaySfx(soundID,fadeBg, bLogin)

    if not bLogin and not MainPlayerController.isEnter then
        return
    end
    if not soundID then
        return
    end
    local sfxCfg = t_music[soundID]
    if not sfxCfg then
        Error("not sfxCfg by ", soundID)
        return
    end

	local has = self:SoundFileExist(sfxCfg.sound_file);
	if not has then
		WriteLog(LogType.Normal,true,'PlaySfx时声音文件不存在'..sfxCfg.sound_file);
		return;
	end
	
	
    local loopType = nil
    if sfxCfg.loop == 1 then
        loopType = _SoundDevice.Loop
    end
	if _sys:fileExist(self:GetSoundFilePath(sfxCfg.sound_file)) then
		self.objEffectPlayer:play(sfxCfg.sound_file, loopType)
		if fadeBg then
			self:FadeBg(soundID);
		end
	else
		self.lastEffectName = sfxCfg.sound_file;
		for i,vo in ipairs(self.sfxLoadMap) do
			if vo.name == sfxCfg.sound_file then
				vo.startTime = GetCurTime();
				return;
			end
		end
		local vo = {};
		vo.name = sfxCfg.sound_file;
		vo.loader = _Loader.new();
		vo.startTime = GetCurTime();
		vo.loader:load("resfile/sound/" .. sfxCfg.sound_file)
		vo.loader:onFinish(function()
			for i,v in ipairs(self.sfxLoadMap) do
				if v.name == vo.name then
					if self.lastEffectName==vo.name and GetCurTime()-vo.startTime<SoundManager.EffectDelayTime then
						self.objEffectPlayer:play(sfxCfg.sound_file, loopType);
						self.lastEffectName = "";
						if fadeBg then
							self:FadeBg(soundID);
						end

					end
					table.remove(self.sfxLoadMap,i,1);
					break;
				end
			end
		end);
		table.push(self.sfxLoadMap,vo);
	end
end

function SoundManager:FadeBg(file)
	if not isFadeBg then
		isFadeBg = true;
		self:TurnDownBackSoundVolume()
	end
end

function SoundManager:StopSfx()
	self.lastEffectName = "";
    self.objEffectPlayer:stop()
end


--播放音效
function SoundManager:PlaySkillSfx(soundID)
    if not soundID then
        return
    end
    local sfxCfg = t_music[soundID]
    if not sfxCfg then
        Error("not sfxCfg by ", soundID)
        return
    end

	local has = self:SoundFileExist(sfxCfg.sound_file);
	if not has then
		WriteLog(LogType.Normal,true,'PlaySkillSfx时声音文件不存在'..sfxCfg.sound_file);
		return;
	end
	
    local loopType = nil
    if sfxCfg.loop == 1 then
        loopType = _SoundDevice.Loop
    end
    if _sys:fileExist(self:GetSoundFilePath(sfxCfg.sound_file)) then
        self.objSkillPlayer:play(sfxCfg.sound_file, loopType)
    else
        self.lastEffectName = sfxCfg.sound_file;
        for i,vo in ipairs(self.sfxLoadMap) do
            if vo.name == sfxCfg.sound_file then
                vo.startTime = GetCurTime();
                return;
            end
        end
        local vo = {};
        vo.name = sfxCfg.sound_file;
        vo.loader = _Loader.new();
        vo.startTime = GetCurTime();
        vo.loader:load("resfile/sound/" .. sfxCfg.sound_file)
        vo.loader:onFinish(function()
            for i,v in ipairs(self.sfxLoadMap) do
                if v.name == vo.name then
                    if self.lastEffectName==vo.name and GetCurTime()-vo.startTime<SoundManager.EffectDelayTime then
                        self.objSkillPlayer:play(sfxCfg.sound_file, loopType);
                        self.lastEffectName = "";
                    end
                    table.remove(self.sfxLoadMap,i,1);
                    break;
                end
            end
        end);
        table.push(self.sfxLoadMap,vo);
    end
end

function SoundManager:StopSkillSfx()
    self.lastEffectName = "";
    self.objSkillPlayer:stop()
end

--播放音效
function SoundManager:PlayEffectSound(soundID)
    if not soundID then
        return
    end
    local sfxCfg = t_music[soundID]
    if not sfxCfg then
        Error("not sfxCfg by ", soundID)
        return
    end

	local has = self:SoundFileExist(sfxCfg.sound_file);
	if not has then
		WriteLog(LogType.Normal,true,'PlayEffectSound时声音文件不存在'..sfxCfg.sound_file);
		return;
	end
	
    local loopType = nil
    if sfxCfg.loop == 1 then
        loopType = _SoundDevice.Loop
    end
	if _sys:fileExist(self:GetSoundFilePath(sfxCfg.sound_file)) then
		self.objSfxPlayer:play(sfxCfg.sound_file, loopType)
	else
		self.lastSfxName = sfxCfg.sound_file;
		for i,vo in ipairs(self.sfxLoadMap) do
			if vo.name == sfxCfg.sound_file then
				return;
			end
		end
		local vo = {};
		vo.name = sfxCfg.sound_file;
		vo.loader = _Loader.new();
		vo.startTime = GetCurTime();
		vo.loader:load("resfile/sound/" .. sfxCfg.sound_file)
		vo.loader:onFinish(function()
			for i,v in ipairs(self.sfxLoadMap) do
				if v.name == vo.name then
					if self.lastSfxName==vo.name and GetCurTime()-vo.startTime<SoundManager.EffectDelayTime then
						self.objSfxPlayer:play(sfxCfg.sound_file, loopType);
						self.lastSfxName = "";
					end
					table.remove(self.sfxLoadMap,i,1);
					break;
				end
			end
		end);
		table.push(self.sfxLoadMap,vo);
	end
end

function SoundManager:StopEffectSound()
	self.lastSfxName = "";
    self.objSfxPlayer:stop()
end


function SoundManager:Update()
	if isFadeBg then
		if not self.objEffectPlayer:isPlaying() then
			self:RecoverBackSoundVolume()
			isFadeBg = false;
		end
	end
end

function SoundManager:OnActive(isActive)
    if isActive then
        if SetSystemController.BackSoundMute then
            SoundManager:SetBackSoundMute(true)
            SoundManager:SetBackSoundStoryMute(true)
        else
            SoundManager:SetBackSoundMute(false)
            SoundManager:SetBackSoundStoryMute(false)
        end
        if SetSystemController.MusicMute then
            SoundManager:SetMusicMute(true)
        else
            SoundManager:SetMusicMute(false)
        end              
    else
        SoundManager:SetBackSoundMute(true)
        SoundManager:SetBackSoundStoryMute(true)
        SoundManager:SetMusicMute(true)
    end
end

function SoundManager:GetSoundFilePath(fileName)
	return "resfile/sound/" .. fileName;
end

function SoundManager:SoundFileExist(fileName)
	local has = _sys:fileExist(self:GetSoundFilePath(fileName));
	if not has then
		has = _sys:fileExist(self:GetSoundFilePath(fileName), true);
	end
	return has;
end