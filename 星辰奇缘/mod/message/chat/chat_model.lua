ChatModel = ChatModel or BaseClass(BaseModel)

function ChatModel:__init()

    self.path = "prefabs/ui/chat/chatcanvas.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.chat_window_res, type = AssetType.Dep},
        {file = AssetConfig.chat_prefix, type = AssetType.Dep},
    }
    --创建加载wrapper
    self.assetWrapper = AssetBatchWrapper.New()
    local func = function()
        if self.assetWrapper == nil then return end
        self.chatCanvas = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
        self.chatCanvas.name = "ChatCanvas"
        UIUtils.AddUIChild(ctx.CanvasContainer, self.chatCanvas)
        self.chatCanvas.transform.localPosition = Vector3(0, 0, 500)
        self.chatCanvasRect = self.chatCanvas:GetComponent(RectTransform)

        self.speech = MsgSpeech.New(self, function(msg) self:ConvertMsgBack(msg) end)

        self.assetWrapper:ClearMainAsset()

        SingManager.Instance.model:GetLocalAll()
    end
    self.assetWrapper:LoadAssetBundle(self.resList, func)

    self.chatWindow = nil
    self.chatMini = nil
    self.chatVoiceTips = nil
    self.listener = function() self:SceneLoad() end
    EventMgr.Instance:AddListener(event_name.scene_load, self.listener)

    self.historyTab = {
        [MsgEumn.ChatChannel.World] = {},
        [MsgEumn.ChatChannel.Team] = {},
        [MsgEumn.ChatChannel.Scene] = {},
        [MsgEumn.ChatChannel.Guild] = {},
        [MsgEumn.ChatChannel.Private] = {},
        [MsgEumn.ChatChannel.Group] = {},
        [MsgEumn.ChatChannel.System] = {},
        [MsgEumn.ChatChannel.MixWorld] = {},
        [MsgEumn.ChatChannel.Activity] = {},
        [MsgEumn.ChatChannel.Activity1] = {},
        [MsgEumn.ChatChannel.Camp] = {},
    }

    -- 登录时没创建好，服务端发了一堆
    self.miniAppendList = {}

    -- 置顶信息面版
    self.topPanelList = {}

    -- 语音数据
    self.clipTab = {}

    -- 当前缓存id
    self.currentCacheId = 0

    self.voiceData = VoiceData.New()

    -- 聊天倒计时
    self.voiceMaxTime = 15000
    self.voiceTimeId = 0

    -- 大面板是否显
    self.isChatShow = false

    -- 添加元素缓存,发送清空
    self.appendElementCache = {}

    self.bubble_id = 0 -- 当前使用的聊天旗袍
    self.prefix_id = 0 -- 当前使用的聊天前缀
end

function ChatModel:__delete()
    if self.chatWindow then
        self.chatWindow:DeleteMe()
        self.chatWindow = nil
    end

    if self.chatMini then
        self.chatMini:DeleteMe()
        self.chatMini = nil
    end

    if self.chatVoiceTips ~= nil then
        self.chatVoiceTips:DeleteMe()
        self.chatVoiceTips = nil
    end
end

function ChatModel:ShowCanvas(bool)
    if bool then
        self.chatCanvasRect.anchoredPosition = Vector2.zero

        -- BaseUtils.ChangeLayersRecursively(self.chatCanvas.transform, "UI")
        -- if self.raycaster == nil then
        --     self.raycaster = self.chatCanvas:GetComponent(GraphicRaycaster)
        -- end
        -- self.raycaster.enabled = true
    else
        self.chatCanvasRect.anchoredPosition = Vector2(4000, -4000)
---------------------
        -- BaseUtils.ChangeLayersRecursively(self.chatCanvas.transform, "Water")
        -- if self.raycaster == nil then
        --     self.raycaster = self.chatCanvas:GetComponent(GraphicRaycaster)
        -- end
        -- self.raycaster.enabled = false
    end

    if self.chatMini ~= nil then
        self.chatMini:ShowCanvas(bool)
    end

    if self.chatWindow ~= nil then
        self.chatWindow:ShowCanvas(bool)
    end
end

function ChatModel:ShowChatWindow(bool)
    if self.chatMini ~= nil then
        self.chatMini:ShowCanvas(bool)
    end
end

function ChatModel:SceneLoad()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.listener)
    self:ShowChatMini()
end

function ChatModel:ShowChatWindow(args)
    if self.chatWindow == nil then
        self.chatWindow = ChatPanel.New(self)
    end
    self.isChatShow = true
    self.chatWindow:Show(args)
end

function ChatModel:ShowChatMini(args)
    if self.chatMini == nil then
        self.chatMini = ChatMini.New(self)
    end
    self.chatMini:Show(args)
end

function ChatModel:HideChatWindow()
    if self.chatWindow ~= nil then
        self.chatWindow:Hiden()
    end
    self.isChatShow = false
end

function ChatModel:HideChatMini()
    if self.chatMini ~= nil then
        self.chatMini:TweenHide()
        -- self.chatMini:Hiden()
    end
end

function ChatModel:ShowMsg(data)
    if data.channel == MsgEumn.ChatChannel.Private then
        FriendManager.Instance:RecMsg(data)
        return
    elseif data.channel == MsgEumn.ChatChannel.Danmaku then
        DanmakuManager.Instance:AddNewMsg(data)
        return
    end
    if CombatManager.Instance.isFighting and CombatManager.Instance.controller ~= nil and data.channel ~= MsgEumn.ChatChannel.Guild and data.channel ~= MsgEumn.ChatChannel.World  then
        local BubbleID = 0
        if data.special ~= nil then
            for i,v in ipairs(data.special) do
                if v.type == MsgEumn.SpecialType.Bubble then
                    BubbleID = v.val
                end
            end
        end
        if data.showType == MsgEumn.ChatShowType.Voice then
            CombatManager.Instance.controller:ShowMemberMsg(data.rid, data.platform, data.zone_id, data.text, BubbleID)
        else
            CombatManager.Instance.controller:ShowMemberMsg(data.rid, data.platform, data.zone_id, data.msg, BubbleID)
        end
    end
    if data.channel == MsgEumn.ChatChannel.Team then
        if data.showType == MsgEumn.ChatShowType.Voice then
            WorldChampionManager.Instance.model:ShowMemberMsg(data.rid, data.platform, data.zone_id, data.text, BubbleID)
            UnlimitedChallengeManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.text, BubbleID)
            TeamDungeonManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.text, BubbleID)
            CrossArenaManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.text, BubbleID)
        else
            WorldChampionManager.Instance.model:ShowMemberMsg(data.rid, data.platform, data.zone_id, data.msg, BubbleID)
            UnlimitedChallengeManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.msg, BubbleID)
            TeamDungeonManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.msg, BubbleID)
            CrossArenaManager.Instance.model:ShowMsg(data.rid, data.platform, data.zone_id, data.msg, BubbleID)
        end
    end

    if data.showType == MsgEumn.ChatShowType.Voice then
        CrossArenaManager.Instance.model:ShowMsg(data.channel, data.rid, data.platform, data.zone_id, data.text, BubbleID)
    else
        CrossArenaManager.Instance.model:ShowMsg(data.channel, data.rid, data.platform, data.zone_id, data.msg, BubbleID)
    end

    local role = RoleManager.Instance.RoleData
    if data.channel == MsgEumn.ChatChannel.MixWorld
        and role.event ~= RoleEumn.Event.WarriorReady and role.event ~= RoleEumn.Event.Warrior
        and role.event ~= RoleEumn.Event.GuildFightReady and role.event ~= RoleEumn.Event.GuildFight and role.event ~= RoleEumn.Event.Masquerade 
        and role.event ~= RoleEumn.Event.CanYonReady and role.event ~= RoleEumn.Event.CanYon then
        if self.chatMini ~= nil and self.chatMini.isInit then
            self.chatMini:ShowMsg(BaseUtils.copytab(data))
        else
            table.insert(self.miniAppendList, data)
        end
    elseif data.channel ~= MsgEumn.ChatChannel.MixWorld then
        if self.chatMini ~= nil and self.chatMini.isInit then
            self.chatMini:ShowMsg(BaseUtils.copytab(data))
        else
            table.insert(self.miniAppendList, data)
        end
    end

    if self.chatWindow ~= nil and self.chatWindow.isInit then
        self.chatWindow:ShowMsg(BaseUtils.copytab(data))
    else
        self:AppendHistoryMsg(BaseUtils.copytab(data))
    end
end

function ChatModel:UpdateMatchMsg()
    if self.chatWindow ~= nil then
        self.chatWindow:UpdateMatch()
    end
    if self.chatMini ~= nil and self.chatMini.isInit then
        self.chatMini:UpdateMatch()
    end
end

function ChatModel:UpdateHelp()
    if self.chatWindow ~= nil then
        self.chatWindow:UpdateHelp()
    end
    if self.chatMini ~= nil and self.chatMini.isInit then
        self.chatMini:UpdateHelp()
    end
end

function ChatModel:UpdateCrossArena()
    if self.chatWindow ~= nil then
        self.chatWindow:UpdateCrossArena()
    end
    if self.chatMini ~= nil and self.chatMini.isInit then
        self.chatMini:UpdateCrossArena()
    end
end

-- ---------------------------------------
-- 界面未打开记录历史消息
-- ---------------------------------------
function ChatModel:AppendHistoryMsg(data)
    local tab = self.historyTab[data.channel]
    table.insert(tab, data)
    local len = #tab - 30
    if len > 0 then
        for i = 1,len do
            table.remove(tab, i)
        end
    end
end

function ChatModel:HasHistoryMsg(channel)
    local tab = self.historyTab[channel]
    if tab ~= nil and #tab > 0 then
        return true
    end
    return false
end

function ChatModel:GetHistoryMsg(channel)
    local back = BaseUtils.copytab(self.historyTab[channel])
    self.historyTab[channel] = {}
    return back
end

-- ---------------------------------------
-- 界面未打开记录历史消息
-- ---------------------------------------
function ChatModel:AppendTopPanelMsg(data)
    local addMark = true
    for i,v in ipairs(self.topPanelList) do
        if v.id == data.id then
            self.topPanelList[i] = data
            addMark = false
        end
    end
    if addMark then
        table.insert(self.topPanelList, data)
    end
end

function ChatModel:DeleteTopPanelMsg(id)
    local index = 0
    for i,v in ipairs(self.topPanelList) do
        if v.id == id then
            index = i
        end
    end
    if index ~= 0 then
        table.remove(self.topPanelList, index)
    end
end

function ChatModel:GetTopPanelMsg(channel)
    -- if channel == MsgEumn.ChatChannel.Guild then
    --     return {panelType = 1}
    -- end
    if #self.topPanelList > 0 then
        for i,v in ipairs(self.topPanelList) do
            if (v.channelList == nil or table.containValue(v.channelList, channel)) and (v.time == nil or v.time > BaseUtils.BASE_TIME) then
                return v
            end
        end
    end
    return nil
end

function ChatModel:GetTopPanelMsgById(id)
    if #self.topPanelList > 0 then
        for i,v in ipairs(self.topPanelList) do
            if v.id == id and (v.time == nil or v.time > BaseUtils.BASE_TIME) then
                return v
            end
        end
    end
    return nil
end

-- 插入字符串到输入框,历史记录
function ChatModel:AppendInput(str)
    if self.chatWindow ~= nil then
        self.chatWindow:AppendInput(str)
    end
end

-- 点击扩展元素后插入到输入框
-- 表情：支持多个
-- 任务：点击就发出去
-- 其他：同类只有一个，如果是自己，则过滤掉
function ChatModel:AppendInputElement(element)
    if self.chatWindow ~= nil then
        self.chatWindow:AppendInputElement(element)
    else
        table.insert(self.appendElementCache, element)
    end
end

-- ---------------------
-- 语音提示
-- ---------------------
-- 语音按钮操作
function ChatModel:DownVoice(channel, rid, zone_id, platform)
    if SdkManager.Instance.platform ~= RuntimePlatform.IPhonePlayer and SdkManager.Instance.platform ~= RuntimePlatform.Android then
        Log.Debug("暂不支持语音")
        return
    end

    local key = string.format("%s_%s_%s", rid, platform, zone_id)
    if ShieldManager.Instance:CheckIsSheild(key) then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已将对方屏蔽，无法发送语音，请先<color='#ffff00'>取消屏蔽</color>。"))
        return
    end

    if RoleManager.Instance.RoleData.lev < MsgEumn.ChannelLimit[channel] then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才能在<color='#ffff00'>%s频道</color>说话，加油升级哦！"), MsgEumn.ChannelLimit[channel], MsgEumn.ChatChannelName[channel]))
        return
    end

    if channel == MsgEumn.ChatChannel.World and ChatManager.Instance.worldCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), ChatManager.Instance.worldCd, MsgEumn.ChatChannelName[channel]))
        return
    end

    if channel == MsgEumn.ChatChannel.Scene and ChatManager.Instance.sceneCd ~= 0 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then 
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.sceneCd, TI18N("峡谷")))
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), self.sceneCd, MsgEumn.ChatChannelName[channel]))
        end
        return
    end

    if channel == MsgEumn.ChatChannel.Activity and ChatManager.Instance.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), ChatManager.Instance.activityCd, MsgEumn.ChatChannelName[channel]))
        return
    end

    if channel == MsgEumn.ChatChannel.Activity1 and ChatManager.Instance.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), ChatManager.Instance.activityCd, MsgEumn.ChatChannelName[channel]))
        return
    end

    if channel == MsgEumn.ChatChannel.Camp and ChatManager.Instance.activityCd ~= 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>秒后可%s发言"), ChatManager.Instance.activityCd, MsgEumn.ChatChannelName[channel]))
        return
    end

    self.voiceDown = true
    self:ShowVoiceSendTips()

    self.sureId = LuaTimer.Add(200, function() self:SureDownVoice(channel, rid, zone_id, platform) end)

    if BaseUtils.CSVersionToNum() == 50607 then
        NoticeManager.Instance:FloatTipsByString(TI18N("语音技术由科大讯飞支持提供"))
    end
end

-- 防止摸一下的情况
function ChatModel:SureDownVoice(channel, rid, zone_id, platform)
    -- self:StopChat()
    SoundManager.Instance:StopChat()
    LuaTimer.Add(100, function() self:BeginVoiceRecord(channel, rid, zone_id, platform) end)
    -- self:BeginVoiceRecord(channel, rid, zone_id, platform)
end

function ChatModel:UpVoice()
    if self.sureId ~= nil then
        LuaTimer.Delete(self.sureId)
        self.sureId = nil
    end
    if self.voiceDown then
        self.voiceDown = false
        self:HideVoice()
        if self.voiceEnter then
            if self.hasRecord then
                self:EndVoiceRecord()
            end
        else
            self:CancelVoiceRecord()
        end
    end
end

function ChatModel:ExitVoice()
    self.voiceEnter = false
    self:ShowVoiceCancelTips()
end

function ChatModel:EnterVoice()
    self.voiceEnter = true
    if self.voiceDown then
        self:ShowVoiceSendTips()
    end
end

function ChatModel:ShowVoiceSendTips()
    if self.chatVoiceTips == nil then
        self.chatVoiceTips = ChatVoiceTips.New(self)
    end
    self.chatVoiceTips:Show()
end

function ChatModel:ShowVoiceCancelTips()
    if self.chatVoiceTips ~= nil then
        self.chatVoiceTips:ShowCancel()
    end
end

function ChatModel:HideVoice()
    if self.chatVoiceTips ~= nil then
        self.chatVoiceTips:Hiden()
    end
end

-- ---------------------
-- 语音录制
-- ---------------------
function ChatModel:BeginVoiceRecord(channel, rid, zone_id, platform)
    self.hasRecord = true
    ChatManager.Instance.IsRecording = true

    if self.voiceData ~= nil then
        self.voiceData.byteData = nil
        self.voiceData.rid = rid or RoleManager.Instance.RoleData.id
        self.voiceData.zone_id = zone_id or RoleManager.Instance.RoleData.zone_id
        self.voiceData.platform = platform or RoleManager.Instance.RoleData.platform
    end
    if channel == MsgEumn.ChatChannel.Group then
        self.voiceData.group_id = rid
        self.voiceData.group_platform = platform
        self.voiceData.group_zone_id = zone_id
    end

    if self.voiceTimeId ~= 0 then
        LuaTimer.Delete(self.voiceTimeId)
        self.voiceTimeId = 0
    end
    self.voiceTimeId = LuaTimer.Add(self.voiceMaxTime, function() self:VoiceTimeOut() end)

    if self.voicePlaying then
        self:StopChat()
    else
        self.speech:BeforePlay()
    end

    self.voiceChannel = channel
    self.recordTime = os.time()
    self.speech:StartRecord()
    ChatManager.Instance:Send10405()
end

function ChatModel:ResetIsMute()
    self.speech:AfterPlay()
end

function ChatModel:VoiceTimeOut()
    if self.voiceTimeId ~= 0 then
        LuaTimer.Delete(self.voiceTimeId)
        self.voiceTimeId = 0
    end
    self:HideVoice()
    self:EndVoiceRecord()
end

function ChatModel:EndVoiceRecord()
    self.hasRecord = false
    ChatManager.Instance.IsRecording = false
    if self.voiceTimeId ~= 0 then
        LuaTimer.Delete(self.voiceTimeId)
        self.voiceTimeId = 0
    end

    local space = os.time() - self.recordTime
    if space < 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("录音失败,时间太短"))
        self.speech:Cancel()
    else
        local audioclip = self.speech:EndRecord()
        if audioclip ~= nil then
            if self.currentCacheId == 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("网络似乎有问题,请重试"))
                GameObject.DestroyImmediate(audioclip)
                audioclip = nil
            else
                self.voiceData.id = self.currentCacheId
                self.voiceData.cacheId = self.currentCacheId
                self.voiceData.channel = self.voiceChannel
                self.voiceData.time = space
                -- self.voiceData.byteData = self.speech:Compress(self.speech.wavFilePath, self.speech.spxFilePath)
                self.voiceData.byteData = self.speech:Compress()
                self.voiceData.clip = audioclip
                -- self:AddAudioClip(self.voiceData.clip, self.voiceData.cacheId, self.voiceData.platform, self.voiceData.zone_id)
                self.currentCacheId = 0
                self.voiceData.msg = TI18N("没有翻译结果")
            end
        end
    end
    self:ResetIsMute()
end

function ChatModel:CancelVoiceRecord()
    ChatManager.Instance.IsRecording = false
    self.speech:Cancel()
    if self.hasRecord then
        self:ResetIsMute()
    end
end

-- 语音翻译结果返回
function ChatModel:ConvertMsgBack(result)
    if self.voiceData ~= nil and self.voiceData.byteData ~= nil then
        if result == "" then
            result = TI18N("没有翻译结果")
        end
        self.voiceData.msg = result
        if self.voiceData.channel == MsgEumn.ChatChannel.Private then
            ChatManager.Instance:Send10411(self.voiceData)
        elseif self.voiceData.channel == MsgEumn.ChatChannel.Group then
            ChatManager.Instance:Send10425(self.voiceData)
        else
            ChatManager.Instance:Send10403(self.voiceData)
        end
    end
end

function ChatModel:SelfCacheIdBack(cacheId)
    self.currentCacheId = cacheId
end

function ChatModel:Play(clip)
    if clip == nil then
        return
    end
    if self.voicePlaying and ChatManager.Instance.startAutoPlay then
        Log.Debug("当前播放中")
        return
    end
    if not self.voicePlaying then
        self.voicePlaying = true
        self.speech:BeforePlay()
    end
    SoundManager.Instance:PlayChat(clip)
    if self.playTimeId ~= nil then
        LuaTimer.Delete(self.playTimeId)
    end
    self.playTimeId = LuaTimer.Add(clip.length * 1000 + 500, function() self:PlayEnd() end)
end

function ChatModel:PlayEnd()
    self.playTimeId = nil
    self.voicePlaying = false
    self.currentPlayId = 0
    self.speech:AfterPlay()
    ChatManager.Instance.startAutoPlay = false
end

function ChatModel:StopChat()
    if self.playTimeId ~= nil then
        LuaTimer.Delete(self.playTimeId)
    end
    -- SoundManager.Instance:StopChat()
    self.playTimeId = nil
    self.voicePlaying = false
    self.currentPlayId = 0
    ChatManager.Instance.startAutoPlay = false
end

function ChatModel:GetCacheInfo(cacheId, platform, zone_id)
    local clipInfo = nil
    for i,info in ipairs(self.clipTab) do
        if info.id == cacheId and info.platform == platform and info.zone_id == zone_id then
            clipInfo = info
            break
        end
    end
    return clipInfo
end

-- 播放
function ChatModel:PlayVoice(chatData)
    if SdkManager.Instance.platform ~= RuntimePlatform.IPhonePlayer and SdkManager.Instance.platform ~= RuntimePlatform.Android then
        Log.Debug("暂不支持语音播放")
        return
    end

    -- 省点模式下不播放
    if not SleepManager.Instance.IsWakeUp then
        Log.Debug("省点模式下不播放")
        return
    end

    -- 静音不播放
    if self.speech:IsMute() then
        Log.Debug("静音不播放语音")
        return
    end

    ChatManager.Instance.startAutoPlay = false
    if chatData.cacheId == 0 then
        Log.Debug("缓存数据不存在 0")
        NoticeManager.Instance:FloatTipsByString(TI18N("语音数据已过期"))
        return
    end

    local clipInfo = self:GetCacheInfo(chatData.cacheId, chatData.platform, chatData.zone_id)
    if clipInfo ~= nil then
        if self.chatPlayer == nil then
            self.chatPlayer = SoundManager.Instance.playerList[AudioSourceType.Chat]
        end
        if self.chatPlayer:IsPlaying() and chatData.cacheId == self.currentPlayId then
            self.chatPlayer:Stop()
            self:PlayEnd()
        else
            self.currentPlayId = chatData.cacheId
            self:Play(clipInfo.clip)
        end
    else
        ChatManager.Instance:Send10404(chatData.platform, chatData.zone_id, chatData.cacheId)
    end
end

function ChatModel:GetAudioClip(dat)
    local clip = self.speech:GetAudioClip(dat.voice)
    if clip ~= nil then
        self:AddAudioClip(clip, dat.id, dat.platform, dat.zone_id)
    end
    return clip
end

function ChatModel:AddAudioClip(clip, id, platform, zone_id)
    if #self.clipTab == 10 then
        table.remove(self.clipTab, 1)
    end
    table.insert(self.clipTab, {clip = clip , id = id, platform = platform, zone_id = zone_id})
end

function ChatModel:DelAudioClip(cacheId, platform, zone_id)
    local delIndex = 0
    for i,clipInfo in ipairs(self.clipTab) do
        if clipInfo.id == cacheId and clipInfo.platform == platform and clipInfo.zone_id == zone_id then
            delIndex = i
            break
        end
    end
    if delIndex ~= 0 then
        local del = table.remove(self.clipTab, delIndex)
        GameObject.DestroyImmediate(del.clip)
        del = nil
    end
end

-- --------------------------------
-- 频道倒计时
-- --------------------------------
function ChatModel:OnTick()
    if self.chatWindow ~= nil and self.chatWindow.gameObject ~= nil then
        self.chatWindow:OnTick()
    end
end

function ChatModel:ClearAll()
    self:HideChatWindow()

    self.historyTab = {
        [MsgEumn.ChatChannel.World] = {},
        [MsgEumn.ChatChannel.Team] = {},
        [MsgEumn.ChatChannel.Scene] = {},
        [MsgEumn.ChatChannel.Guild] = {},
        [MsgEumn.ChatChannel.Private] = {},
        [MsgEumn.ChatChannel.Group] = {},
        [MsgEumn.ChatChannel.System] = {},
        [MsgEumn.ChatChannel.MixWorld] = {},
        [MsgEumn.ChatChannel.Activity] = {},
        [MsgEumn.ChatChannel.Activity1] = {},
        [MsgEumn.ChatChannel.Camp] = {},
    }

    self.miniAppendList = {}

    self.topPanelList = {}

    self.chatCanvas:SetActive(true)
    if self.chatMini ~= nil then
        self.chatMini:ClearAll()
    end

    if self.chatWindow ~= nil then
        self.chatWindow:ClearAll()
    end

    for i,info in ipairs(self.clipTab) do
        GameObject.DestroyImmediate(info.clip)
    end
    self.clipTab = {}

    -- 当前缓存id
    self.currentCacheId = 0
    if self.voiceData ~= nil then
        self.voiceData.byteData = nil
    end

    self.appendElementCache = {}
end
