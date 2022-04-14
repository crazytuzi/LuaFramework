SoundManager = SoundManager or class("SoundManager", BaseManager)
local this = SoundManager


function SoundManager:ctor()
    SoundManager.Instance = self

    self.durTime = 0.7
    
    self.sounds = {}
    local transform = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.GameManager)
    self.audio_source = transform.gameObject:AddComponent(typeof(AudioSource))
    self.eff_source = transform.gameObject:AddComponent(typeof(AudioSource))
    self:SetDefult()

    self:Reset()
    self:AddEvent()
end

function SoundManager:Reset()
end

function SoundManager:AddEvent()
   -- GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))
    local function call_back(sceneId)
        local db = Config.db_scene[sceneId]
        if db then
            local soundId = tonumber(db.backg_music)
           -- self:PlayBackGround("backsound",soundName)
            self:PlayById(soundId)
        end
    end
    GlobalEvent:AddListener(EventName.ChangeSceneStart,call_back)


end

--function SoundManager:Test(keyCode)
--    if keyCode == InputManager.KeyCode.C then
--        self:PlayEff("effectsound","test3")
--    end
--end

function SoundManager.GetInstance()
    if SoundManager.Instance == nil then
        SoundManager()
    end
    return SoundManager.Instance
end

function SoundManager:Get(abName,soundName,loadBack)
    if not self.sounds[soundName] then
        local function callBack(obj)
            if obj then
                self.sounds[soundName] = obj[0]
                loadBack(self.sounds[soundName])
            end
        end
        lua_resMgr:LoasSound(self,abName,soundName,callBack)
    else
        loadBack(self.sounds[soundName])
    end
end

function SoundManager:LoadAll()

end

function SoundManager:SetDefult()
    self.eff_source.volume = CacheManager:GetInstance():GetFloat("effVolume",0.5)
    self.audio_source.volume = CacheManager:GetInstance():GetFloat("BackGroundVolume",0.5)
    self.audio_source.mute = CacheManager:GetInstance():GetInt("BackGroundOnOrOff",1) == 0
    self.eff_source.mute = CacheManager:GetInstance():GetInt("effOnOrOff",1) == 0
end



--播放背景音乐
function SoundManager:PlayBackGround(abName,assetName)
    if string.isempty(assetName) then
        return
    end
    local function call_back(clip)
        if clip == nil then
            return
        end
            if self.audio_source.isPlaying then  --有背景音乐播放 淡出淡入
                local curVol = self.audio_source.volume
                local action = cc.ValueTo(self.durTime,0,self.audio_source,"volume")
                local function end_call_bacl()
                    self.audio_source.loop = true
                    self.audio_source.clip = clip
                    self.audio_source:Play()
                    self.audio_source.volume = 0
                    local action1 = cc.ValueTo(self.durTime,curVol,self.audio_source,"volume")
                    cc.ActionManager:GetInstance():addAction(action1,self.audio_source)
                end
                local endAction =  cc.CallFunc(end_call_bacl)
                action = cc.Sequence(action,endAction)
                cc.ActionManager:GetInstance():addAction(action,self.audio_source)

            else   --无背景音乐  淡入'
                local curVol = self.audio_source.volume
                self.audio_source.volume = 0
                local action = cc.ValueTo(self.durTime,curVol,self.audio_source,"volume")
                cc.ActionManager:GetInstance():addAction(action,self.audio_source)
                self.audio_source.loop = true
                self.audio_source.clip = clip
                self.audio_source:Play()
            end
    end
    self:Get(abName,assetName,call_back)
end

function SoundManager:PlaySeceneSound()
    local sceneId = SceneManager:GetInstance():GetSceneId()
    local db  = Config.db_scene[sceneId]
    if db then
        local soundName = db.backg_music
        self:PlayBackGround("backsound",soundName)
    end
end

--播放音效
function SoundManager:PlayEff(abName,assetName,isStop)
    local function call_back(clip)
        if clip == nil then
            return
        end
        if isStop == 2 then
            self.eff_source:PlayOneShot(clip)
        else
            self:Pause()
            self.eff_source:PlayOneShot(clip)
            self.clipLen = clip.length
            self.schedule = GlobalSchedule:Start(handler(self, self.StartCount), Time.deltaTime, -1);
        end
      --  print2(clip.length)
    end
    self:Get(abName,assetName,call_back)
end

function SoundManager:StartCount()
    self.clipLen = self.clipLen - Time.deltaTime
    if  self.clipLen <= 0 then
        if not self.audio_source.isPlaying  then
            self.audio_source:Play()
        end
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
    end
end


function SoundManager:SetBackGroundMute(flag)
    self.audio_source.mute = flag
end


--设置背景音乐大小
function SoundManager:SetBackGroundVolume(vol)
    CacheManager:GetInstance():SetFloat("BackGroundVolume",vol)
    self.audio_source.volume = vol
    if self.audio_source.volume <= 0.1 then
        self.audio_source.mute = true
    else
        self.audio_source.mute = false
    end
end
function SoundManager:GetBackGroundVolume()
    return self.audio_source.volume
end
--设置音效大小
function SoundManager:SetEffVolume(vol)
    CacheManager:GetInstance():SetFloat("effVolume",vol)
    self.eff_source.volume = vol
    if self.eff_source.volume <= 0.1 then
        self.eff_source.mute = true
    else
        self.eff_source.mute = false
    end
end
function SoundManager:GetEffVolume()
    return self.eff_source.volume
end
--设置音量开关
function SoundManager:SetBackGroundOnOrOff(bool)
    local index = 1
    if bool then
        index = 0
    end
    CacheManager:GetInstance():SetInt("BackGroundOnOrOff",index)  --静音是0

    self.audio_source.mute = bool --true 静音 
end

function SoundManager:GetBackGroundOnOrOff()
    return  self.audio_source.mute
end

--设置音效开关
function SoundManager:SetEffOnOrOff(bool)
    local index = 1
    if bool then
        index = 0
    end
    CacheManager:GetInstance():SetInt("effOnOrOff",index)  --静音是0
    self.eff_source.mute = bool --true 静音
end

function SoundManager:GetEffOnOrOff()
    return  self.eff_source.mute
end

function SoundManager:StopEffectSound()
    self.eff_source:Stop()
end


function SoundManager:Stop()
    if  self.audio_source.isPlaying then
        self.audio_source:Stop()
    end
end

function SoundManager:Pause()
    if  self.audio_source.isPlaying then
        self.audio_source:Pause()
    end
end



function SoundManager:PlayById(id)
    local cf = Config.db_music_type[id]
    if not cf then
        logError("音乐配置不存在，id是：",id)
    end
    local abName = cf.bag_name
    local assetName = cf.music_name
    local isStop = cf.isstop
    if cf.music_type == 1 then
        self:PlayBackGround(abName,assetName)
    else
        self:PlayEff(abName,assetName,cf.isstop)
    end
end

-- 跑步特效
function SoundManager:RunEff(is_mount)
    do
        return
    end
    local off_time =  SceneConstant.RunSoundEffTime.Run
    if is_mount then
        off_time = 1.0
    end
    if self.last_play_run_eff_time and Time.time - self.last_play_run_eff_time  <= off_time then
        return
    end
    self.last_play_run_eff_time = Time.time
    if is_mount then
        self:PlayById(41)
    else
        self:PlayById(40)
    end
end