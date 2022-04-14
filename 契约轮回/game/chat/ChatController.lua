require('game.chat.RequireChat')
ChatController = ChatController or class("ChatController", BaseController)
local ChatController = ChatController

function ChatController:ctor()
    ChatController.Instance = self

    self.model = ChatModel.GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function ChatController:dctor()
    if self.events then
        for i, v in pairs(self.events) do
            GlobalEvent:RemoveListener(v)
        end
        self.events = nil
    end
end

function ChatController:GetInstance()
    if not ChatController.Instance then
        ChatController.new()
    end
    return ChatController.Instance
end

function ChatController:GameStart()
    local function call_back()
        self:RequestOffMsg()
        self:RequestMarQuee()
        self:LoadSazi()
        self:LoadEmoji()
        self.model:AddLocalMarquee()
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Low)
end

--加载表情
function ChatController:LoadEmoji()
    self.model.emoji_list["emoji_image"] = {}
    for k, v in pairs(Config.db_emoji) do
        local list = String2Table(v.images)[1]
        for i=1, #list do
            local assetname = list[i]
            local function call_back(objs)
                self.model.emoji_list["emoji_image"][assetname] = objs[0]
            end
            lua_resMgr:LoadSprite(self, 'emoji_image', assetname, call_back)
        end
    end
end

function ChatController:LoadSazi()
    local arr_spirite = {"saizi_1_2","saizi_2_2","saizi_3_2","saizi_4_2",
        "saizi_5_2","saizi_6_2","saizi_7_2","saizi_8_2","saizi_9_2",
    "saizi_1","saizi_2","saizi_3","saizi_4","saizi_5","saizi_6"}
    
    for i=1, #arr_spirite do
        local function call_back(objs)
            self.model.saizi_list[i] = objs[0]
        end
        lua_resMgr:LoadSprite(self, 'saizi_image', arr_spirite[i], call_back)
    end
end

function ChatController:AddOpenChatPanelEvent()
    local function callBack (channel)
        ChatModel.GetInstance().openPanelChannel = channel
        lua_panelMgr:GetPanelOrCreate(ChatPanel):Open()
    end

    GlobalEvent:AddListener(ChatEvent.OpenChatPanel, callBack)
end

function ChatController:RegisterAllProtocal()
    self.pb_module_name = "pb_1300_chat_pb"
    self:RegisterProtocal(proto.CHAT_CHANNEL, self.HandleChatChannel)
    self:RegisterProtocal(proto.CHAT_ITEM, self.HandleGoodsInfo)
    self:RegisterProtocal(proto.GAME_MARQUEE, self.HandleMarQuee)
    self:RegisterProtocal(proto.GAME_MARQUEE_UPDATE, self.HandleMarQueeUpdate)
end

function ChatController:AddEvents()
    self:AddOpenChatPanelEvent()
    self.events = {}
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.AutoSendTextMsg, handler(self, self.AutoSendMsg))
	self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.AutoUnionSendTextMsg, handler(self, self.AutoUnionSendMsg))

    local function call_back(marquee)
        if marquee then
            self.model:AddMarqueePanel(marquee)
        end
        if not lua_panelMgr:GetPanel(MarqueePanel) then
            if self.model.marquee_panels[1] then
                local marquee2 = table.remove(self.model.marquee_panels, 1)
                lua_panelMgr:GetPanelOrCreate(MarqueePanel):Open(marquee2)
            end
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.OpenMarqueePanel, call_back)

    local function call_back()
        self.model:AddLocalMarquee()
    end
    self.events[#self.events+1] = GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)
end

function ChatController:RequestSendChat(channel_id, type_id, content, items, to_role_id)
    if not self:CheckLimit(channel_id) then
        return
    end
    --判断是否跨服
    if not self:CheckScene(channel_id) then
        return
    end
    content = string.gsub(content, "%%", "%%%%")
    local pb = self:GetPbObject("m_chat_channel_tos")
    pb.channel_id = channel_id
    pb.type_id = type_id
    -- 
    if PlatformManager:IsCN() then
        pb.content = FilterWords:GetInstance():toSafe(content)
    else
        pb.content = content
    end

    items = items or {}
    for i = 1, #items do
        --local info = Table2String(items[i])

        pb.uids:append(items[i].uid)
    end

    if to_role_id then
        pb.to_role_id = to_role_id
    end

    self:WriteMsg(proto.CHAT_CHANNEL, pb)
end

function ChatController:HandleChatChannel()
    local data = self:ReadMsg("m_chat_channel_toc")

    GlobalEvent:Brocast(ChatEvent.ReceiveMessage, data)
end

function ChatController:RequestGoodsInfo(id)
    local pb = self:GetPbObject("m_chat_item_tos")
    pb.id = id
    self:WriteMsg(proto.CHAT_ITEM, pb)
end

function ChatController:HandleGoodsInfo()
    local data = self:ReadMsg("m_chat_item_toc")

    GlobalEvent:Brocast(ChatEvent.ChatGoodsInfo, data.item)
end

function ChatController:AutoSendMsg(text)
    self:RequestSendChat(2, 0, text, {})
end --Union

function ChatController:AutoUnionSendMsg(text)
	self:RequestSendChat(6, 0, text, {})
end 

--获取离线信息
function ChatController:RequestOffMsg()
    local pb = self:GetPbObject("m_chat_off_msg_tos")
    self:WriteMsg(proto.CHAT_OFF_MSG, pb)
end

--获取跑马灯公告
function ChatController:RequestMarQuee()
    local pb = self:GetPbObject("m_game_marquee_tos", "pb_1000_game_pb")
    self:WriteMsg(proto.GAME_MARQUEE, pb)
end

function ChatController:HandleMarQuee()
    local data = self:ReadMsg("m_game_marquee_toc", "pb_1000_game_pb")
    self.model:AddMarquee(data.list)
end

function ChatController:HandleMarQueeUpdate()
    local data = self:ReadMsg("m_game_marquee_update_toc", "pb_1000_game_pb")
    self.model:UpdateMarquee(data)
end

--检查发言限制
function ChatController:CheckLimit(channel)
    if channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD then
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        local need_level = String2Table(Config.db_game["world_chat_lv"].val)[1]
        if level < need_level then
            local lv = GetLevelShow(need_level)
            Notify.ShowText(string.format("World Channel Chat needs Lv.%s", lv))
            return false
        end
    end
    return true
end

function ChatController:IsCrossScene()
    local scene_id = SceneManager:GetInstance():GetSceneId()
    return SceneManager:GetInstance():IsCrossScene(scene_id)
end

function ChatController:CheckScene(channel)
    if self:IsCrossScene()
      and channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE
      and channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD
      and channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P
      and channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
        Notify.ShowText("You can't talk in this channel, fail to chat")
        return false
    end
    return true
end