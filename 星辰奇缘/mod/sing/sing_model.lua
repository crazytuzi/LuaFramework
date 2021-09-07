-- ------------------------------
-- 歌唱比赛
-- hosr
-- 2016-07-14
-- ------------------------------

SingModel = SingModel or BaseClass(BaseModel)

function SingModel:__init()
    -- 自己录制操作，所需的存储路径
    self.wavFilePath = string.format("%s/speech.wav", Application.persistentDataPath)
    self.spxFilePath = string.format("%s/song/song.spx", Application.persistentDataPath)
    self.tmpfile = string.format("%s/song/song.pcm", Application.temporaryCachePath)

    self.mainWindow = nil
    self.signupWindow = nil
    self.advertWindow = nil

    self.timeId = nil
    self.recordTime = 0

    -- self:GetLocalAll()

    self.tempBGM = false
    self.tempBtn = false
    self.tempNpc = false
    self.tempCombat = false
    self.tempCombatHit = false

    self.playCallback = nil
    self.advertTabToday = nil

    self.currplaydata = nil
    self.currtimer = nil

    self.dialList = {20, 40, 60, 80, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 9999}
    math.randomseed(BaseUtils.BASE_TIME)
end

function SingModel:OpenMain(args)
    if self.mainWindow == nil then
        self.mainWindow = SingMainWindow.New(self)
    end
    self.mainWindow:Open(args)
end

function SingModel:CloseMain()
    if self.mainWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWindow)
    end
    self.mainWindow = nil
end

function SingModel:OpenSignup(args)
    local status = SingManager.Instance.activeState
    -- print(status)
    if status > 5 then
        if SingManager.Instance.isRiseRank == 1 then
            if RoleManager.Instance.RoleData.lev >= 40 then
                if self.signupWindow == nil then
                    self.signupWindow = SingSignupWindow.New(self)
                end
                self.signupWindow:Open(args)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("等级需要到达40级，才能报名好声音哦{face_1,3}"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你没有获得参加入围赛的资格，无法进行报名"))
        end
    elseif status > 1 and status < 5 then
        if RoleManager.Instance.RoleData.lev >= 40 then
            if self.signupWindow == nil then
                self.signupWindow = SingSignupWindow.New(self)
            end
            self.signupWindow:Open(args)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("等级需要到达40级，才能报名好声音哦{face_1,3}"))
        end
    elseif status == 5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("预赛活动已结束，请等待入围赛开始"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("好声音尚未开始"))
    end
end

function SingModel:CloseSignup()
    if SingManager.Instance.songRecording then
        self:StopRecord()
    end
    if self.signupWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.signupWindow)
    end
    self.signupWindow = nil
end

function SingModel:OpenAdvert(args)
    if self.advertWindow == nil then
        self.advertWindow = SingAdvertWindow.New(self)
        self.advertWindow:Open(args)
    end
end

function SingModel:UpdateAdvertHistory(list)
    if self.advertWindow ~= nil then
        self.advertWindow:UpdateHistory(list)
    end
end

function SingModel:CloseAdvert()
    if self.advertWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.advertWindow)
    end
    self.advertWindow = nil
end

function SingModel:Setting()
    self.speech = ChatManager.Instance.model.speech
end

function SingModel:StartRecord()
    if self.speech == nil then
        self:Setting()
    end
    SingManager.Instance.songRecording = true
    self.recordTime = 0
    self:StopTimeCount()
    self:TimeCount()
    self:BeforeSing()
    self.speech:StartRecord()
end

function SingModel:StopRecord()
    if self.speech == nil then
        self:Setting()
    end
    self:StopTimeCount()
    local audioclip = self.speech:EndRecord(false)
    if audioclip == nil then
        if SingManager.Instance.songRecording then
            SingManager.Instance.songRecording = false
            self:AfterSing()
        end
        return
    end

    local wav = Utils.ReadBytesPath(self.wavFilePath)
    Log.Debug(string.format("wav原始数据长度: %s kb", (wav.Length / 1024)))
    -- 压缩产生广播用的数据
    local spx = self.speech:Compress(self.wavFilePath, self.spxFilePath)
    Log.Debug(string.format("压缩后数据长度spx: %s kb", (spx.Length / 1024)))
    SingManager.Instance.mySongClip = audioclip
    SingManager.Instance.mySongSpx = spx
    if SingManager.Instance.songRecording then
        SingManager.Instance.songRecording = false
        self:AfterSing()
    end
end

function SingModel:CancelRecord()
    if self.speech == nil then
        self:Setting()
    end
    SingManager.Instance.songRecording = false
    self.speech:Cancel()
    self:AfterSing()
end

function SingModel:PlaySong(singData, isrank)
    SoundManager.Instance:StopChat()
    local key = string.format("%s_%s_%s", singData.rid, singData.platform, singData.zone_id)
    if isrank then
        key = string.format("%s_r", key)
    end
    local cacheData = SingManager.Instance.cached[key]
    if cacheData ~= nil then
        if cacheData.update_time < singData.update_time then
            print("本地文件落后服务器，重新请求")
            if isrank then
                SingManager.Instance:Send16815(singData.rid, singData.platform, singData.zone_id)
            else
                SingManager.Instance:Send16802(singData.rid, singData.platform, singData.zone_id)
            end
            return
        end
        self:BeforeSing()
        SingManager.Instance.songPlaying = true
        if cacheData.clip == nil then
            cacheData.clip = self:GetLocal(cacheData.file)
        end
        if cacheData.clip ~= nil then
            if self.currplaydata ~= nil and self.currtimer ~= nil then
                EventMgr.Instance:Fire(event_name.sing_playing_status, self.currplaydata, false)
                LuaTimer.Delete(self.currtimer)
                self.currtimer = nil
                self.currplaydata = nil
                self.currtimer = nil
            end
            self.currplaydata = singData
            self.currtimer = LuaTimer.Add(cacheData.clip.length*1000, function()
                if self.currplaydata.rid == singData.rid and self.currplaydata.platform == singData.platform and self.currplaydata.zone_id == singData.zone_id then
                    EventMgr.Instance:Fire(event_name.sing_playing_status, self.currplaydata, false)
                    self.currtimer = nil
                end
            end)
            EventMgr.Instance:Fire(event_name.sing_playing_status, self.currplaydata, true)
            SoundManager.Instance:PlayChat(cacheData.clip)
        else
            print("clip是空的")
        end
        if self.playCallback ~= nil then
            self.playCallback()
            self.playCallback = nil
        end
    else
        if isrank then
            SingManager.Instance:Send16815(singData.rid, singData.platform, singData.zone_id)
        else
            SingManager.Instance:Send16802(singData.rid, singData.platform, singData.zone_id)
        end
    end
end

function SingModel:PlayClip(clip)
    self:BeforeSing()
    SingManager.Instance.songPlaying = true
    SoundManager.Instance:PlayChat(clip)
    if self.playCallback ~= nil then
        self.playCallback()
        self.playCallback = nil
    end
end

function SingModel:StopSong()
    SoundManager.Instance:StopChat()
    if self.currplaydata ~= nil and self.currtimer ~= nil then
        EventMgr.Instance:Fire(event_name.sing_playing_status, self.currplaydata, false)
        LuaTimer.Delete(self.currtimer)
        self.currtimer = nil
        self.currplaydata = nil
        self.currtimer = nil
    end

    if SingManager.Instance.songPlaying then
        self:AfterSing()
    end
    SingManager.Instance.songPlaying = false
end

function SingModel:GetAudioClip(voiceData)
    if self.speech == nil then
        self:Setting()
    end
    if self.speech ~= nil and voiceData ~= nil then
        return self.speech:GetAudioClip(voiceData)
    end
    return nil
end

-- 重连清空
function SingModel:Clear()
    self:InitMuteState()
    self:StopSong()
    self:StopRecord()
    self:StopTimeCount()
end

function SingModel:StopTimeCount()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
    end
    self.timeId = nil
end

-- 记录录音时间
function SingModel:TimeCount()
    self:StopTimeCount()
    self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function SingModel:Loop()
    self.recordTime = self.recordTime + 1
end

-- 本地存储
-- self.wavFilePath = string.format("%s/speech.wav", Application.persistentDataPath)
-- self.spxFilePath = string.format("%s/speech.spx", Application.persistentDataPath)
-- self.tmpfile = string.format("%s/tmp.pcm", Application.temporaryCachePath)
function SingModel:LocalSave(songData, name, update_time)
    if Application.platform ~= RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.Android then
        return
    end

    if songData == nil or name == nil or update_time == nil then
        return
    end
    PlayerPrefs.SetString(name, update_time)
    local path = string.format("%s/song/%s.spx", Application.persistentDataPath, name)
    -- 把协议数据写到本地缓存
    Utils.WriteBytesPath(songData, path)
    local str = ""
    for name,v in pairs(SingManager.Instance.cached) do
        str = string.format("%s|%s", str, name)
    end
    PlayerPrefs.SetString("song", str)
end

-- local name = string.format("song_%s_%s_%s_%s", "rid", "platform", "zoneid", "update_time")
-- local path = string.format("%s/song/%s.spx", Application.persistentDataPath, name)
function SingModel:GetLocal(path)
    if self.speech == nil then
        self:Setting()
    end
    local tmp = string.format("%s/tmp.pcm", Application.temporaryCachePath)
    local pcm = self.speech:DeCompress(path, tmp)
    if pcm ~= nil then
        local audioclip = self.speech:PcmToAudioClip(pcm)
        pcm = nil
        return audioclip
    end
    return nil
end

function SingModel:GetLocalAll()
    if Application.platform ~= RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.Android then
        return
    end

    local localPath = string.format("%s/song", Application.persistentDataPath)
    local f = io.open(localPath, 'r')
    if f == nil then
        if Application.platform == RuntimePlatform.WindowsPlayer then
            -- os.execute("mkdir \"" .. localPath.."\"")
            Utils.CreateDirectoryStatic(localPath)
        elseif Application.platform == RuntimePlatform.Android then
            if BaseUtils.CSVersionToNum() <= 10101 then
                Utils():CreateDirectory(localPath)
            else
                Utils.CreateDirectoryStatic(localPath)
            end
        elseif Application.platform == RuntimePlatform.IPhonePlayer then
            if BaseUtils.CSVersionToNum() <= 10101 then
                Utils():CreateDirectory(localPath)
            else
                Utils.CreateDirectoryStatic(localPath)
            end
        else
            os.execute("mkdir \"" .. localPath.."\"")
        end
    else
        f:close()
    end

    local str = PlayerPrefs.GetString("song")
    -- print(string.format("声音缓存=>song=%s", str))
    if str ~= "" then
        local list = BaseUtils.split(str, "|")
        for i,fileName in ipairs(list) do
            if fileName ~= "" then
                local file = string.format("%s/%s.spx", localPath, fileName)
                local args = BaseUtils.split(fileName, "_")
                local name = string.format("%s_%s_%s", args[1], args[2], args[3])
                local update_time = tonumber(PlayerPrefs.GetString(name)) or 0
                SingManager.Instance.cached[name] = {clip = nil, update_time = update_time, file = file}
            end
        end
    end
end

function SingModel:ClearAllLoaclFile()
    local path = string.format("%s/song", Application.persistentDataPath)
    local f = io.open(path, 'r')
    if f ~= nil then
        f:close()
        BaseUtils.ClearFloder(path)
    end
end

function SingModel:BeforeSing()
    if SingManager.Instance.songPlaying then
        return
    end

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

    self.tempSys = self.speech.speech:GetPlayerVolume()
    LuaTimer.Add(300, function() self.speech.speech:SetPlayerVolume(80) end)
end

function SingModel:AfterSing()
    SoundManager.Instance.playerList[AudioSourceType.BGM]:SetMute(self.tempBGM)
    SoundManager.Instance.playerList[AudioSourceType.UI]:SetMute(self.tempBtn)
    SoundManager.Instance.playerList[AudioSourceType.NPC]:SetMute(self.tempNpc)
    SoundManager.Instance.playerList[AudioSourceType.Combat]:SetMute(self.tempCombat)
    SoundManager.Instance.playerList[AudioSourceType.CombatHit]:SetMute(self.tempCombatHit)

    if self.speech == nil then
        self:Setting()
    end
    self.speech.speech:SetPlayerVolume(self.tempSys)
end

function SingModel:UpdateSignUp()
    if self.signupWindow ~= nil then
        self.signupWindow:UpdateState()
    end
end

function SingModel:UpdateMainInfo()
    if self.mainWindow ~= nil and self.mainWindow.isOpen then
        self.mainWindow:OnRefresh()
    end
end

function SingModel:InitMuteState()
    local playerList = SoundManager.Instance.playerList
    self.tempBGM = playerList[AudioSourceType.BGM].isMute
    self.tempBtn = playerList[AudioSourceType.UI].isMute
    self.tempNpc = playerList[AudioSourceType.NPC].isMute
    self.tempCombat = playerList[AudioSourceType.Combat].isMute
    self.tempCombatHit = playerList[AudioSourceType.CombatHit].isMute
end

function SingModel:OpenTime(args)
    if self.timeWin == nil then
        self.timeWin = SingTimeWindow.New(self)
    end
    self.timeWin:Open(args)
end

function SingModel:CloseTime()
    if self.timeWin ~= nil then
        WindowManager.Instance:CloseWindow(self.timeWin)
        self.timeWin = nil
    end
end

function SingModel:OpenDesc(args)
    if self.descWin == nil then
        self.descWin = SingDescWindow.New(self)
    end
    self.descWin:Open(args)
end

function SingModel:CloseDesc()
    if self.descWin ~= nil then
        WindowManager.Instance:CloseWindow(self.descWin)
        self.descWin = nil
    end
end

function SingModel:OpenMultiItem(parent, info)
    if self.multiItemPanel == nil then
        self.multiItemPanel = MultiItemPanel.New(parent)
    end
    self.multiItemPanel:Show(info)
end

function SingModel:CloseMultiItem()
    if self.multiItemPanel ~= nil then
        self.multiItemPanel:DeleteMe()
        self.multiItemPanel = nil
    end
end

function SingModel:OpenSingRankTypePanel(parent, info)
    if self.singRankTypePanel == nil then
        self.singRankTypePanel = SingRankTypePanel.New(parent)
    end
    self.singRankTypePanel:Show(info)
end

function SingModel:CloseSingRankTypePanel()
    if self.singRankTypePanel ~= nil then
        self.singRankTypePanel:DeleteMe()
        self.singRankTypePanel = nil
    end
end

function SingModel:ShowRankReward(parent)
    local tab = {}
    for k,v in pairs(DataSing.data_rank_reward) do
        local start_time = os.time{year = v.start_time[1][1], month = v.start_time[1][2], day = v.start_time[1][3], hour = v.start_time[1][4], minute = v.start_time[1][5], second = v.start_time[1][6]}
        local end_time = os.time{year = v.end_time[1][1], month = v.end_time[1][2], day = v.end_time[1][3], hour = v.end_time[1][4], minute = v.end_time[1][5], second = v.end_time[1][6]}
        -- if start_time < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= end_time then
            table.insert(tab, v)
        -- end
    end
    table.sort(tab, function(a,b) return a.min_rank < b.min_rank end)

    if #tab > 0 and tab[1].rank_type == 0 then
        local list = {}
        for i,v in ipairs(tab) do
            local items = {}
            for _,item in pairs(v.reward) do
                table.insert(items, {base_id = item[1], num = item[2]})
            end
            table.insert(list, {title = v.title, items = items})
        end
        self:OpenMultiItem(parent, {list = list})
    else
        local list1 = {}
        local list2 = {}
        for i,v in ipairs(tab) do
            local items = {}
            for _,item in pairs(v.reward) do
                table.insert(items, {base_id = item[1], num = item[2]})
            end
            if v.rank_type == 1 then
                table.insert(list1, {title = v.title, items = items})
            else
                table.insert(list2, {title = v.title, items = items})
            end
        end
        self:OpenSingRankTypePanel(parent, { list1 = list1, list2 = list2 })
    end
end

function SingModel:UpdateAdvertList(list)
    self.advertTabToday = {}
    for i,v in ipairs(list) do
        self.advertTabToday[BaseUtils.Key(v.rid, v.platform, v.zone_id)] = 1
    end
    BaseUtils.dump(self.advertTabToday)
    if self.advertWindow ~= nil then
        self.advertWindow:CheckButtonStatus7()
    end
end

function SingModel:GetRandomList(dat, specailCount, length)
    local list0 = {}
    local list1 = {}    -- 本服
    local list2 = {}    -- 其他
    local list3 = {}    -- 结果数组
    local tab = {}
    local len = 0
    local r = 0
    local temp = 0
    -- BaseUtils.dump(dat)
    for _,v in pairs(dat) do
        if SingManager.Instance:IsFollow(BaseUtils.Key(v.rid, v.platform, v.zone_id)) then
            -- table.insert(list, 1, v)
            v.isFollow = 1
        else
            v.isFollow = 0
        end
    end
    if #dat > length then
        for i,v in ipairs(dat) do
            if v.isFollow == 1 then
                table.insert(list0, v)
            elseif BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
                table.insert(list1, v)
            else
                table.insert(list2, v)
            end
        end
        len = #list0
        local i = 1
        while #list3 < length and i <= len do
            -- BaseUtils.dump(list2[tab[i]])
            table.insert(list3, list0[i])
            i = i + 1
        end
        len = #list1
        if len > specailCount then
            for i=1,len do
                tab[i] = i
            end
            local i = 1
            while #list3 < length and i <= len do
                -- BaseUtils.dump(list2[tab[i]])
                r = math.random(i,len)
                temp = tab[i]
                tab[i] = tab[r]
                tab[r] = temp
                table.insert(list3, list1[tab[i]])
                i = i + 1
            end
            for i=specailCount + 1,len do
                table.insert(list2, list1[tab[i]])
            end
        else
            local i = 1
            while #list3 < length and i <= #list1 do
                -- BaseUtils.dump(list2[tab[i]])
                table.insert(list3, list1[i])
                i = i + 1
            end
        end
        tab = {}
        -- len = length - specailCount
        len = #list2
        for i=1,len do
            tab[i] = i
        end
        for i=1,len do
            r = math.random(i,len)
            temp = tab[r]
            tab[r] = tab[i]
            tab[i] = temp
        end
        local i = 1
        while #list3 < length and i <= len do
            -- BaseUtils.dump(list2[tab[i]])
            table.insert(list3, list2[tab[i]])
            i = i + 1
        end
        return list3
    else
        return dat
    end
end
