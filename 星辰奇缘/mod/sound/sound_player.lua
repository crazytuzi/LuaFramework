-- 音源
-- @author huangyq
SoundPlayer = SoundPlayer or BaseClass()

function SoundPlayer:__init(audioType)
    self.audioType = audioType
    self.gameObject = nil
    self.audioSource = nil
    self.PlayerList = {}

    -- 用于判断是否覆盖播放
    self.priLevel = 5
    self.startTime = 0
    self.clipLenth = 0

    self.isMute = false
    self.maxNum = 10
    self.oldVolume = 0.5
    -- 重复标志，重复播放跳过
    self.isrepeat = false
    self:Init()
end

function SoundPlayer:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
end

function SoundPlayer:Init()
    self.gameObject = GameObject("SoundPlayer" .. self.audioType)
    self.gameObject.transform:SetParent(GameObject.Find("MainCamera").transform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.audioSource = self.gameObject:AddComponent(AudioSource)
    self.oldVolume = self.audioSource.volume
    table.insert(self.PlayerList, self.audioSource)
    self:Reset()
end

-- 当前音频剪辑
function SoundPlayer:SetClip(clip)
    -- if clip ~= nil and not BaseUtils.is_null(self.audioSource) and not BaseUtils.is_null(self.audioSource.clip) then
    --     if self.audioSource.isPlaying and self.audioSource.clip.name == clip.name then
    --         self.isrepeat = true
    --         return
    --     end
    -- end
    -- local done = false
    -- for k, player in pairs(self.PlayerList) do
    --     print(k,v)
    -- end
    -- self.isrepeat = false
    -- self.audioSource.clip = clip
    -- end
end
function SoundPlayer:GetClip()
    return self.PlayerList[1].clip
end

function SoundPlayer:StopId(id)
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) and not BaseUtils.is_null(player.clip) then
            if tostring(id) == player.clip.name then
                player:Stop()
            end
        end
    end
end

-- 音量
function SoundPlayer:SetVolume(volume)
    if self.audioType == AudioSourceType.Combat then
        if volume > 0 then
            volume = volume * 0.6
        end
    end
    self.oldVolume = volume
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player.volume = volume
        end
    end
end

function SoundPlayer:GetVolume()
    return self.PlayerList[1].volume
end

-- 静音
function SoundPlayer:SetMute(mute)
    self.isMute = mute
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player.mute = mute
        end
    end
end

-- 播放
function SoundPlayer:Play(clip, single)
    if self.audioType == AudioSourceType.BGM or self.audioType == AudioSourceType.Chat or single then
        self.audioSource.clip = clip
        self.audioSource:Play()
        return
    end
    local done = false
    if clip ~= nil then
        for k, player in pairs(self.PlayerList) do
            if not BaseUtils.is_null(player) and not player.isPlaying then
                player.clip = clip
                player:Play()
                done = true
                return
            end
        end
    end
    if clip ~= nil and not done then
        if #self.PlayerList < self.maxNum then
            self:AddNewPlayer(clip)
        else
            self.audioSource.clip = clip
            self.audioSource:Play()
        end
    end
end

function SoundPlayer:IsPlaying()
    return self.audioSource.isPlaying
end
-- 暂停
function SoundPlayer:Pause()
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player:Pause()
        end
    end
end

-- 停止
function SoundPlayer:Stop()
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player:Stop()
        end
    end
end

-- 重置
function SoundPlayer:Reset()
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player.playOnAwake = false
            player.volume = 0.5
            player.loop = self.audioType == AudioSourceType.BGM
        end
    end

end

function SoundPlayer:OnWakeUp()
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            player.volume = self.oldVolume
        end
    end
    -- self.audioSource.volume = self.oldVolume
end

function SoundPlayer:OnSleep()
    self.oldVolume = self.PlayerList[1].volume
    -- if self.oldVolume > 0.1 then
    --     self.audioSource.volume = 0.1
    -- end
    for k, player in pairs(self.PlayerList) do
        if not BaseUtils.is_null(player) then
            if player.volume > 0.1 then
                player.volume = 0.1
            end
        end
    end
end

function SoundPlayer:AddNewPlayer(clip)
    local player = GameObject("SoundPlayer" .. self.audioType)
    player.transform:SetParent(GameObject.Find("MainCamera").transform)
    player.transform.localPosition = Vector3.zero
    local audioSource = player:AddComponent(AudioSource)
    audioSource.volume = self.audioSource.volume
    audioSource.playOnAwake = self.audioSource.playOnAwake
    audioSource.volume = self.audioSource.volume
    audioSource.mute = self.audioSource.mute
    audioSource.loop = self.audioSource.loop
    table.insert(self.PlayerList, audioSource)
    if clip ~= nil then
        audioSource.clip = clip
        audioSource:Play()
    end
end