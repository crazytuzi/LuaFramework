--
-- Author: LaoY
-- Date: 2018-06-29 11:35:40
--

require("game.login.RequireLogin")

require("game.nft.RequireNft")

LoginController = LoginController or class("LoginController", BaseController)
local LoginController = LoginController
local CreateRoleSceneMgr = require("game.login.CreateRoleSceneManager")

function LoginController:ctor()
    LoginController.Instance = self
    self.model = LoginModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function LoginController:dctor()
end

function LoginController:GetInstance()
    if not LoginController.Instance then
        LoginController.new()
    end
    return LoginController.Instance
end

function LoginController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1001_login_pb"
    self:RegisterProtocal(proto.LOGIN_VERIFY, self.HandleLoginVerify)
    self:RegisterProtocal(proto.LOGIN_CREATE, self.HandleCreateRole)
    self:RegisterProtocal(proto.LOGIN_ENTER, self.HandleEnterGame)
    self:RegisterProtocal(proto.LOGIN_NAME, self.HandleCreateName)

    self:RegisterProtocal(proto.GAME_ERROR, self.HandleError)
    self:RegisterProtocal(proto.GAME_HEART, self.HandleHeart)
    self:RegisterProtocal(proto.GAME_TIME, self.HandleTime)
    self:RegisterProtocal(proto.GAME_NOTIFY, self.HandleNotify)
    self:RegisterProtocal(proto.LOGIN_RECONN, self.HandleReConnect)

    self:RegisterProtocal(proto.GAME_HOTCONFIG, self.HandleUpdateConfig)

    self:RegisterProtocal(proto.GAME_NEWBIE_SCENE, self.HandleNewBieScene)

    --self:RegisterProtocal(proto.GAME_OPEN,self.HandleOpen)
end

function LoginController:AddEvents()
    local function open_login_panel()
        lua_panelMgr:GetPanelOrCreate(LoginPanel):Open()

        -- if AppConfig.Debug then
        if not PlatformManager:GetInstance():IsMobile() then
            lua_panelMgr:GetPanelOrCreate(DebugFps):Open()
        end
    end
    GlobalEvent:AddListener(LoginEvent.OpenLoginPanel, open_login_panel)

    local function CloseLoginPanel()
        local panel = lua_panelMgr:GetPanel(LoginPanel)
        if panel then
            panel:Close()
        end
    end
    GlobalEvent:AddListener(LoginEvent.CloseLoginPanel, CloseLoginPanel)

    local function OpenSelectPanel()
        lua_panelMgr:GetPanelOrCreate(SelectRolePanel):Open()
        MapManager:GetInstance():SetSceneCameraEnable(false)
    end
    GlobalEvent:AddListener(LoginEvent.OpenSelectRolePanel, OpenSelectPanel)

    -----开始加载场景, 后打开创角UI
    --local function loadScene()
    --    CreateRoleSceneMgr:LoadCreateScene(handler(self, self.OpenCreatePanel)) --, handler(self, self.LoadSceneProgress)
    --end
    -----加载场景AB包
    --local function loadAb()
    --    if (self.IsSceneLoaded) then
    --        loadScene()
    --    else
    --        lua_resMgr:LoadScene(self, CreateRoleSceneMgr.Scene_Create, loadScene)
    --    end
    --end
    --GlobalEvent:AddListener(LoginEvent.OpenCreateRolePanel, loadAb)

    GlobalEvent:AddListener(LoginEvent.OpenCreateRolePanel, handler(self, self.OpenCreatePanel))

    local function OnConnect()
        self.model:StartHeart()
        self.model:StartTime()
        if
            self.model.is_first_connect and
                (not self.model.is_reconnect or not RoleInfoModel:GetInstance():GetMainRoleId())
         then
            self.model:Login()
        end
        if self.model.is_reconnect and RoleInfoModel:GetInstance():GetMainRoleId() then
            self:RequestReConnect()
        end
        self.model.is_reconnect = nil
        self.model.to_login = nil
    end
    GlobalEvent:AddListener(EventName.ConnectSuccess, OnConnect)

    local function logout_call()
        if self.model.to_login then
            self:HandleLeaveGame()
        end
    end
    GlobalEvent:AddListener(EventName.SDKLogOut, logout_call)

    local function call_back()
        if Time.timeScale > 1 then
            Notify.ShowText("Accelerator prohibited")
            Time:SetTimeScale(1)
        end
    end
    GlobalSchedule:Start(call_back, 0.1)

    self.is_pause = false
    local function call_back()
        if self.is_pause then
            return
        end
        self.is_pause = true
        DebugLog("=============EventName.OnPause",self.is_pause)
        if not self.model.is_connect then
            return
        end
        self:RequestSuSpend()
        -- NetManager:GetInstance().is_pause = true
    end
    GlobalEvent:AddListener(EventName.OnPause, call_back)

    local function call_back()
        if not self.is_pause then
            return
        end
        self.is_pause = false
        DebugLog("=============EventName.OnResume",self.is_pause)
        if not self.model.is_connect then
            return
        end
        -- NetManager:GetInstance().is_pause = false
        self:RequestAwake()
    end
    GlobalEvent:AddListener(EventName.OnResume, call_back)


    local function call_back()
        if AppConfig.GameStart then
            self.model:InitFirstLanding()
        end
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)

    local function call_back()
        CreateRoleSceneMgr:UnloadCreateScene(nil)
    end
    GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function LoginController:GetCreateRoleSceneMgr()
    return CreateRoleSceneMgr
end

---场景加载进度
function LoginController:LoadSceneProgress(value)
    print("LoadSceneProgress-------------> " .. value)
end

function LoginController:OpenCreatePanel()
    --if (sceneName == CreateRoleSceneMgr.Scene_Create) then

    local panel = lua_panelMgr:GetPanel(SelectRolePanel)
    if panel then
        panel:Close()
    end
    MapManager:GetInstance():SetSceneCameraEnable(false)
    lua_panelMgr:GetPanelOrCreate(CreateRolePanel):Open()
    --end
end

--请求基本信息
function LoginController:RequestLoginVerify(account, platform, gamechan, token, args)
    local pb = self:GetPbObject("m_login_verify_tos")
    DebugLog("--LaoY ======>", type(account), account, platform, gamechan, token, args)
    pb.platform = platform or "xingwan"
    pb.account = account
    if gamechan then
        pb.gamechan = gamechan
    else
        pb.gamechan = ""
    end

    if token then
        pb.token = token
    else
        pb.token = ""
    end

    if pb.token == "" then
        if not PlatformManager:GetInstance():IsMobile() or not AppConfig.isOutServer then
            local str = account .. "DiHyxsjl4PTypmoWBJic68QV"
            local md5 = Util.md5(str)
            pb.token = md5
        end
    end

    if not AppConfig.Debug and not args then
        -- local cur_ser = SelectServerModel:GetInstance().curSer
        local cur_ser = self.model:GetLoginServerInfo()
        if self.model.sdk_login_info and self.model.sdk_login_info.loginInfo and cur_ser then
            args = {
                game_id = self.model.sdk_login_info.loginInfo.game_id or "207",
                channel_id = self.model.sdk_login_info.loginInfo.game_channel_id or PlatformManager:GetChannelID() or "tw003",
                zone_id = cur_ser.sid or "",
                zone_name = cur_ser.name or ""
            }

            local device_info = PlatformManager:GetInstance().device_info
            for k,v in pairs(device_info) do
                args[k] = v
            end
        end
    end

    if not args and (not AppConfig.isOutServer) then
        args = {
            game_id = LoginModel.DefaultGameId,
            channel_id = LoginModel.DefaultChannelId,
            zone_id = LoginModel.ZoneID,
            zone_name = LoginModel.ZoneID
        }
    end

    -- 120.79.93.201:9001
    -- args = {
    --     game_id = 207,
    --     channel_id = gamechan,
    --     zone_id     = 1,
    --     zone_name   = "",
    -- }
    -- local device_info = PlatformManager:GetInstance().device_info
    -- for k,v in pairs(device_info) do
    --     args[k] = v
    -- end

    if args then
        LoginModel.ZoneID = args.zone_id or LoginModel.ZoneID
        LoginModel.ZoneName = args.zone_name or LoginModel.ZoneName
    end


    if not table.isempty(args) then
        DebugLog("--LaoY LoginController.lua,line 200--", Table2String(args))

        for k, v in pairs(args) do
            local map = pb.args:add()
            map.key = k
            map.value = tostring(v)
        end
    end

    -- print('--LaoY LoginController.lua,line 59-- Time.time=',token_str,pb.ticket)
    self:WriteMsg(proto.LOGIN_VERIFY, pb)
end

function LoginController:HandleLoginVerify()
    BaseController.CusMsgState = BaseController.MsgState.Select
    
    local data = self:ReadMsg("m_login_verify_toc")
    self.model.is_first_connect = true
    self.model.is_connect = true
    self.model.login_role_list = data.roles

    local function Call_back(sceneName)
        if (sceneName == CreateRoleSceneMgr.Scene_Create) then
            -- GlobalEvent:Brocast(LoginEvent.CloseLoginPanel)
            
            GlobalEvent:Brocast(LoginEvent.OpenLoginScene)
            LoadingCtrl:GetInstance():HandleLoadingClose(true)

            --lua_resMgr:UnloadPrefab(CreateRoleSceneMgr.Scene_Create, 1)

            local panel1 = lua_panelMgr:GetPanel(SelectRolePanel)
            local panel2 = lua_panelMgr:GetPanel(CreateRolePanel)
            ---检测是不是已经有打开的Panel了，如果存在则可以认为是重连状态了
            if AppConfig.Debug then
               -- logError(string.format("测试打印：SelectRolePanel = %s,CreateRolePanel = %s,data = %s",tostring(panel1),tostring(panel2),Table2String(data)))
            end
            if panel1 or panel2 then
                return
            end

            if #data.roles > 0 then
                GlobalEvent:Brocast(LoginEvent.OpenSelectRolePanel)
                -- local roe_data = self.model.login_role_list[1]
                -- local role_id = roe_data.id
                -- local role_name = roe_data.name
                -- LoginController:GetInstance():RequestEnterGame(role_id, role_name)
            else
                GlobalEvent:Brocast(LoginEvent.OpenCreateRolePanel)
            end
        end
    end

    DebugLog("<color=#e63232>--LaoY LoginController.lua,line 198--</color>", lua_resMgr.down_load_cur_count)


    ---开始加载场景, 后打开创角UI
    -- local function loadScene()
    --     CreateRoleSceneMgr:LoadCreateScene(Call_back) --, handler(self, self.LoadSceneProgress)
    -- end

    -- if (self.IsSceneLoaded) then
    --     loadScene()
    -- else
    --     if lua_resMgr:IsInDownLoadList(CreateRoleSceneManager.abName) then
    --         local function call_back(abName)
    --             lua_resMgr:LoadScene(self, CreateRoleSceneMgr.Scene_Create, loadScene)
    --         end
    --         lua_resMgr:AddDownLoadList(self, CreateRoleSceneManager.abName, call_back, Constant.LoadResLevel.Urgent)
    --     else
    --         lua_resMgr:LoadScene(self, CreateRoleSceneMgr.Scene_Create, loadScene)
    --     end
    -- end

    CreateRoleSceneManager:LoadAB(self,Call_back)

    NetManager:GetInstance():StartReConnectSchedule()

    self:RequestNewBieScene()

    if AppConfig.isOutServer then
        local data = {suid = LoginModel.ZoneID,serverName = LoginModel.ZoneName}
        PlatformManager:GetInstance():uploadUserDataByRoleData(data, 5)
    end
end

function LoginController:RequestCreateRole(career, gender, name)

    local pb = self:GetPbObject("m_login_create_tos")
    pb.career = career
    pb.gender = gender
    pb.name = name
    self:WriteMsg(proto.LOGIN_CREATE, pb)
    -- print('--LaoY LoginController.lua,line 101-- data=',data)
end

--创建角色返回
function LoginController:HandleCreateRole()
    local data = self:ReadMsg("m_login_create_toc")
    -- print('--LaoY LoginController.lua,line 104-- data=',data.role_id)

    self.model.is_create_role = true
    self:RequestEnterGame(data.role_id)
end

function LoginController:RequestEnterGame(role_id, role_name)
    local pb = self:GetPbObject("m_login_enter_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.LOGIN_ENTER, pb)
end

function LoginController:HandleEnterGame()
    BaseController.CusMsgState = BaseController.MsgState.Normal

    local data = self:ReadMsg("m_login_enter_toc")
    -- print('--LaoY LoginController.lua,line 117--')
    -- dump(data,"data")

    RoleInfoModel:GetInstance():SetSuids(data.suids)

    -- Notify.ShowText("成功进入游戏")
    self.model:SetToken(data.token)
    self.model:SetOpenTime(data.open)
    ---进入游戏后=>卸载场景=>去掉加载过的标识
    CreateRoleSceneMgr:UnloadCreateScene(nil)

    local function Unload_Create_Scene()
        lua_resMgr:UnloadPrefab(CreateRoleSceneMgr.Scene_Create, 1)
    end
    GlobalSchedule:StartOnce(Unload_Create_Scene, 0)

    self.IsSceneLoaded = nil

    MapManager:GetInstance():SetSceneCameraEnable(true)

    AppConfig.GameStart = true
    AppConfig.EnterGameCount = AppConfig.EnterGameCount + 1
    GlobalEvent:Brocast(EventName.GameStart)
end

function LoginController:RequestCreateName(gender)
    local pb = self:GetPbObject("m_login_name_tos")
    pb.gender = gender
    self:WriteMsg(proto.LOGIN_NAME, pb)
end

function LoginController:HandleCreateName()
    local data = self:ReadMsg("m_login_name_toc")
    -- print('--LaoY LoginController.lua,line 131--',data.name)
    -- dump(data,"data")

    GlobalEvent:Brocast(LoginEvent.RandomName, data.name)
end

--错误码处理
function LoginController:HandleError()
    local data = self:ReadMsg("m_game_error_toc", "pb_1000_game_pb")
    local str = errno[data.errno]
    --print("--LoginController.lua,line 148-- data=", data.errno, str, self.model:IsShowError(data.errno))
    --dump(data, "data")
    if
        data.errno == 1000010 or data.errno == 1000012 or data.errno == 1000002 or data.errno == 1000004 or
            data.errno == 1001010 or data.errno == 1000021 or data.errno == 1000022
     then
        GlobalEvent:Brocast(EventName.GameReset)
        self.model:SetQuit(data.errno)
        NetManager:GetInstance():Quit()
        return
    end
    if data.errno == 1134009 then --同时被求婚
        GlobalEvent:Brocast(MarryEvent.MarryErrorInfo, data.args)
        return
    end
    if LoginModel.IsIOSExamine then
        return
    end
    if str then
        if self.model:IsShowError(data.errno) then
            if data.errno == 1101002 then
                if data.args[1] ~= nil and data.args[1] == "201" and errno[1400036] ~= nil then
                    Notify.ShowText(errno[1400036])
                elseif data.args[1] then
                    local bag_type = tonumber(data.args[1])
                    local cf = Config.db_bag[bag_type]
                    -- local train_name = enumName.TRAIN[train_type]
                    if cf then
                        Notify.ShowText(string.format(str, cf.name))
                    end
                else
                    Notify.ShowText(str)
                end
            elseif data.errno == 1200005 and data.args[1] then
                SceneConfigManager:GetInstance():CheckEnterScene(tonumber(data.args[1]), true)
            elseif data.errno == 1200004 and data.args[1] then
                local object = SceneManager:GetInstance():GetObject(data.args[1])
                if object then
                    -- if object and object.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP and not AppConfig.Debug then
                    Yzprint("--怪物不在场景中1--", data.args[1], object.object_info.name)
                    FightManager:GetInstance():DebugMonster(object.object_id)
                    FightManager:GetInstance():DebugKillDamage(object.object_id)
                    -- object:destroy()
                    object:PlayDeath()
                else
                    Yzprint("--怪物不在场景中2--",data.args[1], object and object.object_info.name)
                end
                if AppConfig.Debug then
                    Notify.ShowText(str)
                end
                return
            elseif (data.errno == 1201004 or data.errno == 1201005) and data.args[1] then
                -- 道具不足
                Yzprint("--LaoY LoginController.lua,line 274--", str, data.args[1])
                if AppConfig.Debug then
                    Notify.ShowText(str)
                end
            elseif data.errno == 1102002 and data.args[1] then
                -- 正在xxx中，不能进入副本
                local goods_id = tonumber(data.args[1])
                local number = data.args[2]
                local config = Config.db_item[goods_id]
                if not config then
                    return
                end
                local str = ""
                if number then
                    -- str = string.format("缺乏:<color=#%s>%sx%s</color>",ColorUtil.GetColor(config.color),config.name,number)
                    str = string.format("Lack: %sx%s", config.name, number)
                else
                    -- str = string.format("缺乏:<color=#%s>%s</color>",ColorUtil.GetColor(config.color),config.name)
                    str = string.format("Lack: %s", config.name)
                end
                Notify.ShowText(str)
            elseif data.errno == 1200030 and data.args[1] then
                local arg = tonumber(data.args[1])
                local role_state = enumName.ROLE_STATE[arg]
                if role_state then
                    local str = string.format(str, role_state)
                    Notify.ShowText(str)
                end
            elseif data.errno == 1107005 and data.args[1] then
                local train_type = tonumber(data.args[1])
                local train_name = enumName.TRAIN[train_type]
                Notify.ShowText(string.format(str, train_name))
            elseif data.errno == 1000018 and data.args[1] then
                if AppConfig.Debug then
                    logError(string.format("%s,相关协议号是：", str, data.args[1]))
                end
            elseif data.errno == 1101003 and data.args[1] then
                local bag_type = tonumber(data.args[1])
                local cf = Config.db_bag[bag_type]
                if cf then
                    Notify.ShowText(string.format(str, cf.name))
                end
            else
                Notify.ShowText(str)
            end
        end
    else
        logWarn("errno is nil,", data.errno)
    end
end

--心跳包
function LoginController:RequestHeart()
    -- Yzprint('--LaoY LoginController.lua,line 150-- data=',proto.GAME_HEART)
    -- local pb = self:ReadMsg("m_game_heart_tos","pb_1000_game_pb")
    --self:WriteMsg(proto.GAME_HEART,pb)
    self:WriteMsg(proto.GAME_HEART)

    local function reconnect()
        DebugLog('--LaoY LoginController.lua,line 473--', self.is_pause, TimeManager:GetInstance():GetClient() - self.model.last_heart_time)
        if self.is_pause then
            return
        end
        local now = TimeManager:GetInstance():GetClient()
        if now - self.model.last_heart_time >= 20 then
            NetManager:GetInstance().err_net = true
        end
    end
    if not self.model.reconnect_time_id then
        self.model.reconnect_time_id = GlobalSchedule:Start(reconnect, 20)
    end
end

function LoginController:HandleHeart()
    local data = self:ReadMsg("m_game_heart_toc", "pb_1000_game_pb")
    -- Yzprint('--LaoY LoginController.lua,line 155-- data=',data)
    self.model:StopReconnect()
    self.model.last_heart_time = TimeManager:GetInstance():GetClient()
end

function LoginController:RequestTime()
    -- local pb = self:ReadMsg("m_game_time_tos","pb_1000_game_pb")
    --self:WriteMsg(proto.GAME_TIME,pb)
    self:WriteMsg(proto.GAME_TIME)
end

function LoginController:HandleTime()
    local data = self:ReadMsg("m_game_time_toc", "pb_1000_game_pb")
    local s_time = tonumber(data.time)
    TimeManager:GetInstance():SetErrorTimeMs(s_time)

    local timeZone = data.tz
    TimeManager:GetInstance():SetServerTimeZone(timeZone)

    -- local tab = os.date("*t")
    -- Yzprint('--LaoY ======>', tab)
end

function LoginController:RequestClientTime()
    local pb = self:GetPbObject("m_game_clienttime_tos", "pb_1000_game_pb")
    pb.time = os.clock()
    self:WriteMsg(proto.GAME_CLIENTTIME, pb)
end

function LoginController:RequestGameCheat(cmd)
    local pb = self:GetPbObject("m_game_cheat_tos", "pb_1000_game_pb")
    pb.cmd = cmd
    self:WriteMsg(proto.GAME_CHEAT, pb)
end

function LoginController:RequestNotify(param)
    local pb = self:GetPbObject("m_game_open_tos", "pb_1000_game_pb")
    pb.param = param
    -- self:WriteMsg(proto.LOGIN_NAME,pb)
end

function LoginController:HandleNotify()
    local data = self:ReadMsg("m_game_notify_toc", "pb_1000_game_pb")
    local _msgno = data.msgno
    local _args = data.args
    local config = msgno[_msgno]
    if not config then
        return
    end
    -- 提示进入聊天
    if config.type == 1 then
        -- 提示弹窗
        if config.chan == enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
            local msg = ""
            if #_args > 0 then
                --msg = string.format(string.trim(config.desc), unpack(_args))
                msg = ChatColor.FormatMsg(string.trim(config.desc), _args)
            else
                msg = ChatColor.FormatMsg(string.trim(config.desc))
            end
            local data = {}
            data.channel_id = enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD
            data.type_id = 0
            data.content = msg
            ChatModel:GetInstance():AddMsg(data)
        end
    elseif config.type == 2 then
        --系统公告
        if #_args > 0 then
            --Notify.ShowText(string.format(string.trim(config.desc), unpack(_args)))
            Notify.ShowText(ChatColor.FormatMsg(string.trim(config.desc), _args))
        else
            Notify.ShowText(ChatColor.FormatMsg(string.trim(config.desc)))
        end
    elseif config.type == 3 then
        local msg = ""
        if #_args > 0 then
            --msg = string.format(string.trim(config.desc), unpack(_args))
            msg = ChatColor.FormatMsg(string.trim(config.desc), _args)
        else
            msg = ChatColor.FormatMsg(string.trim(config.desc))
        end
        TipsManager.ShowHorseRaceTip(msg, 2)
        if config.chan == 1 then
            local chat_msg = {}
            chat_msg.channel_id = enum.CHAT_CHANNEL.CHAT_CHANNEL_SYS
            chat_msg.type_id = 0
            chat_msg.content = msg
            ChatModel:GetInstance():AddMsg(chat_msg)
        --GlobalEvent:Brocast(ChatEvent.AddMsgItem, chat_msg)
        end
    end

    -- if msgNo == msgdef.MSG_BOSS_BORN then

    -- end
    -- GlobalEvent.BrocastEvent(SceneEvent.GAME_NOTIFY , pb);
end

function LoginController:HandleOpen()
    local data = self:ReadMsg("m_game_open_toc", "pb_1000_game_pb")
end

function LoginController:RequestReConnect()
    local pb = self:GetPbObject("m_login_reconn_tos")
    pb.role_id = RoleInfoModel:GetInstance():GetMainRoleId()
    pb.token = self.model:GetToken()
    self:WriteMsg(proto.LOGIN_RECONN, pb)
end

function LoginController:RequestLeaveGame(to_login)
    self.model.to_login = to_login
    local pb = self:GetPbObject("m_login_leave_tos")
    self:WriteMsg(proto.LOGIN_LEAVE, pb)
    self.model:SetIsChangeRole(true)
    NetManager:GetInstance():StopReConnect()
    AppConfig.GameStart = false

    if not self.model.to_login or not PlatformManager:GetInstance():IsMobile() or AppConfig.Debug then
        self:HandleLeaveGame()
    end

    self:StopLeavelTime()
    BaseController.CusMsgState = BaseController.MsgState.Verify
    -- local function step()
    --     BaseController.LockMsg = false
    --     self:StopLeavelTime()
    -- end
    -- self.leave_time_id = GlobalSchedule:StartOnce(step,5.0)
end

function LoginController:StopLeavelTime()
    if self.leave_time_id then
        GlobalSchedule:Stop(self.leave_time_id)
        self.leave_time_id = nil
    end
end

function LoginController:HandleLeaveGame()
    self:StopLeavelTime()
    BaseController.LockMsg = false
    if self.model.to_login then
        GlobalEvent:Brocast(EventName.GameReset)
        GlobalEvent:Brocast(LoginEvent.OpenLoginPanel)
        self.model.is_first_connect = nil
        return
    end
    local function ok_func()
        NetManager:GetInstance():StartConnect(self.model.ip, self.model.port)
        GlobalEvent:Brocast(EventName.GameReset)
    end
    GlobalSchedule:StartOnce(ok_func, 0.5)
end

function LoginController:HandleReConnect()
    NetManager:GetInstance().err_net = false
end

function LoginController:HandleUpdateConfig()
    local data = self:ReadMsg("m_game_hotconfig_toc", "pb_1000_game_pb")
    Yzprint("--LaoY LoginController.lua,line 427--", data)
    self.model:HotUdpateConfig(data.config)
end

-- 游戏挂起(前端调用摄像头等)
function LoginController:RequestSuSpend()
    self:WriteMsg(proto.GAME_SUSPEND)
end

-- 游戏唤醒
function LoginController:RequestAwake()
    self:WriteMsg(proto.GAME_AWAKE)
end

function LoginController:RequestSendErrorMessage(message)
    local pb = self:GetPbObject("m_game_clienterror_tos", "pb_1000_game_pb")
    pb.error = message

    self:WriteMsg(proto.GAME_CLIENTERROR, pb)
end

function LoginController:RequestNewBieScene()
    -- local pb = self:GetPbObject("m_game_clienterror_tos", "pb_1000_game_pb")
    -- pb.error = message
    DebugLog("===========RequestNewBieScene==========")
    self:WriteMsg(proto.GAME_NEWBIE_SCENE)
end

--返回 
function LoginController:HandleNewBieScene()
    local data = self:ReadMsg("m_game_newbie_scene_toc","pb_1000_game_pb")
    DebugLog('--LaoY LoginController.lua,line 703--',data.res_id)
    LoginModel.ResID = data.res_id
end
