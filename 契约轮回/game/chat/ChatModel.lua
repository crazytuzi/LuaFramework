require("game.chat.ChatEvent")
ChatModel = ChatModel or class("ChatModel", BaseBagModel)
local ChatModel = ChatModel

ChatModel.WorldChannel = 1          --世界频道
ChatModel.AreaChannel = 2           --地区频道
ChatModel.CrossChannel = 3          --跨服频道
ChatModel.OrganizeChannel = 4       --招募频道
ChatModel.TeamChannel = 5           --队伍频道
ChatModel.UnionChannel = 6          --帮派频道
ChatModel.PrivateChannel = 99       --私聊频道
ChatModel.SystemChannel = 100       --系统频道
ChatModel.MaxChatCount = 30         --保留最多聊天纪录数量


--各频道聊天cd
ChatModel.channel_cd = {
    [ChatModel.WorldChannel] = 10,
    [ChatModel.AreaChannel] = 10,
    [ChatModel.CrossChannel] = 15,
    [ChatModel.OrganizeChannel] = 10,
    [ChatModel.TeamChannel] = 0,
    [ChatModel.UnionChannel] = 0,
    [ChatModel.PrivateChannel] = 0,
}

function ChatModel:ctor()
    ChatModel.Instance = self

    self:Reset()

    self:AddEvent()
    self.saizi_list = {}
    self.emoji_list = {}
end

function ChatModel:AddEvent()
    local function receive_call_back(data)
        if data.channel_id ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P
                and data.channel_id ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION then
            self:AddMsg(data)
        end
    end
    self.event_id = GlobalEvent:AddListener(ChatEvent.ReceiveMessage, receive_call_back)
end

function ChatModel:Reset()
    self.bagItems = {}
    self.channelMsgIsRead = {}                  --存放频道的消息是否可读
    local settors = self.channelSettors or {}
    for _, channel_settors in pairs(settors) do
        for _, settor in pairs(channel_settors) do 
            settor:destroy()
        end
    end
    self.channelSettors = {}
    self.chatSettorsInMainUI = {}
    self.msg_list_by_channel = {}
    self.item_list_by_channel = {}
    self.inlineManagerScps = {}
    self.inlineManagers = {}
    self.inlineMgrMainUI = nil
    self.inlineMgrMainUIScp = nil
    self.openPanelChannel = 1
    self.emojisOnePage = 12
    self.isLockScreen = false
    self.inlineManagerScp = nil
    self.inlineManagerScpButtom = nil
    self.marquees = {}
    if self.schedules then
        for _, v in pairs(self.schedules) do
            GlobalSchedule:Stop(v)
        end
    end
    self.schedules = {}
    if self.schedules_local then
        for _, v in pairs(self.schedules_local) do
            GlobalSchedule:Stop(v)
        end
    end
    self.schedules_local = {}
    if self.marquee_panels then
        for _, v in pairs(self.marquee_panels) do
            v:destroy()
        end
    end
    self.marquee_panels = {}
end

function ChatModel.GetInstance()
    if ChatModel.Instance == nil then
        ChatModel()
    end
    return ChatModel.Instance
end

function ChatModel:AddMsg(data)
    local channel_id = data.channel_id
    self.msg_list_by_channel[channel_id] = self.msg_list_by_channel[channel_id] or {}
    local msg_list = self.msg_list_by_channel[channel_id]
    local nums = table.nums(msg_list)
    if nums >= ChatModel.MaxChatCount then
        --local value,key = table.removebyindex(msg_list, 1)
        table.remove(msg_list, 1)
    end

    table.insert(msg_list, data)
    GlobalEvent:Brocast(ChatEvent.AddMsgItem, data)
end

function ChatModel:GetChannelItemsByChannel(channel)
    self.channelSettors[channel] = self.channelSettors[channel] or {}
    return self.channelSettors[channel]
end

function ChatModel:GetChannelItemsHeight(channel)
    local height = 0
    local settors = self.channelSettors[channel] or {}
    for i, v in pairs(settors) do
        height = height + v.height
    end

    return height
end

function ChatModel:GetMainUIChannelItemsHeight()
    local height = 0
    for k, v in pairs(self.chatSettorsInMainUI) do
        height = height + v.height
    end

    --height = height + (table.nums(self.chatSettorsInMainUI) - 1) * 5
    return height
end

function ChatModel:GetChannelItemsCount(channel)
    return table.nums(self.channelSettors[channel] or {})
end

function ChatModel:DeleteChannelItems(channel)

    if self.channelSettors then
        for i, v in pairs(self.channelSettors[channel] or {}) do
            v:destroy()
        end

        if channel then
            self.channelSettors[channel] = {}
        end
       
    end

   
end

function ChatModel:IsChannelHaveNotReadMsg(channel)
    local msg_list = self.msg_list_by_channel[channel] or {}
    for i = 1, #msg_list do
        if not msg_list[i].is_read then
            if channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
                if msg_list[i].sender ~= nil then
                    return true
                end
            elseif channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE then
                if msg_list[i].sender ~= nil then
                    return true
                end
            end
        end
    end
    return false
end

function ChatModel:SetChannelRead(channnel)
    local msg_list = self.msg_list_by_channel[channnel] or {}
    for i = 1, #msg_list do
        if msg_list[i] then
            msg_list[i].is_read = true
        end
    end
end

function ChatModel:GetChannelNotReadMsg(channnel)
    local count = 0
    for i, v in pairs(self.channelMsgIsRead[channnel]) do
        if not v then
            count = count + 1
        end
    end

    return count
end

--设置频道的某条信息是否 可读
function ChatModel:SetChannelMsgIsRead(channnel, time, isRead)
    self.channelMsgIsRead[channnel] = self.channelMsgIsRead[channnel] or {}
    self.channelMsgIsRead[channnel][time] = isRead
end

function ChatModel:GetBagItemDataByIndex(index)
    if self.bagItems[BagModel.bagId] ~= nil then
        return self.bagItems[BagModel.bagId][index]
    end
end

function ChatModel:GetBeastBagItemDataByIndex(...)
    if self.bagItems[BagModel.beast] ~= nil then
        return self.bagItems[BagModel.beast][index]
    end
end

function ChatModel:SendInScenePos(channel_id)
    local sceneId = SceneManager.Instance:GetSceneId()
    local sceneCfg = Config.db_scene[sceneId]
    if sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE then
        Notify.ShowText(ConfigLanguage.ChatChn.SceneCantSendMap)
    else
        local roleData = RoleInfoModel.Instance:GetMainRoleData()
        local x, y = SceneManager.GetInstance():GetBlockPos(roleData.coord.x, roleData.coord.y)
        local target = string.format("<color=#6ce19b>[<a href=mapPos_%s_%s_%s>%s%s,%s</a>]</color>", sceneId, x, y, sceneCfg.name, x, y)

        ChatController.GetInstance():RequestSendChat(channel_id, 0, target, {})
        --GlobalEvent:Brocast(ChatEvent.ClickMapPosition,target)
    end
end

function ChatModel:FriendSendScenePos(role_id)
    local sceneId = SceneManager.Instance:GetSceneId()
    local sceneCfg = Config.db_scene[sceneId]
    if sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE then
        Notify.ShowText(ConfigLanguage.ChatChn.SceneCantSendMap)
    else
        local roleData = RoleInfoModel.Instance:GetMainRoleData()
        local x, y = SceneManager.GetInstance():GetBlockPos(roleData.coord.x, roleData.coord.y)
        local target = string.format("<color=#6ce19b>[<a href=mapPos_%s_%s_%s>%s%s,%s</a>]</color>", sceneId, x, y, sceneCfg.name, x, y)

        ChatController:GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P, 0, target, {}, role_id)
        --ChatController.GetInstance():RequestSendChat(channel_id, 0, target, {})
        --GlobalEvent:Brocast(ChatEvent.ClickMapPosition,target)
    end
end

function ChatModel:IsContainEmojiName(emojiName)
    return Config.db_emoji[emojiName] ~= nil
end

function ChatModel:AddLocalMarquee()
    local open_days = LoginModel:GetInstance():GetOpenTime()
    local open_time_stamp = LoginModel.GetInstance():GetOpenStamp()
    local timeTab = os.date("*t", open_time_stamp)
    for k, v in pairs(Config.db_marquee) do
        if open_days >= v.start_days and open_days < v.end_days then
            local marquee = {}
            marquee.interval = v.interval
            marquee.id = v. id
            timeTab.day = timeTab.day + v.end_days
            timeTab.hour = 23
            timeTab.min = 59
            timeTab.sec = 59
            marquee.end_time = os.time(timeTab)
            marquee.content = v.content
            self:AddScheduleLocal(marquee)
        end
    end
end

function ChatModel:AddScheduleLocal(marquee)
    if self.schedules_local[marquee.id] then
        return
    end
    local now = os.time()
    local count = math.ceil((marquee.end_time - now) / marquee.interval)
    local function call_back()
        GlobalEvent:Brocast(ChatEvent.OpenMarqueePanel, marquee)
    end
    local schedule_id = GlobalSchedule:Start(call_back, marquee.interval, count - 1)
    self.schedules_local[marquee.id] = schedule_id
end

--增加跑马灯
function ChatModel:AddMarquee(marquee_list)
    for i = 1, #marquee_list do
        local marquee = marquee_list[i]
        self.marquees[marquee.id] = marquee
        self:AddSchedule(marquee)
    end
end

--更新跑马灯
function ChatModel:UpdateMarquee(data)
    local add = data.add
    local del = data.del
    if add then
        self.marquees[add.id] = add
        self:AddSchedule(add)
    end
    if del > 0 then
        self.marquees[del] = nil
        if self.schedules[del] then
            GlobalSchedule:Stop(self.schedules[del])
            self.schedules[del] = nil
        end
    end
end

function ChatModel:AddSchedule(marquee)
    local now = os.time()
    if now < marquee.start_time then
        local function call_back()
            self:AddSchedule2(marquee)
        end
        GlobalSchedule:StartOnce(call_back, marquee.start_time - now)
    elseif now >= marquee.start_time and now <= marquee.end_time then
        self:AddSchedule2(marquee)
    else
        if self.schedules[marquee.id] then
            GlobalSchedule:Stop(self.schedules[marquee.id])
        end
        self.marquees[marquee.id] = nil
    end
end

function ChatModel:AddSchedule2(marquee)
    if self.schedules[marquee.id] then
        return
    end
    local now = os.time()
    local count = math.ceil((marquee.end_time - now) / marquee.interval)
    local function call_back()
        GlobalEvent:Brocast(ChatEvent.OpenMarqueePanel, marquee)
    end
    local schedule_id = GlobalSchedule:Start(call_back, marquee.interval, count - 1)
    self.schedules[marquee.id] = schedule_id
end

function ChatModel:AddMarqueePanel(marquee)
    self.marquee_panels[#self.marquee_panels + 1] = marquee
end

function ChatModel:GetEmojiId(icon)
    for k, v in pairs(Config.db_emoji) do
        if v.icon == icon then
            return k
        end
    end
    return 0
end