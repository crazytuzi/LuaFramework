---
--- Created by R2D2.
--- DateTime: 2019/1/19 11:44
---
require('game.notice.RequireNotice')
NoticeController = NoticeController or class("NoticeController", BaseController)
local NoticeController = NoticeController

function NoticeController:ctor()
    NoticeController.Instance = self

    self.events = {}
    self.LoadComponentFinish = false
    self.model = NoticeModel.GetInstance()
    self:AddEvents()
    self:RegisterAllProtocol()

    if AppConfig.Debug then
        ---开发期，没有选服界面，直接在打开时请求
        self:RequestOnlineNotice()
    end
end

function NoticeController:dctor()
    self.LoadComponentFinish = false
    GlobalEvent:RemoveTabListener(self.events)
end

function NoticeController:GetInstance()
    if not NoticeController.Instance then
        NoticeController.new()
    end
    return NoticeController.Instance
end

-- overwrite
function NoticeController:GameStart()

end

function NoticeController:RequestOnlineNotice()
     if IsIOSExamine() or LoginModel.IsIOSExamine then
        return
    end
    local url
    local channelId = LoginModel:GetInstance():GetChannelId()

    if AppConfig.Debug then
        url = "http://admin.xingwan.com/api/server/notice?game_channel_id=" .. channelId
    else
        url = AppConfig.Url .. "api/server/notice?game_channel_id=" .. channelId
    end

    local function call_back(data)
        if ((not data) or #data == 0) then
            data = nil
        end
        self.model:SetOnlineNotice(data)

        if (self.LoadComponentFinish and data) then
            lua_panelMgr:GetPanelOrCreate(NoticePanel):Open()
        end

        GlobalEvent:Brocast(NoticeEvent.Notice_ResponseNoticeEvent)
    end

    DebugLog("Start Request Notice: " ..  Time.realtimeSinceStartup)
    HttpManager:GetInstance():ResponseGet(url, call_back)
    --HttpManager:GetInstance():HttpGetRequest(url, call_back)
end

function NoticeController:AddEvents()
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.LoadComponent, handler(self, self.OnLoadComponent))
    --self.events[#self.events + 1] = GlobalEvent:AddListener(NoticeEvent.Notice_OpenPanelEvent, handler(self, self.OnOpenPanel))
end

function NoticeController:OnLoadComponent(value)
    if value >= 1 then
        self.LoadComponentFinish = true
    end

    ---开发期，没有选服界面，直接在打开时请求
    if AppConfig.Debug then
        if self.model.OnlineNotice and self.LoadComponentFinish then
            lua_panelMgr:GetPanelOrCreate(NoticePanel):Open()
        end
    end
end

function NoticeController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
end

