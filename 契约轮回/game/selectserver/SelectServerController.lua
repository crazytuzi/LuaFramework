---
--- Created by  Administrator
--- DateTime: 2019/2/20 16:29
---
require("game.selectserver.RequireSelectPanel")
SelectServerController = SelectServerController or class("SelectServerController", BaseController)
local SelectServerController = SelectServerController
function SelectServerController:ctor()
    SelectServerController.Instance = self
    self.model = SelectServerModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
   -- self:RequsetServerList()
end

function SelectServerController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SelectServerController:GetInstance()
    if not SelectServerController.Instance then
        SelectServerController.new()
    end
    return SelectServerController.Instance
end

function SelectServerController:AddEvents()
   -- GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))
end

function SelectServerController:Test(keyCode)
    if keyCode == InputManager.KeyCode.G then
        lua_panelMgr:GetPanelOrCreate(SelectServerPanel):Open()
    end
end

function SelectServerController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
end

-- overwrite
function SelectServerController:GameStart()

end

function SelectServerController:RequsetServerList()
    -- 上报数据和请求列表一起做
    self:RequsetChurnRate()

    local url =  AppConfig.Url .. "api/server/list" 
    local game_channel_id = LoginModel:GetInstance():GetChannelId()
    local info = LoginModel:GetInstance().sdk_login_info.loginInfo
    local uid = ""
    if info then
        uid = info.uid
    end
    -- game_channel_id = "111648"
    -- uid = "1104209460"
    local platform = "android"
    if PlatformManager:GetInstance():IsIos() then
        platform = "ios"
    end
    if PlatformManager:GetInstance():IsIos() and AppConfig.iosver then
        url = string.format("%s?game_channel_id=%s&account=%s&platform=%s&iosver=%s",url,game_channel_id,uid,platform,AppConfig.iosver)
    else
        url = string.format("%s?game_channel_id=%s&account=%s&platform=%s",url,game_channel_id,uid,platform)
    end
    local function call_back(data)
        DebugLog("----------请求服务器列表成功----------- ",url)
        DebugLog('--LaoY SelectServerController.lua,line 62--',data and Table2String(data))
        self.model:SpiltServerList(data)
        GlobalEvent:Brocast(SelectServerEvent.SelectServerList,data)
    end
    HttpManager:GetInstance():ResponseGet(url,call_back)
end


function SelectServerController:RequsetChurnRate()
    local url =  AppConfig.Url .. "/api/role/create_role_churn_rate" 
    local game_channel_id = LoginModel:GetInstance():GetChannelId()
    local info = LoginModel:GetInstance().sdk_login_info.loginInfo
    local uid = ""
    if info then
        uid = info.uid
    end
    url = string.format("%s?account=%s&gcid=%s&progress=0",url,uid,game_channel_id)
    local function call_back()
        DebugLog("----------上报数据成功----------- ")
    end
    HttpManager:GetInstance():ResponseGet(url,call_back)
end