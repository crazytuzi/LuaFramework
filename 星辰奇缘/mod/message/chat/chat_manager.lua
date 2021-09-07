-- ------------------------------------
-- 聊天
-- hosr
-- ------------------------------------
ChatManager = ChatManager or BaseClass(BaseManager)

function ChatManager:__init()
    if ChatManager.Instance then
        return
    end

    ChatManager.Instance = self

    MessageFilter.Init()

    self.model = ChatModel.New()

    self:InitHandler()

    -- 输入历史
    self.inputHistoryTab = {}

    self.itemCache = {}
    self.petCache = {}
    self.equipCache = {}
    self.guardCache = {}
    self.wingCache = {}
    self.rideCache = {}
    self.childCache = {}
    self.talismanCache = {}

    -- 小表情
    self.miniFaceDic = {}

    -- 大表情
    self.bigFaceDic = {}

    -- 等待处理缓存数据
    self.waitingCacheTab = {}

    -- 是否自动播放
    self.autoPlayWorld = false
    self.autoPlayTeam = false
    self.autoPlayGuild = false

    self.startAutoPlay = false

    -- 是否在录音中
    self.IsRecording = false

    self.worldCd = 0
    self.sceneCd = 0
    self.mixworldCd = 0
    self.honorCd = 0
    self.activityCd = 0

    -- 元素计数
    self.faceCount = 0
    self.hasRoll = false
    self.hasGuess = false

    -- 上次消息时间记录
    self.lastMsgTime = {
        [MsgEumn.ChatChannel.World] = 0,
        [MsgEumn.ChatChannel.Team] = 0,
        [MsgEumn.ChatChannel.Scene] = 0,
        [MsgEumn.ChatChannel.Guild] = 0,
        [MsgEumn.ChatChannel.Private] = 0,
        [MsgEumn.ChatChannel.Group] = 0,
        [MsgEumn.ChatChannel.Bubble] = 0,
        [MsgEumn.ChatChannel.Hearsay] = 0,
        [MsgEumn.ChatChannel.System] = 0,
        [MsgEumn.ChatChannel.MixWorld] = 0,
        [MsgEumn.ChatChannel.Activity] = 0,
        [MsgEumn.ChatChannel.Activity1] = 0,
        [MsgEumn.ChatChannel.Camp] = 0,
    }

    self.spaceTime = 60 * 2

    -- 是否正在打开聊天输入框
    self.customKeyboard = false

    -- @人限制 同一个频道，同一个人@你，一分钟最多收到一个上浮
    self.atLimitTab = {}

    -- 上一次收到聊天协议的时间
    self.lastReviceTime = 0
end

function ChatManager:OnTick()
    if self.worldCd ~= 0 or self.sceneCd ~= 0 or self.mixworldCd ~= 0 or self.activityCd ~= 0 then
        self.worldCd = math.max(self.worldCd - 1, 0)
        self.sceneCd = math.max(self.sceneCd - 1, 0)
        self.mixworldCd = math.max(self.mixworldCd - 1, 0)
        self.activityCd = math.max(self.activityCd - 1, 0)
        self.model:OnTick()
    end

    if self.honorCd > 0 then
        self.honorCd = math.max(self.honorCd - 1, 0)
    end
end

function ChatManager:__delete()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function ChatManager:InitHandler()
    self:AddNetHandler(10400, self.On10400)
    self:AddNetHandler(10401, self.On10401)
    self:AddNetHandler(10402, self.On10402)
    self:AddNetHandler(10403, self.On10403)
    self:AddNetHandler(10404, self.On10404)
    self:AddNetHandler(10405, self.On10405)
    self:AddNetHandler(10406, self.On10406)
    self:AddNetHandler(10407, self.On10407)
    self:AddNetHandler(10408, self.On10408)
    self:AddNetHandler(10409, self.On10409)
    self:AddNetHandler(10410, self.On10410)
    self:AddNetHandler(10411, self.On10411)
    self:AddNetHandler(10413, self.On10413)
    self:AddNetHandler(10415, self.On10415)
    self:AddNetHandler(10416, self.On10416)
    self:AddNetHandler(10417, self.On10417)
    self:AddNetHandler(10418, self.On10418)
    self:AddNetHandler(10419, self.On10419)
    self:AddNetHandler(10420, self.On10420)
    self:AddNetHandler(10421, self.On10421)
    self:AddNetHandler(10424, self.On10424)
    self:AddNetHandler(10425, self.On10425)
    self:AddNetHandler(10426, self.On10426)
    self:AddNetHandler(10427, self.On10427)
    self:AddNetHandler(10428, self.On10428)
    
    self:AddNetHandler(10432, self.On10432)
end

-- 发送聊天信息
function ChatManager:Send10400(target_channel, msg, nocd)
    if msg == "" then
        return
    end
    self:ResetElementCount()

    if not nocd then
        if target_channel == MsgEumn.ChatChannel.World then
            if RoleManager.Instance.RoleData.label == 1 or RoleManager.Instance.RoleData.label == 2 then
                --GM = 1  指导员 = 2
                self.worldCd = 4
            else
                self.worldCd = 31
            end
        elseif target_channel == MsgEumn.ChatChannel.MixWorld then
            self.mixworldCd = 31
        elseif target_channel == MsgEumn.ChatChannel.Scene then
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
                self.sceneCd = 31
            else 
                self.sceneCd = 6
            end
        elseif target_channel == MsgEumn.ChatChannel.Activity then
            self.activityCd = 31
        elseif target_channel == MsgEumn.ChatChannel.Activity1 then
            self.activityCd = 31
        elseif target_channel == MsgEumn.ChatChannel.Camp then
            self.activityCd = 0
        end
    end

    print(string.format("发送============ %s", msg))
    self:Send(10400, {channel = target_channel, msg = msg})

    -- 钻石联赛特殊处理
    if target_channel == MsgEumn.ChatChannel.Scene then
        if SceneManager.Instance:CurrentMapId() == 53002
            or SceneManager.Instance:CurrentMapId() == 53003
            or SceneManager.Instance:CurrentMapId() == 53004
            then
            IngotCrashManager.Instance.isShowDamaku = true
            IngotCrashManager.Instance:send20014(msg)
        end
        -- 冲顶答题
        if (RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTop or
             RoleManager.Instance.RoleData.event == RoleEumn.Event.RushTopPlay)and
              RushTopManager.Instance.model.playerInfo.barrage_time < BaseUtils.BASE_TIME then
            RushTopManager.Instance:Send20430(msg)
        end

        -- 诸神膜拜
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
            --print('dslfjsdkjfklsdjfklsdjklfjsdklfjsdkljfl')
            --print(msg)
            local mystr = string.gsub(msg,"{(%l-_%d.-),(.-)}"," ")
            GodsWarWorShipManager.Instance:SendDanmaku(mystr)
        end
    end
end

-- 收到聊天信息
function ChatManager:On10400(dat)
    BaseUtils.dump(dat, "On10400")
    if self:NeedFilter() and dat.channel == MsgEumn.ChatChannel.World then
        if Time.time - self.lastReviceTime <= 0.1 then
            -- print(Time.time - self.lastReviceTime)
            return
        end
    end
    self.lastReviceTime = Time.time

    if self:IsSheild(dat.rid, dat.platform, dat.zone_id) then
        print(string.format("已屏蔽此人发言 %s_%s_%s", dat.rid, dat.platform, dat.zone_id))
        return
    end

    -- BaseUtils.dump(dat, "聊天内容")
    local msgData = MessageParser.GetMsgData(dat.msg)
    local chatData = ChatData.New()
    chatData:Update(dat)
    chatData.showType = MsgEumn.ChatShowType.Normal
    chatData.msgData = msgData
    if dat.channel == MsgEumn.ChatChannel.Bubble then
        chatData.channel = MsgEumn.ChatChannel.Scene
        --公会宣读
        SceneTalk.Instance:ShowTalk_Player(dat.rid,dat.zone_id,dat.platform,dat.msg,6)--msgData.showString,6)
        -- if dat.rid == RoleManager.Instance.RoleData.id then --自己宣读，显示读条
        --     GuildManager.Instance:ShowPublicityCollection(5000,function ()
        --         SceneTalk.Instance:HideTalk_Player(dat.rid,dat.zone_id,dat.platform)
        --     end)
        -- end
    end
    chatData.prefix = chatData.channel
    self.model:ShowMsg(chatData)
end

-- 聊天频道限制反馈
function ChatManager:On10401(dat)
    NoticeManager.Instance:FlatTipsByString(dat.msg)
end

-- 发送私聊信息
function ChatManager:Send10402(id, platform, zone_id, msg)
    local data = {id = id, platform = platform, zone_id = zone_id, msg = msg}
    self:ResetElementCount()
    self:Send(10402, {id = id, platform = platform, zone_id = zone_id, msg = msg})
end

-- 收到私聊信息
function ChatManager:On10402(dat)
    -- BaseUtils.dump(dat)
    if self:IsSheild(dat.id, dat.platform, dat.zone_id) then
        print(string.format("已屏蔽此人发言 %s_%s_%s", dat.id, dat.platform, dat.zone_id))
        return
    end
    local msgData = MessageParser.GetMsgData(dat.msg)
    local chatData = ChatData.New()
    chatData:Update(dat)
    chatData.showType = MsgEumn.ChatShowType.Normal
    chatData.msgData = msgData
    chatData.channel = MsgEumn.ChatChannel.Private
    chatData.prefix = MsgEumn.ChatChannel.Private
    self.model:ShowMsg(chatData)
end

-- 缓存语音信息
function ChatManager:Send10403(voiceData)
    -- BaseUtils.dump(voiceData, "缓存语音")
    local channel = voiceData.channel
    local voice = voiceData.byteData
    local msg = voiceData.msg
    local time = voiceData.time
    local cacheId = voiceData.cacheId

    -- 先自己给自己发
    -- local msgData = MsgData.New()
    -- msgData.sourceString = msg
    -- msgData.showString = msg
    -- local chatData = ChatData.New()
    -- chatData:Update(RoleManager.Instance.RoleData)
    -- chatData.showType = MsgEumn.ChatShowType.Voice
    -- chatData.msgData = msgData
    -- chatData.prefix = channel
    -- chatData.channel = channel
    -- chatData.cacheId = cacheId
    -- chatData.time = time
    -- chatData.rid = RoleManager.Instance.RoleData.id
    -- chatData.text = msg
    -- self.model:ShowMsg(chatData)

    if voice ~= nil then
        if channel == MsgEumn.ChatChannel.World then
            if RoleManager.Instance.RoleData.label == 1 or RoleManager.Instance.RoleData.label == 2 then
                --GM = 1  指导员 = 2
                self.worldCd = 4
            else
                self.worldCd = 31
            end
        elseif channel == MsgEumn.ChatChannel.Scene then
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
                self.sceneCd = 31
            else 
                self.sceneCd = 6
            end
        elseif channel == MsgEumn.ChatChannel.Activity then
            self.activityCd = 6
        elseif channel == MsgEumn.ChatChannel.Activity1 then
            self.activityCd = 6
        elseif channel == MsgEumn.ChatChannel.Camp then
            self.activityCd = 6
        end
        self:Send(10403, {channel = channel, voice = voice, time = time, text = msg, id = cacheId})
    end

    voiceData.byteData = nil
end

function ChatManager:On10403(dat)
    if self:IsSheild(dat.rid, dat.platform, dat.zone_id) then
        print(string.format("已屏蔽此人发言 %s_%s_%s", dat.rid, dat.platform, dat.zone_id))
        return
    end

    if self.model:GetCacheInfo(dat.id, dat.platform, dat.zone_id) == nil then
        local msgData = MsgData.New()
        msgData.sourceString = dat.text
        msgData.showString = dat.text
        local chatData = ChatData.New()
        chatData:Update(dat)
        chatData.showType = MsgEumn.ChatShowType.Voice
        chatData.msgData = msgData
        chatData.prefix = dat.channel
        chatData.cacheId = dat.id
        chatData.time = dat.time
        self.model:ShowMsg(chatData)

        self:CheckAutoPlay(chatData)
    end
end

-- 查询语音信息缓存
function ChatManager:Send10404(platform, zone_id, cacheId)
    Log.Debug("请求语音缓存")
    self:Send(10404, {platform = platform, zone_id = zone_id, id = cacheId})
end

function ChatManager:On10404(dat)
    if self.startAutoPlay then
        self:AutoPlayStart()
    end
    local clip = self.model:GetAudioClip(dat)
    if clip ~= nil then
        self.model:Play(clip)
    end
    dat.voice = nil
    dat = nil
end

-- 请求缓存id
function ChatManager:Send10406(type, base_id)
    self:Send(10406, {type = type, base_id = base_id})
end

function ChatManager:On10406(dat)
    -- BaseUtils.dump(dat, "收到缓存id")
    if dat.flag == 1 then
        if dat.type == MsgEumn.CacheType.Item then
            self.itemCache[dat.base_id] = dat.id
        elseif dat.type == MsgEumn.CacheType.Pet then
            self.petCache[dat.base_id] = dat.id
        elseif dat.type == MsgEumn.CacheType.Equip then
            self.equipCache[dat.base_id] = dat.id
        elseif dat.type == MsgEumn.CacheType.Guard then
            self.guardCache[dat.base_id] = dat.id
        elseif dat.type == MsgEumn.CacheType.Wing then
            self.wingCache[0] = dat.id
        elseif dat.type == MsgEumn.CacheType.Ride then
            self.rideCache[dat.base_id] = dat.id
        elseif dat.type == MsgEumn.CacheType.Talisman then
            self.talismanCache[dat.base_id] = dat.id
        end
    end
end

-- 请求语音缓存id,省着用，录音完成了再请求
function ChatManager:Send10405()
    Log.Debug("请求缓存id")
    self:Send(10405, {})
end

function ChatManager:On10405(dat)
    Log.Debug("收到缓存id" .. dat.id)
    self.model:SelfCacheIdBack(dat.id)
end

-- 请求缓存物品预览
function ChatManager:Send10407(platform, zone_id, cacheId)
    self:Send(10407, {platform = platform, zone_id = zone_id, query_id = cacheId})
end

function ChatManager:On10407(dat)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Item, dat.query_id)]
    if info ~= nil then
        local msg = info.msg
        local baseData = DataItem.data_get[msg.itemId]
        local itemData = ItemData.New()
        itemData:SetBase(baseData)
        itemData:SetProto(dat)
        info.result = itemData
        self:ShowItemTips(info)
    end
end

-- 请求缓存宠物预览
function ChatManager:Send10408(platform, zone_id, cacheId)
    self:Send(10408, {platform = platform, zone_id = zone_id, id = cacheId})
end

function ChatManager:On10408(dat)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Pet, dat.id)]
    if info ~= nil then
        info.result = PetManager.Instance.model:updatepetbasedata(dat)
        PetManager.Instance.model:ProcessingSkillData(info.result)
        PetManager.Instance.model.quickshow_petdata = info.result
        PetManager.Instance.model:OpenPetQuickShowWindow()
    end
end

-- 请求缓存装备预览
function ChatManager:Send10409(platform, zone_id, cacheId)
    self:Send(10409, {platform = platform, zone_id = zone_id, query_id = cacheId})
end

function ChatManager:On10409(dat)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Equip, dat.query_id)]
    if info ~= nil then
        local msg = info.msg
        local baseData = DataItem.data_get[msg.itemId]
        local itemData = ItemData.New()
        itemData:SetBase(baseData)
        itemData:SetProto(dat)
        info.result = itemData
        self:ShowItemTips(info)
    end
end

-- 请求缓存守护数据
function ChatManager:Send10410(platform, zone_id, cacheId)
    self:Send(10410, {platform = platform, zone_id = zone_id, query_id = cacheId})
end

function ChatManager:On10410(dat)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Guard, dat.query_id)]
    if info ~= nil then
        info.result = dat
        local result_data = ShouhuManager.Instance.model:build_look_win_data(info.result, info.data.lev)
        result_data.owner_name = info.data.name
        ShouhuManager.Instance.model.shouhu_look_dat = result_data
        ShouhuManager.Instance.model:OpenShouhuLookUI()
    end
end

-- 私聊语音发送
function ChatManager:Send10411(voiceData)
    local channel = voiceData.channel
    local voice = voiceData.byteData
    local msg = voiceData.msg
    local time = voiceData.time
    local cacheId = voiceData.cacheId
    local rid = voiceData.rid
    local platform = voiceData.platform
    local zone_id = voiceData.zone_id

    -- 先自己给自己发
    local msgData = MsgData.New()
    msgData.sourceString = msg
    msgData.showString = msg
    local chatData = ChatData.New()
    chatData:Update(RoleManager.Instance.RoleData)
    chatData.rid = rid
    chatData.id = rid
    chatData.platform = platform
    chatData.zone_id = zone_id
    chatData.showType = MsgEumn.ChatShowType.Voice
    chatData.msgData = msgData
    chatData.prefix = channel
    chatData.channel = channel
    chatData.cacheId = cacheId
    chatData.text = msg
    chatData.time = time
    chatData.isself = true
    self.model:ShowMsg(chatData)

    if voice ~= nil then
        self:Send(10411, {id = rid, platform = platform, zone_id = zone_id, voice = voice, time = time, text = msg, cache_id = cacheId})
    end

    voiceData.byteData = nil
end

function ChatManager:On10411(dat)
    if self:IsSheild(dat.id, dat.platform, dat.zone_id) then
        print(string.format("已屏蔽此人发言 %s_%s_%s", dat.id, dat.platform, dat.zone_id))
        return
    end

    if self.model:GetCacheInfo(dat.cache_id, dat.platform, dat.zone_id) == nil then
        local msgData = MsgData.New()
        msgData.sourceString = dat.text
        msgData.showString = dat.text
        local chatData = ChatData.New()
        chatData:Update(dat)
        chatData.showType = MsgEumn.ChatShowType.Voice
        chatData.msgData = msgData
        chatData.channel = MsgEumn.ChatChannel.Private
        chatData.prefix = MsgEumn.ChatChannel.Private
        chatData.cacheId = dat.cache_id
        chatData.time = dat.time
        self.model:ShowMsg(chatData)

        self:CheckAutoPlay(chatData)
    end
end

function ChatManager:Send10412()
    self:Send(10412,{})
end

function ChatManager:On10413(dat)
    SceneTalk.Instance:ShowTalk_Player(dat.id, dat.zone_id, dat.platform, dat.msg, 2)
end

function ChatManager:Send10415(bubble)
    self:Send(10415,{ bubble = bubble })
end

function ChatManager:On10415(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function ChatManager:Send10416()
    self:Send(10416,{})
end

function ChatManager:On10416(dat)
    self.model.bubble_id = dat.bubble_id
    AchievementManager.Instance.onUpdateBuyPanel:Fire()
end

function ChatManager:Send10417(platform, zone_id, query_id, classes, owner_name)
    self.wingClasses = classes
    self.wingowner = owner_name
    self:Send(10417,{platform = platform, zone_id = zone_id, query_id = query_id})
end

function ChatManager:On10417(dat)
    dat.classes = self.wingClasses
    dat.owner = self.wingowner
    WingsManager.Instance:OpenWingInfoWindow(dat)
end

-- 请求缓存坐骑预览
function ChatManager:Send10418(platform, zone_id, cacheId)
    self:Send(10418, {platform = platform, zone_id = zone_id, query_id = cacheId})
end

function ChatManager:On10418(dat)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Ride, dat.query_id)]
    if info ~= nil then
        info.mount = RideManager.Instance.model:updateridebasedata(dat)
        RideManager.Instance.model.show_ridedata = info.mount
        RideManager.Instance.model:OpenRideShowWindow()
    else
        RideManager.Instance.model.show_ridedata = RideManager.Instance.model:updateridebasedata(dat)
        RideManager.Instance.model:OpenRideShowWindow()
    end
end

-- 发送招募提示
function ChatManager:Send10419(match_id)
    print("Send10419=============================================================================")
    self:Send(10419, {match_id = match_id})
end

function ChatManager:On10419(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function ChatManager:Send10420(child_id, platform, zone_id)
    self:Send(10420, {child_id = child_id, platform = platform, zone_id = zone_id})
end

function ChatManager:On10420(dat)
    if dat.flag == 1 then
        self.childCache[0] = dat.id
    end
end

-- 请求缓存孩子预览
function ChatManager:Send10421(platform, zone_id, cacheId)
    -- print("发送协议10421============================================================")
    self:Send(10421, {platform = platform, zone_id = zone_id, id = cacheId})
end

function ChatManager:On10421(dat)
    -- BaseUtils.dump(dat,"10421协议回调===============================================================================")
    local child_data = ChildrenData.New()
    child_data:SetProto(dat)
    table.sort(child_data.talent_skills, function(a,b) return a.grade < b.grade end)

    ChildrenManager.Instance.quickShowChildData = child_data
    ChildrenManager.Instance.model:OpenChildQuickShow()
end


-- 发送群聊消息
function ChatManager:Send10424(channel, group_id, group_platform, group_zone_id, msg)
print(debug.traceback())
    self:Send(10424, {channel = channel, group_id = group_id, group_platform = group_platform, group_zone_id = group_zone_id, msg = msg})
end

function ChatManager:On10424(dat)
    -- BaseUtils.dump(dat, "收到群聊消息")
    local msgData = MessageParser.GetMsgData(dat.msg)
    local chatData = ChatData.New()
    chatData:Update(dat)
    chatData.showType = MsgEumn.ChatShowType.Normal
    chatData.msgData = msgData
    chatData.prefix = chatData.channel
    -- self.model:ShowMsg(chatData)
    FriendGroupManager.Instance:ReceiveMsg(chatData)
end


-- 群组语音缓存
function ChatManager:Send10425(voiceData)
    -- BaseUtils.dump(voiceData, "缓存语音")
    local channel = voiceData.channel
    local voice = voiceData.byteData
    local msg = voiceData.msg
    local time = voiceData.time
    local cacheId = voiceData.cacheId

    -- 先自己给自己发
    local msgData = MsgData.New()
    msgData.sourceString = msg
    msgData.showString = msg
    local chatData = ChatData.New()
    chatData:Update(RoleManager.Instance.RoleData)
    chatData.showType = MsgEumn.ChatShowType.Voice
    chatData.msgData = msgData
    chatData.prefix = channel
    chatData.channel = channel
    chatData.cacheId = cacheId

    chatData.group_id = voiceData.group_id
    chatData.group_platform = voiceData.group_platform
    chatData.group_zone_id = voiceData.group_zone_id

    chatData.time = time
    chatData.rid = RoleManager.Instance.RoleData.id
    chatData.text = msg
    self:On10424(chatData)

    if voice ~= nil then
        self:Send(10425, {channel = channel, group_id = voiceData.group_id, group_platform = voiceData.group_platform, group_zone_id = voiceData.group_zone_id, voice = voice, time = time, text = msg, id = cacheId})
    end

    voiceData.byteData = nil
end

function ChatManager:On10425(dat)
    local msgData = MsgData.New()
    msgData.sourceString = dat.text
    msgData.showString = dat.text
    local chatData = ChatData.New()
    chatData:Update(dat)
    chatData.showType = MsgEumn.ChatShowType.Voice
    chatData.msgData = msgData
    chatData.prefix = dat.channel
    chatData.cacheId = dat.id
    chatData.time = dat.time

    FriendGroupManager.Instance:ReceiveMsg(chatData)
end

function ChatManager:Send10426(msg)
    self:Send(10426, {msg = msg})
end

function ChatManager:On10426(dat)
    -- BaseUtils.dump(dat, "On10426")
    NoticeManager.Instance:FloatTipsByString(dat.msg)
    EventMgr.Instance:Fire(event_name.combat_danmaku_cd)
end

-- 请求法宝缓存数据
function ChatManager:Send10427(id, platform, zone_id)
-- BaseUtils.dump({ platform = platform, query_id = id, zone_id = zone_id}, "发送")
    self:Send(10427, { platform = platform, query_id = id, zone_id = zone_id})
end

function ChatManager:On10427(dat)
    -- BaseUtils.dump(dat, "On10427")
    local info = {itemData = dat}
    info.extra = {nobutton = true}
    TipsManager.Instance:ShowTalisman(info)
end
-- ----------------------------
-- 数据处理
-- ----------------------------
-- 加入当前输入到历史记录
function ChatManager:AppendHistory(str)
    if #self.inputHistoryTab == 9 then
        table.remove(self.inputHistoryTab, 1)
    end
    table.insert(self.inputHistoryTab, str)
end

-- 请求缓存数据
function ChatManager:ShowCacheData(gameObject, type, msg, data)
    if data == nil then
        return
    end
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", msg.platform, msg.zoneId, type, msg.cacheId)]
    if info ~= nil and info.result ~= nil then
        info.gameObject = gameObject
        if type == MsgEumn.CacheType.Item then
            self:ShowItemTips(info)
        elseif type == MsgEumn.CacheType.Pet then
            PetManager.Instance.model.quickshow_petdata = info.result
            PetManager.Instance.model:OpenPetQuickShowWindow()
        elseif type == MsgEumn.CacheType.Equip then
            self:ShowItemTips(info)
        elseif type == MsgEumn.CacheType.Guard then
            local result_data = ShouhuManager.Instance.model:build_look_win_data(info.result, data.lev)
            result_data.owner_name = data.name
            ShouhuManager.Instance.model.shouhu_look_dat = result_data
            ShouhuManager.Instance.model:OpenShouhuLookUI()
        elseif type == MsgEumn.CacheType.Ride then
            RideManager.Instance.model.show_ridedata = info.result
            RideManager.Instance.model:OpenRideShowWindow()
        elseif type == MsgEumn.CacheType.Child then
            ChildrenManager.Instance.quickShowChildData = info.result
            ChildrenManager.Instance.model:OpenChildQuickShow()
        end
        return
    else
        if type == MsgEumn.CacheType.Item then
            self:Send10407(data.platform, data.zone_id, msg.cacheId)
        elseif type == MsgEumn.CacheType.Pet then
            self:Send10408(data.platform, data.zone_id, msg.cacheId)
        elseif type == MsgEumn.CacheType.Equip then
            self:Send10409(data.platform, data.zone_id, msg.cacheId)
        elseif type == MsgEumn.CacheType.Guard then
            self:Send10410(data.platform, data.zone_id, msg.cacheId)
        elseif type == MsgEumn.CacheType.Ride then
            self:Send10418(data.platform, data.zone_id, msg.cacheId)
        elseif type == MsgEumn.CacheType.Child then
            self:Send10421(data.platform, data.zone_id, msg.cacheId)
        end
    end
    self.waitingCacheTab[string.format("%s_%s_%s_%s", msg.platform, msg.zoneId, type, msg.cacheId)] = {gameObject = gameObject, type = type, data = data, msg = msg}
end

function ChatManager:ShowItemTips(info)
    if info.result.type == BackpackEumn.ItemType.petattrgem or info.result.type == BackpackEumn.ItemType.petskillgem then
        TipsManager.Instance:ShowPetEquip({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
    elseif info.result.type == BackpackEumn.ItemType.childattreqm or info.result.type == BackpackEumn.ItemType.childskilleqm then
        TipsManager.Instance:ShowPetEquip({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
    elseif info.result.func == TI18N("变身") then
        -- TipsManager.Instance:ShowFruit({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
        local isRandom = false
        local isNewFruit = false
        for i,v in ipairs(info.result.effect) do
            if v.effect_type == 52 then
                isNewFruit = true
                break
            end

            if v.effect_type == 20 then
                isRandom = true
                break
            end
        end

        if isNewFruit then
            TipsManager.Instance:ShowFruitNew({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
        elseif isRandom then
            TipsManager.Instance:ShowRandomFruit({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
        else
            TipsManager.Instance:ShowFruit({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
        end
    else
        if BackpackManager.Instance:IsEquip(info.result.type) then
            TipsManager.Instance:ShowEquip({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true, classes = info.data.classes, sex = info.data.sex, lev = info.data.lev}})
        else
            TipsManager.Instance:ShowItem({gameObject = info.gameObject, itemData = info.result, extra = {nobutton = true}})
        end
    end
end

function ChatManager:CurrentChannel()
    if self.model.chatWindow ~= nil and self.model.chatWindow.currentChannel ~= nil then
        return self.model.chatWindow.currentChannel.channel
    end
    return MsgEumn.ChatChannel.World
end

-- 消息发送时处理
-- 1.直接发送
-- 2.表情通用符号是 #id 自动转义成标签发送，最大5个
-- 3.处理记录历史消息
function ChatManager:SendMsg(channel, msg, _gsub)
    if msg == "" then
        return false
    end

    if RoleManager.Instance.RoleData.lev < MsgEumn.ChannelLimit[channel] then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才能在<color='#ffff00'>%s频道</color>说话，加油升级哦！"), MsgEumn.ChannelLimit[channel], MsgEumn.ChatChannelName[channel]))
        return false
    end

    if channel == MsgEumn.ChatChannel.World and self.worldCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.worldCd, MsgEumn.ChatChannelName[channel]))
        return false
    end

    if channel == MsgEumn.ChatChannel.Scene and self.sceneCd ~= 0 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then 
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.sceneCd, TI18N("峡谷")))
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.sceneCd, MsgEumn.ChatChannelName[channel]))
        end
        return false
    end

    if channel == MsgEumn.ChatChannel.MixWorld and self.mixworldCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.mixworldCd, MsgEumn.ChatChannelName[channel]))
        return false
    end

    if channel == MsgEumn.ChatChannel.Activity and self.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.activityCd, MsgEumn.ChatChannelName[channel]))
        return false
    end

    if channel == MsgEumn.ChatChannel.Activity1 and self.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.activityCd, MsgEumn.ChatChannelName[channel]))
        return false
    end

    if channel == MsgEumn.ChatChannel.Camp and self.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.activityCd, MsgEumn.ChatChannelName[channel]))
        return false
    end

    if _gsub == nil then
    msg = string.gsub(msg, "<.->", "")
    end
    local send_msg = MessageParser.ConvertToTag_Face(msg)
    -- send_msg = MessageParser.ReplaceSpace(send_msg)

    if ctx.PlatformChanleId == 110 then
    -- 暂时只有乐视渠道处理过滤
    print("报警啦")
    send_msg = MessageFilter.Parse(send_msg)
    end

    if channel == MsgEumn.ChatChannel.World then
    NationalDayManager.Instance.model:CheckCanAnswerNationalDay(send_msg)
    end

    self:Send10400(channel, send_msg)
    RedBagManager.Instance.model:CheckRedBagPassword(channel, send_msg)

    self.itemCache = {}
    self.petCache = {}
    self.equipCache = {}
    self.guardCache = {}
    self.wingCache = {}
    self.rideCache = {}
    self.childCache = {}
    self.talismanCache = {}
    return true
end

function ChatManager:CheckAutoPlay(chatData)
    if SingManager.Instance:Singing() then
        Log.Debug("唱歌中!")
        return
    end

    if SdkManager.Instance.platform ~= RuntimePlatform.IPhonePlayer and SdkManager.Instance.platform ~= RuntimePlatform.Android then
        Log.Debug("不支持语音播放!")
        return
    end

    -- 静音不播放
    if self.model.speech:IsMute() then
        Log.Debug("静音不播放语音")
        return
    end

    if self.startAutoPlay then
        Log.Debug("自动播放中")
        return
    end

    if self.IsRecording then
        Log.Debug("录音中不自动播放")
        return
    end

    local play = false
    if chatData.channel == MsgEumn.ChatChannel.World and self.autoPlayWorld then
        play = true
    elseif chatData.channel == MsgEumn.ChatChannel.Team and self.autoPlayTeam then
        play = true
    elseif chatData.channel == MsgEumn.ChatChannel.Guild and self.autoPlayGuild then
        play = true
    end

    if play then
        Log.Debug("自动播放语音啦")
        self:WaitAutoStartTimeOut()
        self.startAutoPlay = true
        self.waitAutoStartId = LuaTimer.Add(5000, function() self:WaitAutoStartTimeOut() end)
        self:Send10404(chatData.platform, chatData.zone_id, chatData.cacheId)
    end
end

function ChatManager:WaitAutoStartTimeOut()
    Log.Debug("自动播放语音--超时")
    if self.waitAutoStartId ~= nil then
        LuaTimer.Delete(self.waitAutoStartId)
    end
    self.waitAutoStartId = nil
    self.startAutoPlay = false
end

function ChatManager:AutoPlayStart()
    if self.waitAutoStartId ~= nil then
        LuaTimer.Delete(self.waitAutoStartId)
    end
    self.waitAutoStartId = nil
end

function ChatManager:Clean()
    self.worldCd = 0
    self.sceneCd = 0
    self.mixworldCd = 0
    self.honorCd = 0
    self.activityCd = 0

    if self.model ~= nil then
        self.model:ClearAll()
    end

    self.itemCache = {}
    self.petCache = {}
    self.equipCache = {}
    self.guardCache = {}
    self.wingCache = {}
    self.rideCache = {}
    self.childCache = {}
    self.talismanCache = {}

    -- 等待处理缓存数据
    self.waitingCacheTab = {}

    self.customKeyboard = false
end

function ChatManager:CleanSomeCache()
    self.itemCache = {}
    self.petCache = {}
    self.equipCache = {}
    self.guardCache = {}
    self.wingCache = {}
    self.rideCache = {}
    self.childCache = {}
    self.talismanCache = {}
end

function ChatManager:HideAll()
end

function ChatManager:ShowAll()
end

function ChatManager:ResetElementCount()
    self.faceCount = 0
    self.hasRoll = false
    self.hasGuess = false
end

function ChatManager:AppendInputElement(element, type, otherOption)
    local ok = true
    if element.type == MsgEumn.AppendElementType.Face then
        if element.data == 1000 then
            if self.hasRoll then
                ok = false
            else
                self.hasRoll = true
            end
        elseif element.data == 1001 then
            if self.hasGuess then
                ok = false
            else
                self.hasGuess = true
            end
        else
            if self.faceCount == 5 then
                ok = false
            else
                self.faceCount = self.faceCount + 1
            end
        end
    end
    if ok then
        if type == MsgEumn.ExtPanelType.Chat then
            self.model:AppendInputElement(element)
        elseif type == MsgEumn.ExtPanelType.Friend then
            FriendManager.Instance.model:AppendInputElement(element)
        elseif type == MsgEumn.ExtPanelType.Group then
            FriendManager.Instance.model:GroupAppendInputElement(element)
        elseif type == MsgEumn.ExtPanelType.Zone then
            ZoneManager.Instance.model:AppendInputElement(element)
        elseif type == MsgEumn.ExtPanelType.Other then
            otherOption.parent:AppendInputElement(element)
        elseif type == MsgEumn.ExtPanelType.PetEvaluation then
            PetEvaluationManager.Instance.model:AppendInputElement(element)
        end
    end
end

-- 添加公会职位接口
function ChatManager:AppendGuildPost(sourceStr, rid, platform, zone_id)
    local gdata = GuildManager.Instance.model:get_guild_member_by_id(rid, platform, zone_id)
    if gdata ~= nil and (gdata.Post >= GuildManager.Instance.model.member_positions.sergeant or gdata.Post >= GuildManager.Instance.model.member_positions.baby ) then
        local post = GuildManager.Instance.model.member_position_names[gdata.Post]
        local color_str = "#ffdc5f"
        if gdata.Post == GuildManager.Instance.model.member_positions.baby then
            color_str = "#F98AD6"
        end
        return string.format("%s <color='%s'>%s</color>",  sourceStr, color_str, post)
    end
    return sourceStr
end

function ChatManager:IsSheild(rid, platform, zone_id)
    local key = string.format("%s_%s_%s", rid, platform, zone_id)
    return ShieldManager.Instance:CheckIsSheild(key)
end

-- -------------------------------------------------------
-- 鉴于抢答活动改成了日常，怀疑是刷太快导致客户端卡
-- 故在抢答期间，对收协议做一个冷却处理，非法的丢弃
-- 但是协议是已经收了，这样做无法优化刷协议造成的卡顿
-- hosr 2016-12-16
-- -------------------------------------------------------
function ChatManager:NeedFilter()
    if NationalDayManager.Instance.model.questionData ~= nil and NationalDayManager.Instance.model.questionData.status == 1 then
        return true
    end
    return false
end

-- 请求新表情包
function ChatManager:Send10428()
    self:Send(10428, {})
end

function ChatManager:On10428(data)
    self.miniFaceDic = {}
    self.bigFaceDic = {}
    for _,v in ipairs(data.m_list) do
        self.miniFaceDic[v.val] = 1
    end
    for _,v in ipairs(data.b_list) do
        self.bigFaceDic[v.val] = 1
    end
    EventMgr.Instance:Fire(event_name.new_face_update)
end

function ChatManager:On10432(data)
    -- BaseUtils.dump(data, "On10432")
    EventMgr.Instance:Fire(event_name.message_send_success, data)
    if data.code == 10400 and data.flag == 0 then
        local channel = data.channel
        if channel == MsgEumn.ChatChannel.World then
            self.worldCd = 0
        elseif channel == MsgEumn.ChatChannel.Scene then
            self.sceneCd = 0
        elseif channel == MsgEumn.ChatChannel.MixWorld then
            self.mixworldCd = 0
        elseif channel == MsgEumn.ChatChannel.Activity or channel == MsgEumn.ChatChannel.Activity1 then
            self.activityCd = 0
        end
    end
end

-- 登录初始化
function ChatManager:RequestInitData()
    self:Send10428()
end
