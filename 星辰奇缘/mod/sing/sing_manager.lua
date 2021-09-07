-- ---------------------------------------------
-- 歌唱比赛
-- hosr
-- 2016-07-14
-- ---------------------------------------------
SingManager = SingManager or BaseClass(BaseManager)

function SingManager:__init()
    if SingManager.Instance then
        return
    end
    SingManager.Instance = self
    self:InitHandler()

    self.model = SingModel.New()

    -- 活动状态
    self.activeState = SingEumn.ActiveState.Close
    -- 录制歌唱中
    self.songRecording = false
    -- 播放歌唱中
    self.songPlaying = false
    -- 关注列表
    self.follow = {}
    -- 当前参赛的歌曲列表
    self.songList = {}
    -- 本地缓存
    self.cached = {}
    -- 我的提交id
    self.mySongId = 0
    -- 我的简介
    self.mySongDesc = ""
    -- 我的时长
    self.mySongTime = 0
    -- 我的更新时间
    self.mySongUpdate = 0
    -- 我的好评数
    self.mySongLiked = 0
    -- 我的播放数
    self.mySongPlay = 0
    -- 我的音频文件
    self.mySongClip = nil
    -- 我的音频文件压缩后
    self.mySongSpx = nil
    -- 缓存打开界面参数
    self.openArgs = nil

    self.isInit = false
    -- 排行榜数据
    self.rankList = {}

    -- 是否晋级
    self.isRiseRank = false

    -- 当前显示
    self.currentShowKey = ""
    -- 当前播放
    self.currentPlayKey = ""
    self.tempsummary = ""
end

function SingManager:RequestInitData()
    self.currentShowKey = ""
    self.currentPlayKey = ""
    self.isInit = false
    self.model:Clear()
    self.songRecording = false
    self.songPlaying = false
    self.isRiseRank = false
    self.songList = {}
    self.follow = {}
    self:Send16801()
    self:Send16803()
    self:Send16809()
    -- self:Send16813()
end

-- 外部判断状态用
-- singing=true，不播放语音或其他音乐
function SingManager:Singing()
    return self.songRecording or self.songPlaying
end

function SingManager:GetOrderList(isShow)
    local list = {}
    local aList = nil
    if isShow then
        aList = self.showList
    else
        aList = self.songList
    end

    for k,v in pairs(aList) do
        local _,v2 = self:ShowLiked(v.liked)
        v.likedLevel = v2
        table.insert(list, v)
    end

    -- if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
        table.sort(list, function(a,b)
            if a.isFollow == b.isFollow then
                return a.likedLevel > b.likedLevel
            else
                return a.isFollow > b.isFollow
            end
        end)
    -- end

    return list
end

-- 是否关注
function SingManager:IsFollow(key)
    if self.follow[key] == nil then
        return false
    end
    return true
end

function SingManager:InitHandler()
    self:AddNetHandler(16800, self.On16800)
    self:AddNetHandler(16801, self.On16801)
    self:AddNetHandler(16802, self.On16802)
    self:AddNetHandler(16803, self.On16803)
    self:AddNetHandler(16804, self.On16804)
    self:AddNetHandler(16805, self.On16805)
    self:AddNetHandler(16806, self.On16806)
    self:AddNetHandler(16807, self.On16807)
    self:AddNetHandler(16808, self.On16808)
    self:AddNetHandler(16809, self.On16809)
    self:AddNetHandler(16810, self.On16810)
    self:AddNetHandler(16811, self.On16811)
    self:AddNetHandler(16812, self.On16812)
    self:AddNetHandler(16813, self.On16813)
    self:AddNetHandler(16814, self.On16814)
    self:AddNetHandler(16815, self.On16815)
end

function SingManager:OpenMain(args)
    self.openArgs = args
    local list = self:GetOrderList()
    -- BaseUtils.dump(list, "list")
    if #list > 0 then
        self.model:OpenMain(self.openArgs)
    else
        if RoleManager.Instance.RoleData.lev < 40 then           
            NoticeManager.Instance:FloatTipsByString(TI18N("目前暂无好声音上传，晚点再来看看吧{face_1,18}"))
            return
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前还没有玩家录制上传好声音"))
        end
    end
    
    self:AskSongList()
    self:Send16813()
end

-- 提交歌曲
function SingManager:Send16800(summary, voice, time)
    self:Send(16800, {summary = summary, voice = voice, time = time})
end

function SingManager:On16800(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    if dat.result == 1 then
        self.model:CloseSignup()
        self:Send16803()
    end
    self.mySongId = dat.id
end

-- 查询当前歌曲列表
function SingManager:Send16801()
    print("Send16801")
    self:Send(16801, {})
end

function SingManager:On16801(dat)
    -- BaseUtils.dump(dat, "接收16801")
    local count = 0
    self.songList = {}
    for i,v in ipairs(dat.goodvoice_list) do
        count = count + 1
        local key = string.format("%s_%s_%s", v.rid, v.platform, v.zone_id)
        local singData = self.songList[key]
        if singData == nil then
            singData = SingData.New()
            self.songList[key] = singData
        end
        singData:Update(v)
    end
    self.showList = self.model:GetRandomList(dat.goodvoice_list, 3, 20)

    self.follow = {}
    for i,v in ipairs(dat.follow) do
        local key = string.format("%s_%s_%s", v.rid, v.platform, v.zone_id)
        self.follow[key] = 1
    end

    if self.isInit then
        if count == 0 then
            if (self.activeState > 1 and self.activeState < 5) or self.activeState > 5 then
                NoticeManager.Instance:FloatTipsByString(TI18N("好声音正在进行中，快来录制属于自己的好声音吧{face_1,18}"))
                self.model:OpenSignup()
            end
        end
    end

    self.model:UpdateMainInfo()
    self.isInit = true
end

-- 请求歌曲
function SingManager:Send16802(rid, platform, zone_id)
    self:Send(16802, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16802(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    local key = string.format("%s_%s_%s", dat.rid, dat.platform, dat.zone_id)
    local clip = self.model:GetAudioClip(dat.voice)
    SingManager.Instance.cached[key] = {clip = clip, update_time = dat.update_time}
    self.model:LocalSave(dat.voice, key, dat.update_time)
    local singData = self.songList[key]
    if singData ~= nil then
        singData.clip = clip
        if key == self.currentPlayKey then
            self.model:PlaySong(singData)
        end
    else
        if key == self.currentPlayKey then
            self.model:PlayClip(clip)
        end
    end

    local own = string.format("%s_%s_%s", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    if own == key then
        self.mySongClip = clip
        self.mySongSpx = dat.voice
        self.mySongUpdate = dat.update_time
    end
end

-- 查询自己的提交情况
function SingManager:Send16803()
    self:Send(16803, {})
end

function SingManager:On16803(dat)
    self.mySongId = dat.id
    self.mySongTime = dat.time
    self.mySongUpdate = dat.update_time
    self.mySongDesc = dat.summary
    self.mySongLiked = dat.liked
    self.mySongPlay = dat.caster_num
    self.model:UpdateSignUp()

    if self.mySongClip == nil then
        local name = string.format("%s_%s_%s", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
        local cacheData = SingManager.Instance.cached[name]
        if cacheData ~= nil then
            if cacheData.update_time == dat.update_time then
                if cacheData.clip == nil then
                    if cacheData.file ~= nil then
                        self.mySongClip = self.model:GetLocal(cacheData.file)
                    end
                else
                    self.mySongClip = cacheData.clip
                end
            else
                if dat.id ~= 0 then
                    -- 没提交过的不请求
                    self:Send16802(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
                end
            end
        else
            if dat.id ~= 0 then
                -- 没提交过的不请求
                self:Send16802(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
            end
        end
    end
end

-- 更新歌曲
function SingManager:Send16804(voice, time)
    self:Send(16804, {voice = voice, time = time})
end

function SingManager:On16804(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    if dat.result == 1 then
        self.model:UpdateSignUp()
    end
end

-- 更新简介
function SingManager:Send16805(summary)
    self.tempsummary = summary
    self:Send(16805, {summary = summary})
end

function SingManager:On16805(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    if dat.result == 1 then
        self.mySongDesc = self.tempsummary
        self.model:UpdateSignUp()
    end
    self.tempsummary = ""
end

-- 关注
function SingManager:Send16806(rid, platform, zone_id, follow)
    self:Send(16806, {rid = rid, platform = platform, zone_id = zone_id, follow = follow})
end

function SingManager:On16806(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    if dat.result == 1 then
        local key = string.format("%s_%s_%s", dat.rid, dat.platform, dat.zone_id)
        if dat.follow == 0 then
            -- 取消关注
            self.follow[key] = nil
        else
            self.follow[key] = 1
        end
        EventMgr.Instance:Fire(event_name.sing_follow_update)
    end
end

-- 举报
function SingManager:Send16807(rid, platform, zone_id)
    self:Send(16807, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16807(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 查看指定作品
function SingManager:Send16808(rid, platform, zone_id)
    self:Send(16808, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16808(dat)
    local singData = SingData.New()
    singData:Update(dat)
    self.model:OpenAdvert(singData)
end

-- 当前活动状态
function SingManager:Send16809()
    self:Send(16809, {})
end

function SingManager:On16809(dat)
    if self.activeState == 4 and dat.status == 5 then
        self.model:ClearAllLoaclFile()
    end
    self.activeState = dat.status

-- self.activeState = SingEumn.ActiveState.SignUp
    if dat.status == 6 or dat.status == 7 or dat.status == 8 then
        self:Send16812()
    end

    self:AskSongList()
    self:Send16813()
end

-- 好评
function SingManager:Send16810(rid, platform, zone_id)
    self:Send(16810, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16810(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    if dat.result == 1 then
        self:Send16813()
    end
end

-- 好评记录
function SingManager:Send16811(rid, platform, zone_id)
    self:Send(16811, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16811(dat)
    --BaseUtils.dump(dat, "接收16811")
    if #dat.logs > 0 then
        self.model:UpdateAdvertHistory(dat.logs)
    end
end

function SingManager:OpenTime(args)
    self.model:OpenTime(args)
end

function SingManager:OpenDesc(args)
    self.model:OpenDesc(args)
end

-- 转换好评显示
function SingManager:ShowLiked(liked)
    local str = "<100"
    local level = 0

    local dial = self.model.dialList
    local len = #dial

    local res = BaseUtils.BinarySearch(liked, dial)

    if res.index == 0 then
        return "<" .. dial[1], 0
    else
        if res.index == len then
            return ">" .. dial[len], len
        else
            return dial[res.index].."+", res.index
        end
    end
end

-- 是否有入围赛资格
function SingManager:Send16812()
    self:Send(16812, {})
end

function SingManager:On16812(data)
    -- BaseUtils.dump(data, "接收16812")
    self.isRiseRank = data.flag
end

-- 今日好评角色列表
function SingManager:Send16813()
    self:Send(16813, {})
end

function SingManager:On16813(data)
    --BaseUtils.dump(data, "<color='#00ff00'>接收16813</color>")
    self.model:UpdateAdvertList(data.list)
end

-- 获取排行榜列表
function SingManager:Send16814(type)
    print("Send16814 "..type)
    self:Send(16814, { type = type })
end

function SingManager:On16814(data)
    BaseUtils.dump(data, "<color='#00ff00'>接收16814</color>")

    if data.type == 1 then
        self.rankList = data.goodvoice_rank
        local temp = {}
        temp.rank_list = data.goodvoice_rank
        table.sort(temp.rank_list, function(a,b) return a.rank < b.rank end)
        local pos = RankManager.Instance.model.rankTypeToPageIndexList[RankManager.Instance.model.rank_type.GoodVoice]
        RankManager.Instance.model:SetData(pos.main, pos.sub, 1, temp)
        EventMgr.Instance:Fire(event_name.sing_ranklist_update)
    else
        local temp = {}
        temp.rank_list = data.goodvoice_rank
        table.sort(temp.rank_list, function(a,b) return a.rank < b.rank end)
        local pos = RankManager.Instance.model.rankTypeToPageIndexList[RankManager.Instance.model.rank_type.GoodVoice2]
        RankManager.Instance.model:SetData(pos.main, pos.sub, 1, temp)
        EventMgr.Instance:Fire(event_name.sing_ranklist_update)
    end
end

-- 播放排行榜歌曲
function SingManager:Send16815(rid, platform, zone_id)
    self:Send(16815, {rid = rid, platform = platform, zone_id = zone_id})
end

function SingManager:On16815(dat)
    BaseUtils.dump(dat, "<color='#00ff00'>接收16815</color>")
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
    local key = string.format("%s_%s_%s_r", dat.rid, dat.platform, dat.zone_id)
    local clip = self.model:GetAudioClip(dat.voice)
    SingManager.Instance.cached[key] = {clip = clip, update_time = dat.update_time}
    self.model:LocalSave(dat.voice, key, dat.update_time)
    local singData = self.songList[key]
    if singData ~= nil then
        singData.clip = clip
        self.model:PlaySong(singData, true)
    else
        self.songList[key] = dat
        self.songList[key].clip = clip
        self.model:PlaySong(self.songList[key], true)
    end

end

-- forceReask 1 表示强制重新请求
function SingManager:AskSongList(forceReask)
    if #self.songList == 0 then
        forceReask = 1
    end
    if forceReask == 1 then
        self:Send16801()
    else
        self.model:UpdateMainInfo()
    end
end
