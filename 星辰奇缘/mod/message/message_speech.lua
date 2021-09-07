-- ------------------------------------------
-- 语音消息管理
-- hosr
-- ------------------------------------------
MsgSpeech = MsgSpeech or BaseClass()

function MsgSpeech:__init(model, callback)
    self.model = model
    self.callback = callback

    self.wavFilePath = string.format("%s/speech.wav", Application.persistentDataPath)
    self.spxFilePath = string.format("%s/speech.spx", Application.persistentDataPath)
    self.tmpfile = string.format("%s/tmp.pcm", Application.temporaryCachePath)

    self.speech = Speech.Init(ctx.MainCamera.gameObject.transform, function(msg) self:ReceiveText(msg) end)
    self.audioclip = nil

    -- 记录默认音量
    self.tempBGM = false
    self.tempBtn = false
    self.tempNpc = false
    self.tempCombat = false
    self.tempCombatHit = false
    self.tempSys = 0

    -- ios审核处理
    if BaseUtils.IsIPhonePlayer() and not BaseUtils.IsVerify and CSVersion.Version > "2.8.1" then
        self.speech:Init_IOS()
    end
end

function MsgSpeech:__delete()
end

-- 接收翻译结果
function MsgSpeech:ReceiveText(msg)
    if self.callback ~= nil then
        self.callback(msg)
    end
end

-- 取消录音
function MsgSpeech:Cancel()
    self.speech:Cancel()
end

-- 开始录音
function MsgSpeech:StartRecord()
    self.speech:Begin()
end

-- 结束录音
function MsgSpeech:EndRecord(recongnize)
    if recongnize == nil then
        recongnize = true
    end
    local audioclip = self.speech:End(recongnize)

    if audioclip == nil then
        -- Log.Error("录音失败")
        return nil
    end

    -- local wav = Utils.ReadBytesPath(self.wavFilePath)
    -- Log.Debug(string.format("wav原始数据长度: %s kb", (wav.Length / 1024)))
    return audioclip
end

-- 压缩。广播此压缩文件
function MsgSpeech:Compress(wavFilePath, spxFilePath)
    if self.compressing then
        return
    end

    if wavFilePath == nil then
        wavFilePath = self.wavFilePath
    end

    if spxFilePath == nil then
        spxFilePath = self.spxFilePath
    end

    self.compressing = true
    if not self.speech:CompressAudio(wavFilePath, spxFilePath) then
        Log.Error(string.format("编码wav文件为speex格式失败: %s", wavFilePath))
        self.compressing = false
        return nil
    end
    local spx = Utils.ReadBytesPath(spxFilePath)
    Log.Debug(string.format("编码为speex格式后数据长度: %s kb", (spx.Length / 1024)))
    self.compressing = false
    return spx
end

-- 解压。收到广播的压缩文件，解压成可播放音源
function MsgSpeech:DeCompress(spxFilePath, tmpfile)
    if spxFilePath == nil then
        spxFilePath = self.spxFilePath
    end

    if tmpfile == nil then
        tmpfile = self.tmpfile
    end

    if not self.speech:DecompressAudio(spxFilePath, tmpfile) then
        -- Log.Error("解码speex文件为pcm格式失败")
        return nil
    end
    local pcm = Utils.ReadBytesPath(tmpfile)
    Log.Debug(string.format("解码为PCM格式后数据长度: %s kb", (pcm.Length / 1024)))
    return pcm
end

function MsgSpeech:PcmToAudioClip(pcm)
    if pcm ~= nil then
        local audioclip = self.speech:PcmToAudioClip(pcm)
        return audioclip
    end
    return nil
end

function MsgSpeech:GetAudioClip(voice)
    if self.decompressing then
        return
    end
    self.decompressing = true
    Utils.WriteBytesPath(voice, self.spxFilePath)
    local pcm = self:DeCompress()
    if pcm == nil then
        return nil
    end
    local audioclip = self:PcmToAudioClip(pcm)

    pcm = nil
    self.decompressing = false
    return audioclip
end

-- 播放前
-- 1.背景音乐调小
-- 2.语音播放音量调大,(默认值)
-- 3.或者把系统音量调大
function MsgSpeech:BeforePlay()
    self.tempBGM = SoundManager.Instance.playerList[AudioSourceType.BGM].isMute
    self.tempBtn = SoundManager.Instance.playerList[AudioSourceType.UI].isMute
    self.tempNpc = SoundManager.Instance.playerList[AudioSourceType.NPC].isMute
    self.tempCombat = SoundManager.Instance.playerList[AudioSourceType.Combat].isMute
    self.tempCombatHit = SoundManager.Instance.playerList[AudioSourceType.CombatHit].isMute

    SoundManager.Instance.playerList[AudioSourceType.BGM]:SetMute(true)
    SoundManager.Instance.playerList[AudioSourceType.UI]:SetMute(true)
    SoundManager.Instance.playerList[AudioSourceType.NPC]:SetMute(true)
    SoundManager.Instance.playerList[AudioSourceType.Combat]:SetMute(true)
    SoundManager.Instance.playerList[AudioSourceType.CombatHit]:SetMute(true)


    if Application.platform == RuntimePlatform.Android then
        self.tempSys = self.speech:GetPlayerVolumeRaw()
        LuaTimer.Add(300, function() self.speech:SetPlayerVolume(80) end)
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        self.tempSys = self.speech:GetPlayerVolume()
        LuaTimer.Add(300, function() self.speech:SetPlayerVolume(80) end)
    end
end

-- 播放后
-- 1.背景音乐还原
-- 2.把系统音量还原
function MsgSpeech:AfterPlay()
    SoundManager.Instance.playerList[AudioSourceType.BGM]:SetMute(self.tempBGM)
    SoundManager.Instance.playerList[AudioSourceType.UI]:SetMute(self.tempBtn)
    SoundManager.Instance.playerList[AudioSourceType.NPC]:SetMute(self.tempNpc)
    SoundManager.Instance.playerList[AudioSourceType.Combat]:SetMute(self.tempCombat)
    SoundManager.Instance.playerList[AudioSourceType.CombatHit]:SetMute(self.tempCombatHit)

    if Application.platform == RuntimePlatform.Android then
        self.speech:SetPlayerVolumeRaw(self.tempSys)
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        self.speech:SetPlayerVolume(self.tempSys)
    end
end

-- 判断系统音量是否为0
function MsgSpeech:IsMute()
    local val = 0
    if Application.platform == RuntimePlatform.Android then
        val = self.speech:GetPlayerVolumeRaw()
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        val = self.speech:GetPlayerVolume()
    end
    Log.Debug(string.format("当前音量＝%s", val))
    return (val == 0)
end