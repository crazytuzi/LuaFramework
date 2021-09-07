-- ----------------------------------------------------------
-- 逻辑模块 - 游戏登录
-- ----------------------------------------------------------
LoginManager = LoginManager or BaseClass(BaseManager)

function LoginManager:__init()
    if LoginManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    LoginManager.Instance = self

    self.socket_init = false -- socket初始化标记
    self.has_login = false --成功登录标记
    self.disconnect_mark = true  --主动断开连接标记，不主动进行断线重连
    self.reconnet = false -- 断线重连标记
    self.remotelogin = false -- 异地登录标记
    self.reconnet_time = 0 -- 重新连接时间戳，根据时间来跳转下一个重登步骤
    self.reconnet_step = 0 -- 重登步骤 0.未开始重连 1.后台重连 2.后台重连并弹出转圈圈界面 3.后台重连并弹出提示框
    self.reconnet_times = 0 -- 重登次数，超过3次则重新回到登录页
    self.relogin = false -- 重新登录标记
    self.reconnet_onresume = false -- 唤醒程序后需要断线重连的标记(后台断线时会用到)
    self.webcam_sleep = false -- 拍照切且后台的标记，不计算后台待机时间进行重连
    self.create_role_camera = nil
    self.connectiong = false
    self.mixSvrList = {} ----合服列表

    self.fail_on1010 = false
    self.has_connected = false
    self.data1100 = nil
    self.first_enter = false
    self.first_enter = false

    self.isWhiteList = false -- 是否白名单

    self.model = LoginModel.New()

    self.timeId = 0
    self.last_heartbeat_time = nil

    self.checkVersionTime = -1000000
    self.lastSend1097Time = BaseUtils.BASE_TIME
    
    self:InitHandler()
    -- 载入协议配置数据
    Connection.Instance:load_matedata()


    self.sendHeartbeat = function(id) self.timeId = id self:send1099() end

    EventMgr.Instance:AddListener(event_name.socket_connect, function() self:onConnected() end)
    EventMgr.Instance:AddListener(event_name.socket_reconnect, function() self:Request_On_Connet() end)
    EventMgr.Instance:AddListener(event_name.logined, function() self:Role_Info_Loaded() end)

    SleepManager.Instance.OnResumeEvent:Add(function() self:OnResume() end)

    self.loginInfo = {
        account = ""
        ,uid = ""
        ,timestamp = ""
        ,sign = ""
        ,guid = ""
        ,cp_ext = ""
    }
    self.curPlatform = ""
end

function LoginManager:__delete()
    LuaTimer.Delete(self.timeId)
end

function LoginManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(1099, self.on1099)
    self:AddNetHandler(1010, self.on1010)
    self:AddNetHandler(1097, self.on1097)
    self:AddNetHandler(1100, self.on1100)
    self:AddNetHandler(1101, self.on1101)
    self:AddNetHandler(1110, self.on1110)
    self:AddNetHandler(1120, self.on1120)

    self:AddNetHandler(9901, self.on9901)
    self:AddNetHandler(14701, self.on14701)
end

function LoginManager:send1099()
    local time = os.time()
    -- Log.Info(string.format("发心跳包 %s", time))
    if self.last_heartbeat_time ~= nil and time - self.last_heartbeat_time > 60 and self.remotelogin == false then
        -- Log.Info("长时间未收到心跳包，判断为断线，重新连接")
        Connection.Instance:disconnect()
        self.last_heartbeat_time = nil
    end
    Connection.Instance:send(1099, { time = time })

    self:CheckSend1097()
end

-- 处理返回的心跳包数据，并将客户端时间与服务器时间进行同步
function LoginManager:on1099(data)
    -- Log.Info(string.format("收心跳包 %s", data.server_time))
    BaseUtils.BASE_TIME = data.server_time
    self.last_heartbeat_time = os.time()
end

function LoginManager:send1010(account, platform, zone_id)
    -- print("-----------连接成功，发送协议： 1010----------"..account..","..platform..","..zone_id)

    local data = {account = account, type = 0, platform = platform, zone_id = zone_id, channel_reg = ctx.PlatformChanleId, dispense_id = ctx.KKKChanleId }
    if Application.platform == RuntimePlatform.Android then
        data.device_type = 1
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        data.device_type = 2
    elseif Application.platform == RuntimePlatform.WindowsPlayer then
        data.device_type = 3
    else
        data.device_type = 0
    end
    data.device_id = ctx.GeTuiClient

    if data.device_id == nil or data.device_id == "" then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            data.device_id = SdkManager.Instance:GetDeviceIdIMEI()
        else
            data.device_id = PlayerPrefs.GetString("virtual_device_id")
            if data.device_id == nil or data.device_id == "" then
                data.device_id = string.format("%s_%s_%s", "virtual", os.time(), Random.Range(1000, 9999))
                PlayerPrefs.SetString("virtual_device_id", data.device_id)
            end
        end
    end

    data.use_id = self.loginInfo.uid
    data.ts = self.loginInfo.timestamp
    data.ticket = self.loginInfo.sign
    data.guid = self.loginInfo.guid
    data.cp_ext = self.loginInfo.cp_ext
    if data.guid == nil then
        data.guid = ""
    end
    if data.cp_ext == nil then
        data.cp_ext = ""
    end

    Connection.Instance:send(1011, data)
end

--帐号登录返回
function LoginManager:on1010(data)
    -- print("-----------收到协议返回： 1010----------")
    print(string.format("%s %s", data.flag, data.msg))
    local flag = data.flag
    self.mixSvrList = data.list
    if flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("登录帐号成功"))
        Connection.Instance:send(1100, {})

        self.fail_on1010 = false

        if Application.platform == RuntimePlatform.IPhonePlayer then
            --
        elseif Application.platform == RuntimePlatform.Android then
            if BaseUtils.GetLocation() == KvData.localtion_type.sg then
                SdkManager.Instance:DoSomethingForEyou()
            end
        end


        if IS_USE_SDK then
            -- event_manager:GetUIEvent(ctx.LoadingPage.Panel).OnClick:RemoveListener(main.add_KKKAndroid_Listener)
        end

        --登录成功回调
        -- event_manager:DispatchEvent(event_name.login_succ)

        self:send1099()

        if self.timeId ~= 0 then LuaTimer.Delete(self.timeId) self.timeId = 0 end
        self.timeId = LuaTimer.Add(0, 10000, self.sendHeartbeat)
    elseif flag == 0 then
        local msg = data.msg
        NoticeManager.Instance:FloatTipsByString(msg)

        self.has_connected = false

        self.disconnect_mark = true

        self.connectiong = false

        if self.model.login_visable then
            Connection.Instance:disconnect()
        else
            Log.Error("[LoginError]1010协议报错，弹回登陆界面了")
            self:returnto_login(true)
        end
    else
        local msg = data.msg
        NoticeManager.Instance:FloatTipsByString(msg)

        self.has_connected = false

        self.disconnect_mark = true

        self.fail_on1010 = true
    end
end

function LoginManager:CheckSend1097()
    if BaseUtils.BASE_TIME - self.lastSend1097Time > 1800 then
        self:send1097()
    end
end

function LoginManager:send1097()
    local platform = ""
    local platformString = BaseUtils.GetPlatform()
    if platformString == "ios" then
        platform = "IPhonePlayer"
        Connection.Instance:send(1097, { platform = platform })
    elseif platformString == "jailbreak" then
        platform = "Jailbreak"
        Connection.Instance:send(1097, { platform = platform })
    elseif platformString == "android" then
        platform = "Android"
        Connection.Instance:send(1097, { platform = platform })
    end

    self.lastSend1097Time = BaseUtils.BASE_TIME
end

function LoginManager:on1097(data)
    print(string.format("on1097, version = %s, ctx.ResVersion = %s", data.version, ctx.ResVersion))
    if (Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android)
        and tonumber(data.version) > tonumber(ctx.ResVersion) then

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("检测到有更新信息，请重新进入游戏")
        data.sureLabel = TI18N("重启游戏")
        data.sureCallback = function() Application.Quit() end
        NoticeManager.Instance:UpdateTips(data)
    end
end

--正常退出游戏
function LoginManager:send1020()
    Connection.Instance:send(1020, {})
end

function LoginManager:on1100(data)
    print(string.format(TI18N("收到角色列表：%d"), #data.role_list))
    if data.cdkey == 1 then
        --需要激活,做激活逻辑
        self.data1100 = data
        -- mod_login.destory_zone_con()
        -- mod_login.activation = UIActivation.New()
    else
        self:create_or_login(data)
    end
end

--创建角色
function LoginManager:send1110(_name, gender, _classes)
    print(string.format(TI18N("创建角色,名字:%s,性别:%s,职业:%s"), _name, gender, _classes))
    Connection.Instance:send(1110, {name = _name, sex = gender, classes = _classes, zone_id = ServerConfig.target_server.zone_id })
end

--创建角色返回
function LoginManager:on1110(data)
    local flag = data.flag
    print(string.format("On1110:Flag:{%s}", flag))
    if flag == 1 then
         -- ui_role_create_window.kill_all_timer()
         -- ui_role_create_window.is_open = false
         -- mod_login.destroy_create_role_win()
         -- connection.send(10000,{})
         self.first_enter = true
         CreateRoleManager.Instance.model:CloseMainUI()
         -- DramaManager.Instance.model.dramaMask:BlackPanel(true)
         RoleManager.Instance:Logined()
         if SdkManager.Instance:RunSdk() then
             SdkManager.Instance:SendExtendDataRoleCreate(data)
             SdkManager.Instance:SendExtendDataRoleLogin(data)
         end
    else
        if BaseUtils.IsVerify then
            BaseUtils.VestPassCreateRole()
        else
            NoticeManager.Instance:FloatTipsByString(string.format ("%s", data.msg))
        end
    end
end

function LoginManager:create_or_login(data)
    if data == nil then
        return
    end
    print("create_or_login")
    if #data.role_list == 0 then
        --显示创建角色窗体
        -- mod_login.destory_zone_con()
        -- mod_login.load_create_win()
        self.model:CloseMainUI()
        CreateRoleManager.Instance.model:InitMainUI()
    else
        if self.reconnet then
            print("LoginManager.reconnet")
        elseif self.relogin then
            print("LoginManager.relogin")
        else
            --直接登录
            -- if mod_login.create_role_camera ~= nil then
            --     mod_login.create_role_camera:SetActive(false)
            --     -- GameObject.DestroyImmediate(mod_login.create_role_camera)
            -- end
        end

        -- mod_login.destory_zone_con()

        local zone_id = nil
        for i=1, #data.role_list do
            if data.role_list[i].zone_id == ServerConfig.target_server.zone_id then
                zone_id = data.role_list[i].zone_id
            end
        end

        if zone_id == nil then
            self.model:CloseMainUI()
            CreateRoleManager.Instance.model:InitMainUI()
        else
            self.has_login = true
            Connection.Instance:send(1120, {zone_id = zone_id})
        end
    end
end

function LoginManager:on1120(data)
    local flag = data.flag
    print(string.format("登录角色:%s", flag))
    if flag == 1 then
        self.model:CloseMainUI()
        RoleManager.Instance:Logined()
        if self.reconnet then
            -- SceneManager.Instance:Send10101()
            -- if ReconnectTips.Instance ~= nil then ReconnectTips.Instance:CloseTips() end准备
        -- elseif self.relogin then
        --     RoleManager.Instance:Logined()
        -- else
        --     RoleManager.Instance:Logined()
        end
        if SdkManager.Instance:RunSdk() then
            SdkManager.Instance:SendExtendDataRoleLogin(data)
            -- if BuglyAgent ~= nil then
            --     local userName = "" .. tostring(data.id) .. "_" .. data.platform .. "_" .. tostring(data.zone_id) .. "_" .. data.name
            --     BuglyAgent.SetUserId(userName);
            -- end
        end
    else
        NoticeManager.Instance:FloatTipsByString(string.format("%s", data.msg))
    end
end

function LoginManager:send10022(device_key)
    Connection.Instance:send(10022, {device_key = device_key})
end

function LoginManager:on9901(data)
    -- print(string.format("收到9901协议 %s %s", data.type, data.msg))
    local flag = data.type
    local msg = data.msg
    if flag == 0 then
        self.remotelogin = true

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = msg
        data.sureLabel = TI18N("重启游戏")
        data.sureCallback = function() Application.Quit() end
        NoticeManager.Instance:ConnectionConfirmTips(data)
        NoticeManager.Instance.model.connectionConfirmTips:SetPanelButtonEnabled(false)
    elseif flag == 1 then
        self.remotelogin = true

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = msg
        data.sureLabel = TI18N("重新登录")
        data.sureCallback = function() self.remotelogin = false Connection.Instance:InitReconnectView(1) Connection.Instance:reconnect() end
        NoticeManager.Instance:ConnectionConfirmTips(data)
        NoticeManager.Instance.model.connectionConfirmTips:SetPanelButtonEnabled(false)
    end
end

function LoginManager:on14701(data)
    local version = data.version
    local msg = data.msg
    if version ~= ctx.ResVersion then
        self.remotelogin = true

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = msg
        data.sureLabel = TI18N("重启游戏")
        data.sureCallback = function() Application.Quit() end
        NoticeManager.Instance:ConfirmTips(data)
        NoticeManager.Instance.model.confirmTips:SetPanelButtonEnabled(false)

-- ExitConfirmManager.Instance.model:OpenWindow()
    end
end

-- 登录游戏服务器处理
function LoginManager:Do_Login(_server_index, account)
    ServerConfig.target_server = BaseUtils.copytab(ServerConfig.servers[_server_index])

    if self.fail_on1010 then
        --请求帐号登录
        self:send1010(self.account, ServerConfig.target_server.platform, ServerConfig.target_server.zone_id)
        -- self:send1097()
    elseif self.has_connected == false and self.connectiong == false then
        self.disconnect_mark = false
        self.account = account
        self.connectiong = true

        self.socket_init = true

        -- print(string.format("%s:%s", ServerConfig.target_server.host, ServerConfig.target_server.port))
        -- 准备连接服务器
        Connection.Instance:connect(ServerConfig.target_server.host, ServerConfig.target_server.port)
    else
        print("已经向服务器请求连接，服务器不鸟你我也没办法")
    end
end

-- socket连接成功
function LoginManager:onConnected()
    self:send1010(self.account, ServerConfig.target_server.platform, ServerConfig.target_server.zone_id)
    -- self:send1097()
end

-- 返回登录界面
function LoginManager:returnto_login(force_has_login)
    Connection.Instance:disconnect()
    self.account = nil
    self.has_connected = false
    self.connectiong = false
    self.disconnect_mark = true
    self.last_heartbeat_time = nil
    -- if SdkManager.Instance.IsLogin == false then
    --     print("SDK没登录")
        ctx.LoadingPage.Panel:SetActive(true)
    --     return
    -- end
    self.reconnet_times = 0
    self.relogin = true
    self.reconnet = false
    if self.has_login or force_has_login == true then
        if force_has_login then self.model:InitMainUI() end
        if WindowManager.Instance.currentWin ~= nil then WindowManager.Instance:CloseWindow(WindowManager.Instance.currentWin, false) end
        MainUIManager.Instance:ShowMainUICanvas(false)
        MainUIManager.Instance.dialogModel:Hide()
        ChatManager.Instance.model:HideChatWindow()
        ChatManager.Instance.model:HideChatMini()
        SceneManager.Instance:Clean()
        CombatManager.Instance:OnDisConnect()
        CreateRoleManager.Instance.model:CloseMainUI()
        NoticeManager.Instance:CleanAutoUse()
        CombatManager.Instance:CloseFailedWind()
        TipsManager.Instance.model:Clear()
        NoticeManager.Instance:CleanActiveConfirmTips()
        NoticeManager.Instance:CloseConfrimTips()
        DramaManager.Instance:Clear()

        SceneManager.Instance.sceneElementsModel.self_data = nil
        SceneManager.Instance.sceneElementsModel.self_unique = ""
    end
    SoundManager.Instance:PlayBGM(SoundEumn.Background_MainCity)
end

-- -------------------------------------------------------
-- 回到登陆界面，并且重新打开sdk登陆窗口，用于切换账号
-- hosr 2016-06-04
-- -------------------------------------------------------
function LoginManager:ReturnToShowSdkLogin()
    if Application.platform == RuntimePlatform.Android then
        SdkManager.Instance:OnRelogin()
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        Connection.Instance:disconnect()

        self.has_connected = false
        self.connectiong = false
        self.disconnect_mark = true
        self.reconnet_times = 0
        self.relogin = true
        self.reconnet = false

        ctx.LoadingPage.Panel:SetActive(true)
        self.model:CloseMainUI()

        if WindowManager.Instance.currentWin ~= nil then
            WindowManager.Instance:CloseWindow(WindowManager.Instance.currentWin, false)
        end
        MainUIManager.Instance:ShowMainUICanvas(false)
        MainUIManager.Instance.dialogModel:Hide()
        ChatManager.Instance.model:HideChatWindow()
        ChatManager.Instance.model:HideChatMini()
        SceneManager.Instance:Clean()
        CombatManager.Instance:OnDisConnect()
        CreateRoleManager.Instance.model:CloseMainUI()
        NoticeManager.Instance:CleanAutoUse()
        CombatManager.Instance:CloseFailedWind()
        TipsManager.Instance.model:Clear()
        NoticeManager.Instance:CleanActiveConfirmTips()
        NoticeManager.Instance:CloseConfrimTips()
        SoundManager.Instance:PlayBGM(SoundEumn.Background_MainCity)
        SdkManager.Instance:ShowLoginView()

        SceneManager.Instance.sceneElementsModel.self_data = nil
        SceneManager.Instance.sceneElementsModel.self_unique = ""
    end
end

-- 重新激活系统  立刻测试网络连接
function LoginManager:OnResume()
        -- Log.Debug(string.format("上次tick Time = %s", BaseUtils.Last_Tick_Time))
        -- Log.Debug(string.format("重新激活 Time = %s", os.time()))
        -- Log.Debug(string.format("睡眠时间 Time = %s", os.time() - BaseUtils.Last_Tick_Time))
    if self.socket_init == false then self.webcam_sleep = false return end -- socket未初始化，不需要测试网络连接
    if self.remotelogin then self.webcam_sleep = false return end -- 异地登录，不需要测试网络连接

    if LoginManager.Instance.reconnet_onresume then
        Log.Debug(TI18N("重新激活程序,重新连接socket"))
        NoticeManager.Instance.model:CloseConfrimTips()

        LoginManager.Instance.reconnet_onresume = false
        LoginManager.Instance.reconnet_time = 0
        LoginManager.Instance.reconnet_step = 0
        Connection.Instance:on_disconnected()
    else
        LoginManager.Instance.reconnet_onresume = false
        LoginManager.Instance.reconnet_time = 0
        LoginManager.Instance.reconnet_step = 0

        if not self.webcam_sleep and BaseUtils.Last_Tick_Time ~= nil and os.time() - BaseUtils.Last_Tick_Time > 15 then -- 后台运行超过15秒，直接重连  拍照切后台，不需要测试网络连接
            NoticeManager.Instance.model:CloseConfrimTips()

            Connection.Instance:disconnect()
            self.reconnet_time = Time.time - 15
            self.last_heartbeat_time = nil
        else
            if BaseUtils.Last_Tick_Time ~= nil and os.time() - BaseUtils.Last_Tick_Time > 9 then
                self:send1099() -- 立刻发送心跳包，测试网络

                LuaTimer.Add(6500, function()
                    local time = os.time()
                    -- Log.Info(string.format("发心跳包 %s", time))
                    if self.last_heartbeat_time ~= nil and time - self.last_heartbeat_time > 6 and self.remotelogin == false then
                        NoticeManager.Instance.model:CloseConfrimTips()

                        -- Log.Info("长时间未收到心跳包，判断为断线，重新连接")
                        Connection.Instance:disconnect()
                        self.reconnet_time = Time.time - 15
                        self.last_heartbeat_time = nil
                    end
                end)
            end
        end
    end

    self.webcam_sleep = false
end

-- 重新连接，检查版本号
function LoginManager:CheckVersion()
    if Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android then
        LuaTimer.Add(5000, function ()
                -- if Webcam ~= nil then
                    if not SleepManager.Instance.IsPause and Time.time - self.checkVersionTime > 6000 then
                        self.checkVersionTime = Time.time
                        local url = string.format("%s%s%s", ctx.CheckApkPath, "/offline_version.php?IsTheone=", PlayerPrefs.GetString("last_isfirst")=="1")
                        ctx:GetRemoteTxt(url, function(versonStr) self:CheckVersionCallBack("versonStr") end, 2)
                    end
                -- end
            end)
    end
end

-- 检查版本号返回
function LoginManager:CheckVersionCallBack(versonStr)
    self.checkVersionTime = Time.time
    local param1, param2 = string.find(versonStr, "error")
    if param1 and param2 then
        return
    end
    local versonNum = tonumber(versonStr)
    if versonNum < 10 then
        return
    end
    if versonNum > tonumber(ctx.ResVersion) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("检测到有更新信息，请重新进入游戏")
        data.sureLabel = TI18N("重启游戏")
        data.sureCallback = function() Application.Quit() end
        NoticeManager.Instance:UpdateTips(data)
    end
end

-- 成功连接服务器，请求初始化数据 (断线重连需重新执行该方法)
function LoginManager:Request_On_Connet()
    print("成功连接服务器，请求初始化数据")
    self:send1097()
    if self.reconnet then -- 断线重连的特殊处理
        self.reconnet = false
        self:xpcall(function() MainUIManager.Instance:ClearAll() end)
        self:xpcall(function() CombatManager.Instance:Send10711() end)
        self:xpcall(function() ChatManager.Instance.model:ShowChatMini() end)
        self:xpcall(function() NoticeManager.Instance:FloatTipsByString(TI18N("重新连接成功")) end)

        --请求活动状态协议
        self:xpcall(function() FairyLandManager.Instance:request14600() end)
        self:xpcall(function() QualifyManager.Instance:request13502() end)
        self:xpcall(function() TipsManager.Instance:Clear() end)
        self:xpcall(function() NoticeManager.Instance:Clean() end)
        self:xpcall(function() ShippingManager.Instance:On_Reconnect() end)
        self:xpcall(function() ParadeManager.Instance:ClearAll() end)
        self:xpcall(function() RoleManager.Instance:OnReConnet() end)
        -- self:xpcall(function() PetLoveManager.Instance:request15608() end)
        self:xpcall(function() GuildManager.Instance.isFirstReceive11100 = true end)--改变状态，使重连请求完公会信息后，请求公会战信息
        self:xpcall(function() WorldChampionManager.Instance.Require16407() end)--改变状态，使重连请求完公会信息后，请求公会战信息

        -- self:xpcall(function() self:CheckVersion() end)

        self:xpcall(function() BackpackManager.Instance:NeedReload() end)
        self:xpcall(function() UnlimitedChallengeManager.Instance:ReqOnConnect() end)
        self:xpcall(function() GodsWarWorShipManager.Instance:DeletePlot() end)
    elseif self.relogin then -- 重新登录的特殊处理
        self.relogin = false
        self:xpcall(function() MainUIManager.Instance:ClearAll() end)
        self:xpcall(function() ChatManager.Instance:Clean() end)
        self:xpcall(function() ChatManager.Instance.model:ShowChatMini() end)
        self:xpcall(function() if SceneManager.Instanse ~= nil then SceneManager.Instanse.sceneElementsModel:Reconnet() end end)
        self:xpcall(function() CombatManager.Instance:Send10711() end)
        self:xpcall(function() TipsManager.Instance:Clear() end)
        self:xpcall(function() NoticeManager.Instance:Clean() end)
        self:xpcall(function() ShippingManager.Instance:On_Reconnect() end)
        self:xpcall(function() ParadeManager.Instance:ClearAll() end)
        self:xpcall(function() RoleManager.Instance:OnReConnet() end)
        -- self:xpcall(function() PetLoveManager.Instance:request15608() end)
        self:xpcall(function() SkillManager.Instance.model.in10804 = false end)
        self:xpcall(function() GuildManager.Instance.isFirstReceive11100 = true end)--改变状态，使重连请求完公会信息后，请求公会战信息
        self:xpcall(function() GodsWarWorShipManager.Instance:DeletePlot() end)
        -- self:xpcall(function() self:CheckVersion() end)
        -- self:send1097()

        self:xpcall(function() BackpackManager.Instance:NeedReload() end)
    else -- 首次连接才需要请求的数据
    end

    self:xpcall(function() WindowManager.Instance:ClearWindows() end)

    -- 连接成功需请求的数据
    self:xpcall(function() CampaignManager.Instance:RequestInitData() end)
    self:xpcall(function() NoticeManager.Instance:RequestInitData() end)
    self:xpcall(function() BackpackManager.Instance:RequestInitData() end)
    self:xpcall(function() QuestManager.Instance:RequestInitData() end)
    self:xpcall(function() FormationManager.Instance:RequestInitData() end)
    self:xpcall(function() TrialManager.Instance:RequestInitData() end)
    self:xpcall(function() SkillManager.Instance:RequestInitData() end)
    self:xpcall(function() TreasuremapManager.Instance:RequestInitData() end)
    self:xpcall(function() WingsManager.Instance:RequestInitData() end)
    self:xpcall(function() HonorManager.Instance:RequestInitData() end)
    self:xpcall(function() ClassesChallengeManager.Instance:RequestInitData() end)
    self:xpcall(function() AchievementManager.Instance:RequestInitData() end)
    self:xpcall(function() ConstellationManager.Instance:RequestInitData() end)
    self:xpcall(function() MarryManager.Instance:RequestInitData() end)
    self:xpcall(function() QuestMarryManager.Instance:RequestInitData() end)
    self:xpcall(function() PetLoveManager.Instance:RequestInitData() end)
    self:xpcall(function() DailyHoroscopeManager.Instance:RequestInitData() end)
    self:xpcall(function() SosManager.Instance:RequestInitData() end)
    self:xpcall(function() RideManager.Instance:RequestInitData() end)
    self:xpcall(function() DownLoadManager.Instance:RequestInitData() end)
    self:xpcall(function() HomeManager.Instance:RequestInitData() end)
    self:xpcall(function() RedBagManager.Instance:RequestInitData() end)
    -- self:xpcall(function() SpringFestivalManager.Instance:RequestInitData() end)

    self:xpcall(function() GuildManager.Instance:request11100() end)
    self:xpcall(function() GuildManager.Instance:request11198() end)
    self:xpcall(function() GuildManager.Instance:request11160() end)
    self:xpcall(function() SkillManager.Instance:Send10808() end) --请求生活技能
    self:xpcall(function() ExamManager.Instance:RequestInitData() end)
    self:xpcall(function() WarriorManager.Instance:RequestInitData() end)
    self:xpcall(function() ShouhuManager.Instance:request10901() end)
    self:xpcall(function() GuildManager.Instance:request11123() end)
    self:xpcall(function() AlchemyManager.Instance:request14900() end)
    self:xpcall(function() GuildManager.Instance:request11101() end)
    self:xpcall(function() AnnounceManager.Instance:send9920() end)
    self:xpcall(function() AnnounceManager.Instance:send9934(3) end)
    self:xpcall(function() ArenaManager.Instance:ClearData() end)
    self:xpcall(function() PrivilegeManager.Instance:RequestInitData() end)
    self:xpcall(function() PrivilegeManager.Instance:send9927() end) --限时返利
    self:xpcall(function() PrivilegeManager.Instance:send9932() end) --限时返利
    self:xpcall(function() MarketManager.Instance:ClearData() end)  -- 市场清空数据
    self:xpcall(function() DramaManager.Instance:RequestInitData() end)
    self:xpcall(function() TeacherManager.Instance:RequestInitData() end) -- 请求师徒信息
    self:xpcall(function() HeroManager.Instance:RequestInitData() end) -- 请求武道大会
    self:xpcall(function() ZoneManager.Instance:OnConnect() end)
    self:xpcall(function() CombatManager.Instance:SendOnConnect() end)
    self:xpcall(function() DungeonManager.Instance:ReqOnConnect() end)
    self:xpcall(function() FestivalManager.Instance:ReqOnConnect() end)
    self:xpcall(function() DragonBoatManager.Instance:ReqOnConnect() end)
    self:xpcall(function() SkillScriptManager.Instance:SendOnConnect() end)
    self:xpcall(function() PetManager.Instance:InitData() end)
    self:xpcall(function() WorldChampionManager.Instance:RequireOnConnect() end)
    self:xpcall(function() MasqueradeManager.Instance:RequestInitData() end)
    self:xpcall(function() RoleManager.Instance:Send10019() end)
    self:xpcall(function() StrategyManager.Instance:InitData() end)
    self:xpcall(function() EncyclopediaManager.Instance:InitData() end)
    self:xpcall(function() SevendayManager.Instance:InitData() end)
    self:xpcall(function() QualifyManager.Instance:ReqOnConnect() end)
    self:xpcall(function() SingManager.Instance:RequestInitData() end)
    self:xpcall(function() AuctionManager.Instance:InitData() end)
    self:xpcall(function() LotteryManager.Instance:RequestInitData() end)
    self:xpcall(function() BibleManager.Instance:send9933() end)
    self:xpcall(function() OpenBetaManager.Instance:InitData() end)
    self:xpcall(function() BackendManager.Instance:RequestInitData() end)
    self:xpcall(function() NationalDayManager.Instance:RequestInitData() end)
    self:xpcall(function() HandbookManager.Instance:RequestInitData() end)
    self:xpcall(function() UnlimitedChallengeManager.Instance:ReqOnConnect() end)
    self:xpcall(function() ShareManager.Instance:RequestInitData() end)
    self:xpcall(function() PortraitManager.Instance:RequestInitData() end)
    self:xpcall(function() LevelBreakManager.Instance:send17400() end)
    self:xpcall(function() NationalDayManager.Instance:Send14086() end)
    self:xpcall(function() NpcshopManager.Instance:Init() end)
    self:xpcall(function() GodsWarManager.Instance:RequestInitData() end)
    self:xpcall(function() HalloweenManager.Instance:Clear() HalloweenManager.Instance:RequestInitData() end)
    self:xpcall(function() SwornManager.Instance:RequestInitData() end)
    self:xpcall(function() RegressionManager.Instance:RequestInitData() end)
    self:xpcall(function() NotNamedTreasureManager.Instance:RequestInitData() end)
    self:xpcall(function() MatchManager.Instance:ReqOnReConnect() end)
    self:xpcall(function() SnowBallManager.Instance:ReqOnConnect() end)
    self:xpcall(function() RewardBackManager.Instance:RequestInitData() end)
    self:xpcall(function() FashionManager.Instance:RequestInitData() end)
    self:xpcall(function() ChildrenManager.Instance:ReqOnReConnect() end)
    self:xpcall(function() TeamDungeonManager.Instance:RequestInitData() end)
    self:xpcall(function() GuildManager.Instance:request11188() end)
    self:xpcall(function() WorldBossManager.Instance:RequestInitData() end)
    self:xpcall(function() FriendGroupManager.Instance:RequestInitData() end)
    self:xpcall(function() PetEvaluationManager.Instance:RequestInitData() end)
    -- self:xpcall(function() GuildSiegeManager.Instance:ReqOnConnect() end)
    self:xpcall(function() PlayerkillManager.Instance:RequestInitData() end)
    self:xpcall(function() GuildSiegeManager.Instance:ReqOnConnect() end)
    self:xpcall(function() BibleManager.Instance:RequestInitData() end)
    self:xpcall(function() ForceImproveManager.Instance:RequestInitData() end)
    self:xpcall(function() TalismanManager.Instance:RequireInitData() end)
    self:xpcall(function() GuildDungeonManager.Instance:RequestInitData() end)
    self:xpcall(function() GuildAuctionManager.Instance:ReqOnConnect() end)
    self:xpcall(function() ValentineManager.Instance:RequestInitData() end)
    self:xpcall(function() AnimalChessManager.Instance:RequireInitData() end)
    self:xpcall(function() DragonBoatFestivalManager.Instance:RequireInitData() end)
    self:xpcall(function() RebateRewardManager.Instance:RequestInitData() end)
    self:xpcall(function() QuestKingManager.Instance:RequestInitData() end)
    self:xpcall(function() NewExamManager.Instance:RequestInitData() end)
    self:xpcall(function() GloryManager.Instance:RequestInitData() end)
    self:xpcall(function() IngotCrashManager.Instance:RequestInitData() end)
    self:xpcall(function() SummerGiftManager.Instance:RequestInitData() end)
    self:xpcall(function() StarChallengeManager.Instance:RequestInitData() end)
    self:xpcall(function() BeginAutumnManager.Instance:RequestInitData() end)
    self:xpcall(function() QiXiLoveManager.Instance:RequestInitData() end)
    self:xpcall(function() ChatManager.Instance:RequestInitData() end)
    self:xpcall(function() ExquisiteShelfManager.Instance:RequestInitData() end)
    self:xpcall(function() TurntabelRechargeManager.Instance:RequestInitData() end)
    self:xpcall(function() RechargePackageManager.Instance:RequestInitData() end)
    self:xpcall(function() NationalSecondManager.Instance:RequestInitData() end)
    self:xpcall(function() CampaignAutumnManager.Instance:RequestInitData() end)
    self:xpcall(function() ShopManager.Instance:RequestInitData() end)
    self:xpcall(function() DollsRandomManager.Instance:RequestDollsData() end)
    self:xpcall(function() DoubleElevenManager.Instance:RequestInitData() end)
    self:xpcall(function() GuildDragonManager.Instance:RequestInitData() end)
    self:xpcall(function() MagicEggManager.Instance:RequestInitData() end)
    self:xpcall(function() CampaignInquiryManager.Instance:RequestInitData() end)
    self:xpcall(function() SalesPromotionManager.Instance:RequestInitData() end)
    self:xpcall(function() FashionSelectionManager.Instance:RequestInitData() end)
    self:xpcall(function() FashionDiscountManager.Instance:RequestInitData() end)
    self:xpcall(function() NewYearTurnableManager.Instance:RequestInitData() end)
    self:xpcall(function() BibleManager.Instance:send9954() end)
    self:xpcall(function() RideManager.Instance:Send17000() end)
    self:xpcall(function() RushTopManager.Instance:RequestInitData() end)
    self:xpcall(function() ArborDayShakeManager.Instance:RequestInitData() end)
    self:xpcall(function() GodsWarWorShipManager.Instance:RequestInitData() end)
    self:xpcall(function() SignDrawManager.Instance:RequestInitData() end)
    self:xpcall(function() AprilTreasureManager.Instance:RequestInitData() end)
    self:xpcall(function() ExperienceBottleManager.Instance:RequestInitData() end)
    self:xpcall(function() AgendaManager.Instance:ReqOnReConnect() end)
    self:xpcall(function() CrossArenaManager.Instance:RequestInitData() end)
    self:xpcall(function() ApocalypseLordManager.Instance:RequestInitData() end)
    self:xpcall(function() AnniversaryTyManager.Instance:RequestInitData() end)
    self:xpcall(function() ClassesChangeManager.Instance:RequestInitData() end)
    self:xpcall(function() DragonPhoenixChessManager.Instance:RequestInitData() end)
    self:xpcall(function() CanYonManager.Instance:RequestInitData() end)
    self:xpcall(function() TruthordareManager.Instance:RequestInitData() end)
    self:xpcall(function() IntegralExchangeManager.Instance:RequestInitData() end)
    self:xpcall(function() CardExchangeManager.Instance:RequestInitData() end)
    self:xpcall(function() CampaignProtoManager.Instance:RequestInitData() end)

    self:xpcall(function() SdkManager.Instance:CheckRealName() end)
    self:xpcall(function() SdkManager.Instance:CheckBindPhone() end)

    LuaTimer.Add(500, function() self:xpcall(function() SosManager.Instance:RequestInitData() end) end)
    LuaTimer.Add(1000, function() self:xpcall(function() PetManager.Instance:RequestInitData() end) end)
    LuaTimer.Add(1500, function() self:xpcall(function() TeamManager.Instance:RequestInitData() end) end)
    -- LuaTimer.Add(1500, function()
        self:xpcall(function()
            if MainUIManager.Instance then
                if MainUIManager.Instance.roleInfoView then
                    MainUIManager.Instance.roleInfoView:refresh()
                end
                if MainUIManager.Instance.petInfoView then
                    MainUIManager.Instance.petInfoView:update()
                end
                MainUIManager.Instance:ShowMainUICanvas(true)
                HomeManager.Instance:ShowCanvas(false)
                HomeManager.Instance.model:HideEditPanel()
            end
        end)
    -- end)

    self.has_login = true
end

--角色信息返回，执行初始化操作
function LoginManager:Role_Info_Loaded()
    print("角色信息返回，执行初始化操作")
    MainUIManager.Instance:initMainUICanvas()
end

function LoginManager:xpcall(call)
    local status, err = xpcall(call, function(errinfo)
        Log.Error("LoginManager:Request_On_Connet报错了 " .. tostring(errinfo)); Log.Error(debug.traceback())
    end)
    if not status then
        Log.Error("LoginManager:Request_On_Connet报错了 " .. tostring(err))
    end
end
