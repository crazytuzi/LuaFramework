
-- 音频管理
-- @author huangyq
SoundManager = SoundManager or BaseClass()

function SoundManager:__init()
    if SoundManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    SoundManager.Instance = self;

    -- 全局音频侦听器
    self.audioListener = nil

    -- 同一时间应该只有一个bgm
    self.bgmLoader = nil
    self.bgmLoading = false
    self.loadTime = 0

    self.playerList = {}
    self.BGM_Id = nil

    self.effectPath = AssetConfig.sound_effect_path
    self.combatPath = AssetConfig.sound_battle_path

    self.list = {
        AudioSourceType.BGM        -- 背景音乐
        ,AudioSourceType.UI        -- UI音效
        ,AudioSourceType.Combat    -- 战斗音效
        ,AudioSourceType.CombatHit    -- 战斗音效
        ,AudioSourceType.NPC       -- NPC对话
        ,AudioSourceType.Chat      -- 语音
    }

    --游戏音效
    self.volumelist = {
        AudioSourceType.UI        -- UI音效
        ,AudioSourceType.Combat    -- 战斗音效
        ,AudioSourceType.CombatHit    -- 战斗音效
        ,AudioSourceType.NPC       -- NPC对话
    }

    self:InitPlayer()
end

function SoundManager:__delete()
    for _, data in ipairs(self.playerList) do
        data:DeleteMe()
    end
end

function SoundManager:InitPlayer()
    self.audioListener = GameObject.Find("MainCamera"):AddComponent(AudioListener)
    for _, data in ipairs(self.list) do
        local player = SoundPlayer.New(data)
        self.playerList[data] = player
    end
end

function SoundManager:PlayBGM(soundId)
    -- 后面那个时间是保险
    if self.bgmLoading and (Time.time - self.loadTime) < 60 then
        return
    end

    if SubpackageManager.Instance.IsSubPackage then
        local soundPath = string.format("prefabs/sound/bgm/%s.unity3d", soundId)
        if SubpackageManager.Instance:HaveSubpackageFileSingle(soundPath) then
            soundId = 403
        end
    end

    if self.BGM_Id == soundId then
        return
    end

    if self.bgmLoader ~= nil then
        self.bgmLoader:DeleteMe()
        self.bgmLoader = nil
    end
    local callback = function(soundId, clip)
        self.bgmLoading = false
        self:OnBgmLoadCompleted(soundId, clip)
    end
    self.bgmLoading = true
    self.loadTime = Time.time
    self.BGM_Id = soundId
    self.bgmLoader = SoundLoader.New(soundId, callback)
end

function SoundManager:OnBgmLoadCompleted(soundId, clip)
    local player = self.playerList[AudioSourceType.BGM]
    -- player:SetClip(clip)
    player:Play(clip)
end

function SoundManager:Play(soundId, single)
    local audioType = AudioSourceType.UI
    if soundId >= 500 and soundId <= 699 then
        audioType = AudioSourceType.NPC
    end
    local player = self.playerList[audioType]
    local clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_effect_path, tostring(soundId))
    -- player:SetClip(clip)
    player:Play(clip, single)
end
function SoundManager:StopId(soundId)
    local audioType = AudioSourceType.UI
    if soundId >= 500 and soundId <= 699 then
        audioType = AudioSourceType.NPC
    end
    local player = self.playerList[audioType]
    if player ~= nil then
        player:StopId(soundId)
    end
end

function SoundManager:PlayCombat(soundId, single)
    local player = self.playerList[AudioSourceType.UI]
    local clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_battle_path, tostring(soundId))
    if clip == nil then
        clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_effect_path, tostring(soundId))
    end
    -- player:SetClip(clip)
    player:Play(clip, single)
end

function SoundManager:PlayCombatChat(soundId, single)
    local player = self.playerList[AudioSourceType.NPC]
    local clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_battle_path, tostring(soundId))
    if clip == nil then
        clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_effect_path, tostring(soundId))

    end
    -- player:SetClip(clip)
    player:Play(clip, single)
end

function SoundManager:PlayCombatHiter(soundId, single)
    local player = self.playerList[AudioSourceType.Combat]
    local clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_effect_path, tostring(soundId))
    -- player:SetClip(clip)
    player:Play(clip, single)
end

function SoundManager:PlayCombatHit(soundId, single)
    local player = self.playerList[AudioSourceType.CombatHit]
    local clip = PreloadManager.Instance:GetSubAsset(AssetConfig.sound_effect_path, tostring(soundId))
    -- player:SetClip(clip)
    player:Play(clip, single)
end

function SoundManager:PlayChat(clip, single)
    local player = self.playerList[AudioSourceType.Chat]
    -- player:SetClip(clip)
    player:Play(clip, single)
end

function SoundManager:StopChat()
    local player = self.playerList[AudioSourceType.Chat]
    player:Stop()
end

function SoundManager:IsChatPlaying()
    local player = self.playerList[AudioSourceType.Chat]
    return player:IsPlaying()
end

-- 设置音量
-- volume = 0 ~ 1
function SoundManager:SetAllVolume(volume)
    for _, data in ipairs(self.list) do
        self.playerList[data]:SetVolume(volume)
    end
end

-- 静音
-- mute = true | false
function SoundManager:SetAllMute(mute)
    for _, data in ipairs(self.list) do
        self.playerList[data]:SetMute(mute)
    end
end

--设置音乐音量
function SoundManager:SetMusicValue(value)
    self.playerList[AudioSourceType.BGM]:SetVolume(value)
end

--音乐开关
function SoundManager:SetMusicIsCan(bo)
    self.playerList[AudioSourceType.BGM]:SetMute(not bo)
end

--设置音效音量
function SoundManager:SetVolumeValue(value)
    for i,v in ipairs(self.volumelist) do
        self.playerList[v]:SetVolume(value)
    end
end

--音效开关
function SoundManager:SetVolumeIsCan(bo)
    for i,v in ipairs(self.volumelist) do
        self.playerList[v]:SetMute(not bo)
    end
end

-- 语音音量
function SoundManager:SetChatVolumeValue(value)
    self.playerList[AudioSourceType.Chat]:SetVolume(value)
end

function SoundManager:OnWakeUp()
    for _, data in ipairs(self.list) do
        self.playerList[data]:OnWakeUp()
    end
end

function SoundManager:OnSleep()
    for _, data in ipairs(self.list) do
        self.playerList[data]:OnSleep()
    end
end
