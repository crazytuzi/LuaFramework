--
-- Author: LaoY
-- Date: 2018-07-11 16:29:03
--

-- require("common.tool");
-- require("common.define");
require("game/config/auto/db_server")
LoginPanel = LoginPanel or class("LoginPanel", BasePanel)
local LoginPanel = LoginPanel

function LoginPanel:ctor()
    self.abName = "login"
    self.assetName = "LoginPanel"
    self.layer = "UI"

    self.use_background = false
    self.change_scene_close = false
    self.logout_close = false
    self.use_open_sound = false

    self.global_event_list = {}

    self.model = LoginModel:GetInstance()

    silenceMgr:CheckOutPut(true)

end

function LoginPanel:dctor()
    self:StopSchedule()

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.serSchedule then
        GlobalSchedule.StopFun(self.serSchedule);
    end
    self.serSchedule = nil;
    if self.delaySchedule then
        GlobalSchedule:Stop(self.delaySchedule)
    end
    self.delaySchedule = nil

    self:ClearLoginBg()
    self:ClearLogoIcon()
end

function LoginPanel:Open()
    BasePanel.Open(self)
    self.model.is_first_connect = nil
end

local function random()
    math.newrandomseed()
    local name = tostring(math.random(9))
    for i = 1, 2 do
        local n = math.random(3) + 4
        for j = 1, n do
            local cur_n
            cur_n = math.random(10) - 1
            name = name .. cur_n
        end
    end
    return name
end

function LoginPanel:LoadCallBack()
    self.nodes = {
        "pc", "pc/account", "pc/account/account_default", "pc/account/account_text", "serverObj/loginBtn", "NoticeBtn",
        "pc/ip/ip_default", "pc/ip", "pc/ip/ip_text", "bg", "pc/btn_drop", "pc/btn_drop/name", "img_loding_bg", "img_loding_bg/img_loding", "img_loding_bg/text", "serverObj",
        "serverObj/server/server_bg", "serverObj/server/server_flag", "serverObj/server/server_name", "serverObj/testTex", "pc/TestloginBtn", "btn_login",
        "Text", "Text2", "logo",
        "btn_customer_service",
        "pc/btnChannel","pc/btnChannel/btnChannelName",
        "pc/btnChannelList","pc/btnChannel/btnChannelListName",
    }
    self:GetChildren(self.nodes)
    self.server_flag = GetImage(self.server_flag)
    self.server_name = GetText(self.server_name)
    self.testTex = GetText(self.testTex)
    self.server_name.text = "Retrieving server list..."
    local account1 = CacheManager:GetInstance():GetString("LoginPanel.account", "");
    if not AppConfig.autoGenerateAccount then
        self.account:GetComponent("InputField").text = ""
    elseif account1 and account1 ~= "" and AppConfig.saveAccount then
        self.account:GetComponent("InputField").text = account1
    else
        self.account:GetComponent("InputField").text = SystemInfo.deviceUniqueIdentifier .. "" .. os.time()
    end

    --self.loginBtn_text:GetComponent("Text").text = "登录"

    self.image = self.bg:GetComponent('Image')
    local serverIndex = CacheManager:GetInstance():GetInt("LoginPanel.serverip", -1);
    DebugLog("======LoginPanel:LoadCallBack()===",serverIndex,AppConfig.autoGenerateAccount)
    if not AppConfig.autoGenerateAccount then
        self:SetIpInfo(7)
    elseif self.model.isOutServer then
        self:SetIpInfo(self.model.ip_list.default)
    elseif serverIndex ~= -1 then
        self:SetIpInfo(serverIndex);
    else
        self:SetIpInfo(self.model.ip_list.default)
    end
    --self:SetIpInfo(7)

    self.text_component = self.text:GetComponent('Text')
    self.img_loding_component = self.img_loding:GetComponent('Image')

    SetVisible(self.NoticeBtn, false)
    SetVisible(self.btn_customer_service, false)

    self:AddEvent()

    local value = 1
    if PreloadManager:GetInstance().is_loaded then
        value = 1
    end
    self:SetLoadingValue(value)

    local channel_id = LoginModel:GetInstance():GetChannelId()
    channel_id = tostring(channel_id)
    local cf = Config.db_version_num[channel_id]
    if not cf then
        cf = Config.db_version_num["0"]
    end
    DebugLog("LoginPanel channel_id = ",channel_id)
    if channel_id == "113649" then
        cf = {}
        cf.version_str = [[Examination and Approval Number: Xinguang Examination [2017] No. 3203 Publication Number: ISBN 978-7-7979-6619-1 Publisher: Shanghai Snow Carp Computer Technology Co., Ltd.  
Copyright unit: Guangzhou Junhai Network Technology Co., Ltd. Culture for Network Cultural Operation" Certificate No .: Yuewangwen [2018] 9308-3299 “]]
        cf.notice = [[Boycott bad games and say no to piracy. Protect yourself against frauds.]]
    end
    if cf then
        self.Text_component = self.Text:GetComponent('Text')
        self.Text_component.text = cf.version_str
        self.Text2_component = self.Text2:GetComponent('Text')
        self.Text2_component.text = cf.notice
    end
    -- self:TestPhoto()

    self:StartSDKTime()

    self.bg_component = self.bg:GetComponent('Image')
    self.logo_component = self.logo:GetComponent('Image')

    self:LoadAsset()

    --非大陆地区，不用防沉迷提示
    if not PlatformManager.GetInstance():IsCN() then
        SetVisible(self.Text_component,false)
        SetVisible(self.Text2,false)
    end


    -- lua_panelMgr:GetPanelOrCreate(NftPayPanel):Open()
end

function LoginPanel:StartSDKTime()
    self:StopTime()
    local function step()
        self:StartSDKLogin()
    end
    self.time_id = GlobalSchedule:StartOnce(step, 1.5)
end

function LoginPanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function LoginPanel:ClearLoginBg()
    if self.login_bg_texture then
        destroy(self.login_bg_texture)
        self.login_bg_texture = nil
    end

    if self.login_bg_sprite then
        destroy(self.login_bg_sprite)
        self.login_bg_sprite = nil
    end
end

function LoginPanel:ClearLogoIcon()
    if self.logo_bg_texture then
        destroy(self.logo_bg_texture)
        self.logo_bg_texture = nil
    end

    if self.logo_bg_sprite then
        destroy(self.logo_bg_sprite)
        self.logo_bg_sprite = nil
    end
end

function LoginPanel:LoadAsset()
    local channel_id = tostring(PlatformManager:GetInstance():GetChannelID())
    if channel_id == "112981" or channel_id == "112982" then
        local channelID = channel_id;--tostring(112982);--
        GlobalSchedule.StartFunOnce(function()
            self:StopTime()
            self:StartSDKLogin()
        end, 0.5);
        local res = "login_bg";
        lua_resMgr:SetImageTexture(self, self.bg_component, "asset/" .. channelID .. "/icon_big_bg_" .. res, res, false);
        res = "logo";
        lua_resMgr:SetImageTexture(self, self.logo_component, "asset/" .. channelID .. "/icon_big_bg_" .. res, res, false);
        --lua_resMgr:SetImageTexture(self,self.bg_component , );
        return
    end

    local is_load_bg = false
    local is_load_logo = false
    local function checkSDK()
        if is_load_bg and is_load_logo then
            self:SetVisible(true)
            self:StopTime()
            self:StartSDKLogin()
        end
    end

    self:SetVisible(false)
    local function call_back(sprite,texture)
        if self.is_dctored then
            return
        end
        is_load_bg = true
        checkSDK()
        SetVisible(self.bg_component, true)

        self:ClearLoginBg()
        self.login_bg_sprite = sprite
        self.login_bg_texture = texture
        if sprite then
            self.bg_component.sprite = sprite
            self.bg_component:SetNativeSize()
        end
    end
    HttpManager:GetInstance():LoadSteamAssetImageByCallBack("login_bg.png", call_back)

    SetVisible(self.logo_component, false)

    local function call_back(sprite,texture)
        if self.is_dctored then
            return
        end
        is_load_logo = true
        checkSDK()
        if channel_id ~= "111648" then
            SetVisible(self.logo_component, true)
        end

        self:ClearLogoIcon()
        self.logo_bg_texture = texture

        if sprite then
            self.logo_component.sprite = sprite
            self.logo_component:SetNativeSize()
        end
    end
    HttpManager:GetInstance():LoadSteamAssetImageByCallBack("logo.png", call_back)
end

function LoginPanel:StartSDKLogin()
    if self.is_start_sdk_login then
        return
    end
    self.is_start_sdk_login = true

    lua_panelMgr:ClosePanel(PreLoadingPanel)

    SetVisible(self.btn_login, false)
    if PlatformManager:GetInstance():IsMobile() then
        DebugLog('--LaoY LoginPanel.lua,line 99--', AppConfig.isOutServer)
        if AppConfig.isOutServer then
            local function step()
                if AppConfig.EnterGameCount > 0 then
                    return
                end
                DebugLog('--LaoY LoginPanel.lua,line 102--', AppConfig.isOutServer)
                PlatformManager:GetInstance():login()
            end
            GlobalSchedule:StartOnce(step, 1.0)

            self:SetSDKState()
        end
    else
    end
end

function LoginPanel:SetSDKState()
    SetVisible(self.btn_login, true)
    SetVisible(self.pc, false)
    SetVisible(self.serverObj, false)
end

function LoginPanel:TestPhoto()
    local function call_back(params)
        self:LoadPhoto(params)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.GetPhoto, call_back)
end

function LoginPanel:LoadPhoto(params)
    local function call_back(sprite)
        print('--LaoY LoginPanel.lua,line 114--', sprite)
        if self.is_dctored then
            return
        end
        self.image.sprite = sprite
    end
    local url = params.file_path .. params.file_name
    print('--LaoY LoginPanel.lua,line 120--', url)
    HttpManager:GetInstance():LoadSprite(url, Vector2(0.5, 0.5), call_back)
end

--点击服务器选择按钮后设置对应信息
function LoginPanel:SetIpInfo(index, isDevChannelLogin)

    if isDevChannelLogin then
        local serverInfo = Config.db_server_channel[index]
        self.devChannelLogin_serverInfo = serverInfo
        local account = self.account:GetComponent("InputField").text
        self:requestChannelServerList(account, serverInfo)
    else
        local info = Config.db_server[index]
        if info then
            self.name:GetComponent("Text").text = info.name
            self.ip:GetComponent("InputField").text = info.ip .. ":" .. info.host .. ":" .. info.channel_id .. ":" .. info.game_id .. ":" .. info.zone_id
        end
        CacheManager:GetInstance():SetInt("LoginPanel.serverip", index);
    end
end



function LoginPanel:requestChannelServerList(account, serverInfo)
    local url =  serverInfo.url .. "api/server/list"
    local url = string.format("%s?game_channel_id=%s&account=%s&platform=%s&iosver=%s",url,serverInfo.channel_id,account,"ios",serverInfo.iosver)

    local function call_back(data)
        DebugLog('--ffh 请求服务器列表成功,line 355--',Table2String(data))
        SelectServerModel:GetInstance():SpiltServerList(data)

        --GlobalEvent:Brocast(SelectServerEvent.SelectServerList,data)
        self:SelectServerList(true)

        lua_panelMgr:GetPanelOrCreate(SelectServerPanel):Open(true)

        SetVisible(self.btnChannelList.gameObject, true)
    end
    DebugLog("----------ffh 请求服务器列表 === ",url)
    HttpManager:GetInstance():ResponseGet(url,call_back)
end

function LoginPanel:AddEvent()
    -- local index = 1
    local lastClick
    local function call_back()
        if self.curSer then
            if lastClick and Time.time - lastClick < 0.5 then
                return
            end
            if self.curSer.flag == 3 and table.isempty(SelectServerModel:GetInstance().recent) then
                --Notify.ShowText("排队人数太多，请选择最新区服")
                Notify.ShowText("Too many players are queuing for this server, please change to the newest servers")
                return
            end
            lastClick = Time.time
            local flag = SelectServerModel:GetInstance():GetServerState(self.curSer)
            if flag == 0 then
                --维护中
                Notify.ShowText("Under maintenance")
            end
            local ip = self.curSer.host
            local port = self.curSer.port
            self.model:SetIp(ip, port)
            self.model:SetLoginServerInfo(self.curSer)
            NetManager:GetInstance():StartConnect(ip, port)
        end
    end
    AddButtonEvent(self.loginBtn.gameObject, call_back, nil, nil, 2.0)

    local function set_img_func(sprite)
        print('--LaoY LoginPanel.lua,line 114--', sprite)
        if self.is_dctored then
            return
        end
        self.image.sprite = sprite
    end

    local function auto_send_func(...)
        Yzprint('--LaoY LoginPanel.lua,line 204--', ...)
    end

    local last_click_time
    local isConnect = false
    local function call_back()
        if last_click_time and Time.time - last_click_time < 0.5 then
            return
        end
        last_click_time = Time.time
        local ip_str = self.ip:GetComponent("InputField").text
        if #ip_str <= 5 then
            logWarn("input ip and port")
            return
        end
        local ip_port_config = string.split(ip_str, ":")
        local ip = ip_port_config[1]
        local port = ip_port_config[2]
        LoginModel.DefaultChannelId = ip_port_config[3] or LoginModel.DefaultChannelId
        LoginModel.DefaultGameId = ip_port_config[4] or LoginModel.DefaultGameId
        LoginModel.ZoneID = ip_port_config[5] or LoginModel.ZoneID
        self.model:SetIp(ip, port)
        NetManager:GetInstance():StartConnect(ip, port)

    end
    AddButtonEvent(self.TestloginBtn.gameObject, call_back, nil, nil, 2.0)

    if AppConfig.QuickEnterGame then
        local function step()
            if self.is_dctored then
                return
            end
            call_back()
        end
        GlobalSchedule:StartOnce(step, 0.4)
    end

    local function call_back(target, x, y)
        -- do
        --     PlatformManager:GetInstance():TakePhoto(2,"test_2.png")
        --     return
        -- end
        lua_panelMgr:GetPanelOrCreate(LoginSelectPanel):Open(handler(self, self.SetIpInfo))
        -- Notify.ShowText("点击事件")
    end
    -- AddClickEvent(self.btn_drop.gameObject,call_back)
    AddButtonEvent(self.btn_drop.gameObject, call_back)

    local function OnConnect()
        if table.isempty(self.model.sdk_login_info) then
            local account_name = self.account:GetComponent("InputField").text
            -- account_name = tonumber(account_name)
            if not account_name then
                logWarn("input account number")
                return
            end
            self.model:SetAccount(account_name)
            if AppConfig.saveAccount then
                CacheManager:GetInstance():SetString("LoginPanel.account", account_name);
            end
        end
        LoginModel:GetInstance():Login()
    end
    self.event_id = GlobalEvent:AddListener(EventName.ConnectSuccess, OnConnect)

    local function call_back(value)
        self:SetLoadingValue(value)
    end
    -- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.LoadComponent, call_back)

    local function call_back()
        local serState = SelectServerModel:GetInstance():GetGamechanState()
        if serState == 0 then
            --渠道未开
            Notify.ShowText("It's not server launch time yet")
            return
        end
        lua_panelMgr:GetPanelOrCreate(SelectServerPanel):Open()
    end
    AddClickEvent(self.server_bg.gameObject, call_back)

    local last_login_time
    local function call_back(target, x, y)
        if last_login_time and Time.time - last_login_time < 1.0 then
            return
        end
        DebugLog("=================call_back============", last_login_time, Time.time)
        last_login_time = Time.time

        if PlatformManager:GetInstance():IsMobile() then
            if AppConfig.isOutServer then
                PlatformManager:GetInstance():login()
            end
        end
    end
    AddButtonEvent(self.btn_login.gameObject, call_back, nil, nil,1)

    AddButtonEvent(self.NoticeBtn.gameObject, handler(self, self.OnNoticeBtn))

    --聯繫客服
    local function call_back(  )
        PlatformManager:GetInstance():ShowCustomerService()
    end
    if self.btn_customer_service then
        AddButtonEvent(self.btn_customer_service.gameObject,call_back)
    end


    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SelectServerEvent.SelectServerList, handler(self, self.SelectServerList))
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SelectServerEvent.SelectServerRightClick, handler(self, self.SelectServerRightClick))
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.SDKLoginSucess, handler(self, self.SDKLoginSucess))
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(NoticeEvent.Notice_ResponseNoticeEvent, handler(self, self.OnResponseNotice))

    local function logout_call()
        -- if self.model.to_login then
        --     return
        -- end
        self.is_start_sdk_login = false
        -- self:StartSDKLogin()
        self:SetSDKState()
    end

    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.SDKLogOut, logout_call)


    local function call_back(funcName,code,data)
        if funcName == "SignAndLogin" then
            if code == 0 then
                self:SDKLoginSucess()
            end
        end
    end
    self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(NFTManager.Events.Update, call_back)

    --ffh 渠道登录添加
    local function channelLogin()
        lua_panelMgr:GetPanelOrCreate(LoginSelectPanel):Open(handler(self, self.SetIpInfo), true)
    end
    if self.btnChannel then
        AddButtonEvent(self.btnChannel.gameObject,channelLogin)
    end


    local function channelList()
        lua_panelMgr:GetPanelOrCreate(SelectServerPanel):Open(true)
    end
    if self.btnChannelList then
        AddButtonEvent(self.btnChannelList.gameObject,channelList)
        SetVisible(self.btnChannelList.gameObject, false)--请求列表后才显示
    end
end

function LoginPanel:SetLoadingValue(value)
    value = value or 0
    SetVisible(self.img_loding_bg, value < 1)
    self.img_loding_component.fillAmount = value
    self.text_component.text = value * 100
end

function LoginPanel:testModel()
    self.role_model = RoleModel(self.transform)
end

function LoginPanel:OpenCallBack()
    self:UpdateView()
    self:UpdatePanel()
    --self:DelayUpdatePaenl()
    self:PreloadCreateRoleModel()
end

function LoginPanel:UpdateView()

end

function LoginPanel:CloseCallBack()
    if self.event_id then
        GlobalEvent:RemoveListener(self.event_id)
        self.event_id = nil
    end
end

--function LoginPanel:SelectServerRightClick()
--    self.curSer = SelectServerModel:GetInstance().curSer
--    self:SetServer()
--end


function LoginPanel:SelectServerList(isDevChannelLogin)
    -- print('--LaoY LoginPanel.lua,line 235--',data)
    -- dump(SelectServerModel:GetInstance().curSer)
    local serState = SelectServerModel:GetInstance():GetGamechanState()
    if serState == 0 then
        --渠道未开
        --self.server_name.text = "未到开服时间"
        self.server_name.text = "It's not server launch time yet"
        lua_resMgr:SetImageTexture(self, self.server_flag, "selectserver_image", "selectSer_gray", true);
        return
    end

    if not self.clickSer then
        self.curSer = SelectServerModel:GetInstance().curSer
    else
        self.curSer = self.clickSer
    end

    if type(isDevChannelLogin) ~= "boolean" then
        isDevChannelLogin = false
    end

    self:SetServer(isDevChannelLogin)
end
function LoginPanel:SelectServerRightClick()
    self.clickSer = SelectServerModel:GetInstance().curSer
    self.curSer = self.clickSer

    self:SetServer(SelectServerModel:GetInstance().isDevChannelLogin)
end

function LoginPanel:SetServer(isDevChannelLogin)

    if self.curSer then
        if isDevChannelLogin and not PlatformManager:GetInstance():IsMobile() then
            local serverInfo = self.devChannelLogin_serverInfo
            self.name:GetComponent("Text").text = self.curSer.name
            self.ip:GetComponent("InputField").text = self.curSer.host .. ":" .. self.curSer.port .. ":" .. serverInfo.channel_id .. ":" .. serverInfo.game_id .. ":" .. self.curSer.sid
        else
            self.server_name.text = string.format("%s<color=#43f673> (%s)</color>", self.curSer.name, "Select Server")
            --self.testTex.text = self.curSer.host .. ":" .. self.curSer.port
            local flag = SelectServerModel:GetInstance():GetServerState(self.curSer)
	        if flag == 0 then
	            --维护
	            lua_resMgr:SetImageTexture(self, self.server_flag, "selectserver_image", "selectSer_gray", true);
	        elseif flag == 1 then
	            --流畅
	            lua_resMgr:SetImageTexture(self, self.server_flag, "selectserver_image", "selectSer_green", true);
	        elseif flag == 2 then
	            --推挤
	            lua_resMgr:SetImageTexture(self, self.server_flag, "selectserver_image", "selectSer_green", true);
	        else
	            --火爆
	            lua_resMgr:SetImageTexture(self, self.server_flag, "selectserver_image", "selectSer_red", true);
	        end
    	end

	end
end

function LoginPanel:SDKLoginSucess()
    -- print('--LaoY LoginPanel.lua,line 257--')
    --self:UpdatePanel()
    SetVisible(self.pc, false)
    SetVisible(self.btn_login, false)
    SetVisible(self.serverObj, true)
    self:RequestNotice()
end

---请求公告数据
function LoginPanel:RequestNotice()
    NoticeController:GetInstance():RequestOnlineNotice()

    local function DelayShowPanel()
        self:UpdatePanel()
    end
    self.scheduleId = GlobalSchedule:StartOnce(DelayShowPanel, 5)
end

function LoginPanel:StopSchedule()
    if (self.scheduleId) then
        GlobalSchedule:Stop(self.scheduleId)
        self.scheduleId = nil
    end
end

---请求公告数据回调
---公告按钮的显示由是否有公告为准
function LoginPanel:OnResponseNotice()
    local isHasNotice = NoticeModel:GetInstance():HasNotice()
    SetVisible(self.NoticeBtn, isHasNotice)

    self:StopSchedule()
    self:UpdatePanel()
end

function LoginPanel:OnNoticeBtn()
    lua_panelMgr:GetPanelOrCreate(NoticePanel):Open()
end

function LoginPanel:DelayUpdatePaenl()
    if self.delaySchedule then
        GlobalSchedule:Stop(self.delaySchedule)
    end
    local function step()
        self:UpdatePanel()
    end
    self.delaySchedule = GlobalSchedule:StartOnce(step, 1.0)
end

function LoginPanel:UpdatePanel()
    -- print('--LaoY LoginPanel.lua,line 265--')
    -- dump(self.model.sdk_login_info,"tab")

    if not table.isempty(self.model.sdk_login_info) then
        SetVisible(self.pc, false)
        SetVisible(self.btn_login, false)
        SetVisible(self.serverObj, true)
        if not self.is_first_req then
            SelectServerController:GetInstance():RequsetServerList()
            if self.serSchedule then
                GlobalSchedule.StopFun(self.serSchedule);
            end
            self.serSchedule = nil;
            self.serSchedule = GlobalSchedule:Start(handler(self, self.RequestServer), 60, -1);
            self.is_first_req = true
        end
    else
        SetVisible(self.pc, not PlatformManager:GetInstance():IsMobile() or not AppConfig.isOutServer)
        SetVisible(self.btn_login, not PlatformManager:GetInstance():IsMobile() or not AppConfig.isOutServer)
    end
end

function LoginPanel:RequestServer()
    SelectServerController:GetInstance():RequsetServerList()
end

--加载创角模型
function LoginPanel:PreloadCreateRoleModel()
    local abName = "asset/model_clothe_40002"
    local assetName = "model_clothe_40002"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_head_40002"
    local assetName = "model_head_40002"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_weapon_40002"
    local assetName = "model_weapon_40002"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_wing_40002"
    local assetName = "model_wing_40002"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    --男
    local abName = "asset/model_clothe_40001"
    local assetName = "model_clothe_40001"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_head_40001"
    local assetName = "model_head_40001"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_weapon_40001"
    local assetName = "model_weapon_40001"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)

    local abName = "asset/model_wing_40001"
    local assetName = "model_wing_40001"
    poolMgr:AddConfig(abName, assetName, 1, 0, false)
    PreloadObject(abName, assetName)
    --poolMgr:RemovePool(abName, assetName,false)
end