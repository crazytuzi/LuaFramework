--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-06
]]
LoginController = LoginController or BaseClass(BaseController)

LoginController.type = {
    user_input  = 1,             -- 玩家输入账号和密码面板
    enter_game  = 2,             -- 默认服务器面板,这个时候已经输入账号和密码,并且已经返回了默认服务器
    server_list = 3,             -- 全部服务器列表面板
    create_role = 4,             -- 创角面板
}

function LoginController:config()
    self.model = LoginModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    self.is_ready_enter = false
    self.connect_key = ""
end

function LoginController:getModel()
    return self.model
end

-- 注意：基类BaseController会回调
function LoginController:registerEvents()
    if self.close_usr_panel == nil then
        self.close_usr_panel = self.dispather:Bind(LoginEvent.CLOSE_CHANGE_PANEL, function ()
            self:openView(LoginController.type.enter_game)
        end)
    end

    -- 默认服务器请求完成之后,开始请求
    if self.request_defualt_server_success == nil then
        self.request_defualt_server_success = self.dispather:Bind(LoginEvent.DEFAULE_SERVER_SUCCESS, function(sign)
            --不是断线重连的时候才打开面板--
            if not self.is_re_connect then
                self:openView(LoginController.type.enter_game)
            end
            -- 现在不需要默认服务器加载回来就请求全部服务器了
            -- -- 请求加载全部服务器列表,这种情况表示ios提审服,不需要加载全部服务器列表了
            if FINAL_SERVERS == nil then
                self.model:checkReloadServerData()
            end
        end)
    end

    if self.first_load_finish == nil then
        self.first_load_finish = self.dispather:Bind(SceneEvent.FIRST_TIME_LOAD_FINISH, function()
            self.is_ready_enter = true
            self:closeView()
        end)
    end

    -- 异步链接成功之后,请求角色数据,同时断掉链接事件
    if self.connet_success_event == nil then
        self.connet_success_event = self.dispather:Bind(EventId.CONNECTED, function()
            GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
            self:request1110Role()
        end)
    end

    -- 断开网络的时候,显示该面板,,以及处理断线重连相关事项
    if self.disconnect_event == nil then
        self.disconnect_event = self.dispather:Bind(EventId.DISCONNECT, function()
            local function reconnect()
                if GameNet:getInstance():IsServerConnect() then return end
                self.is_re_connect = true
                GameNet:getInstance():Connect(3000, 1)
            end

            if not GameNet:getInstance():IsServerConnect() and not _is_game_restart then
                if self.is_re_connect == true then
                    -- 非服务端主动断开链接
                    if not GameNet:getInstance():isServerDisconnet() then

                        self:openReconnect(true)
                        delayOnce(function()
                            if GameNet:getInstance():IsServerConnect() then return end
                            if GameNet:getInstance():tryNum() < 10 then
                                reconnect()
                            else
                                self:openReconnect(false)
                                GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
                                CommonAlert.show(TI18N("您的网络不稳定，是否重新连接游戏？"), TI18N("重新连接"), reconnect, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
                            end
                        end, 1)
                    end
                else
                    self:openReconnect(true)
                    ViewManager:getInstance():getMainScene():stopAllActions()
                    ViewManager:getInstance():getMainScene():runAction(cc.Sequence:create(cc.DelayTime:create(RECONNEST_INTERVAL or 5), cc.CallFunc:create(function()
                        if not GameNet:getInstance():IsServerConnect() and not GameNet:getInstance():isServerDisconnet() then
                            reconnect()
                        end
                    end)))
                end
            end
            _is_game_restart = false
        end)
    end
end

function LoginController:registerProtocals()
    self:RegisterProtocal(1110, "on1110Rolelist")       -- 角色列表

    self:RegisterProtocal(10101, "on10101Create")       -- 创建角色返回
    self:RegisterProtocal(10102, "on10102Login")        -- 登录(指定角色)
    self:RegisterProtocal(10103, "on10103ReLogin")      -- 角色重连
    self:RegisterProtocal(10310, "on10310Offline")      -- 服务器断开链接之前,先推送这条消息

    self:RegisterProtocal(10996, "onVersionStateList")  -- 版本号列表
end

--[[
    打开指定id的登陆面板
]]
function LoginController:openView(idx)
    if IS_TEST_APK == true then
        if idx == LoginController.type.enter_game then
            self:testForRquestEnterGame()
        elseif idx == LoginController.type.user_input then
            self:testForRegistAccount()
        end
    else
        -- 走这里
        -- 创建LoginWindow，打开输入面板
        if self.loginView == nil then
            self.loginView = LoginWindow.New()
            self.loginView:open(idx)
            -- 走这里
        else
            if not tolua.isnull(self.loginView.root_wnd) then
                self.loginView:showPanel(idx)
            end
        end
    end
end

--- sdk登录成功之后回调,显示版本号信息
function LoginController:showVersionLabel()
    if self.loginView then
        self.loginView:showVersionLabel()
    end
end

--[[
    在进入游戏成功之后这类的可以释放掉
]]
function LoginController:DeleteMe()
    if self.close_usr_panel then
        self.dispather:UnBind(self.close_usr_panel)
        self.close_usr_panel = nil
    end

    if self.request_defualt_server_success then
        self.dispather:UnBind(self.request_defualt_server_success)
        self.request_defualt_server_success = nil
    end

    if self.first_load_finish then
        self.dispather:UnBind(self.first_load_finish)
        self.first_load_finish = nil
    end

    if self.connet_success_event then
        self.dispather:UnBind(self.connet_success_event)
        self.connet_success_event = nil
    end

    if self.disconnect_event then
        self.dispather:UnBind(self.disconnect_event)
        self.disconnect_event = nil
    end
    self:deleteLoginView()

    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    self.is_init = false
end

--[[
    检测服务器,下载默认服务器列表
    @这里都是针对测试服或者稳定服的,手机上的是走sdk流程
]]
function LoginController:loginPlatformRequest(data)
    -- 点击登录走这里
    print("LoginController:loginPlatformRequest @@@@@@")
    if data.usrName ~= self.model:getLoginData().usrName then
        SysEnv:getInstance():set(SysEnv.keys.usrName, data.usrName, true)
        SysEnv:getInstance():set(SysEnv.keys.password, data.password, true)
    end
    if log_reg_account then log_reg_account(data.usrName) end

    self.model:getLoginData().usrName = data.usrName
    self.model:getLoginData().password = data.password

    -- IS_TEST_SERVER = PLATFORM_NAME == "demo"
    if IS_TEST_SERVER then
        -- 走这里
        local usrList = self.model:getLoginData().usrNameList
        keydelete("usr", data.usrName, usrList)
        if #usrList > 10 then
            table.remove(usrList, #usrList)
        end
        table.insert(usrList, 1, {usr=data.usrName})

        SysEnv:getInstance():set(SysEnv.keys.usrNameList, usrList, true)
    end
    self:loginNewUserRequest(data)
end

--[[
    平台账户请求(已经注册了的平台用户名)
]]
function LoginController:loginNewUserRequest(data)
    local info = {}
    info.code = 1
    info.accName=data.usrName
    info.platform = PLATFORM_NAME -- demo
    info.msg = ""
    self:loginPlatformResult(info)
end

--==============================--
--desc:请求默认服务器列表
--time:2017-11-22 09:43:26
--@data:
--@return
--==============================--
function LoginController:loginPlatformResult(data)
    if data.code == 1 then
        -- 走这里
        self.model:cacheNearLoginData(data.accName)
        if FINAL_SERVERS ~= nil then
            self.model:analysisDefualServerListForVerifyios(FINAL_SERVERS, data.accName, data.platform)
        else
            -- 走这里
            self.model:requestDefaultServerList(data.accName, data.platform)
        end
    else
        message(TI18N("登陆平台网关失败"))
    end
end

--==============================--
--desc:请求建立服务器连接
--time:2017-08-18 10:19:25
--@usrName:
--@ip:
--@port:
--@status:
--@return
--==============================--
function LoginController:requestLoginGame(usrName, ip, port, status, no_role_auto)
    if self.is_ready_enter == true then return end
    self.enter_game_status = status
    self.no_role_auto_enter = no_role_auto
    port = port or 8800
    local key = getNorKey(usrName, ip, port)
    if key == self.connect_key then
        if GameNet:getInstance():IsServerConnect() or GameNet:getInstance():IsConnecting() == true then
            return
        end
    else
        self.connect_key = key
        GameNet:getInstance():DisconnectByClient(false)
    end

    self:requestConnect(ip, port or 8800, usrName)

    local call_back = function()
        if not GameNet:getInstance():IsServerConnect() then

        else
            GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
        end
    end
    GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
    GlobalTimeTicket:getInstance():add(call_back, 3, 0, "LOGIN_REQUEST_tiket")
end

--==============================--
--desc:连接到网关
--time:2017-08-18 10:21:56
--@host:
--@port:
--@usrName:
--@return
--==============================--
function LoginController:requestConnect(host, port, usrName)
    if host == nil or host == "" then return end
    if string.find(host, ":") ~= nil then
        port = string.sub(host, string.find(host, ":")+1)
        host = string.sub(host, 1, string.find(host, ":")-1)
    end
    -- 断线重连状态
    self.is_re_connect = false
    self.account = usrName  -- 当前登录的账号

    if not GameNet:getInstance():IsServerConnect() then
        GameNet:getInstance():SetServerInfo(host, port)
        GameNet:getInstance():Connect(3000, 3)
    else
        if self.model:getLoginInfo() then
            self:on1110Rolelist(self.model:getLoginInfo())
        end
    end
end

--==============================--
--desc:登录成功返回角色列表
--time:2017-08-18 10:22:45
--@data:
--@return
--==============================--
function LoginController:on1110Rolelist(data)
    GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
    self.model:setGatewayCallState(0)
    message(data.msg)
    -- 这种情况下是服务端断点不需要重连
    if data.code == 2 then              -- 验证失败
        GameNet:getInstance():DisconnectByClient(true)
    elseif data.code == 3 then

    elseif data.code == 4 then          -- 服务器维护或者被封或者未开服
        GameNet:getInstance():DisconnectByClient(true)
        NoticeController:getInstance():openNoticeView()
    end

    if data.code ~= TRUE then return end

    -- 这里的判断主要是为了断线重连
    local role = RoleController:getInstance():getRoleVo()
    if role then
        self:request10103ReLogin(role.rid, role.srv_id)
    else
        self.model:setLoginInfo(data)
        self:handleLoginInfo()
    end
end

--==============================--
--desc:正常登陆成功
--time:2017-09-14 04:55:59
--@return
--==============================--
function LoginController:handleLoginInfo()
    if not self.is_re_connect then
        self.model:cacheNearLoginData(self.account)
        self.dispather:Fire(LoginEvent.SERVER_ROLELIST_CHANGE)
    end
    local info = self.model:getLoginInfo()
    if info == nil then return end
    local role_list = info.roles
    -- 没有角色直接打开创角面板
    if (role_list == nil or next(role_list) == nil) and self.no_role_auto_enter == true then
        self.no_role_auto_enter = false
        self:request10101Create()
    else
        if self.is_re_connect then
            local role = RoleController:getInstance():getRoleVo()
            if role then
                self:request10103ReLogin(role.rid, role.srv_id)
            else
                -- 如果是断线重连,又没有角色的时候,则切换到服务器选择面板
                self:openView(LoginController.type.server_list)
            end
        else
            if self.enter_game_status == true then
                self.enter_game_status = false
                -- 这个时候取出登陆的角色数据
                local loginData = self.model:getLoginData()
                if loginData and loginData.usrName ~= "" and loginData.srv_id ~= "" and loginData.rid ~= 0 then
                    self:request10102Login(loginData.rid, loginData.srv_id)
                else
                    -- 如果真的到了这里,其实流程是错的,但是容错一些,取第一个角色列表数据
                    local first_data = role_list[1]
                    if first_data then
                        self:request10102Login(first_data.rid, first_data.srv_id)
                    end
                end
            end
        end
    end
end

--[[
    异步链接成功之后,请求登陆
]]
function LoginController:request1110Role()
    if GameNet:getInstance():IsServerConnect() then
        local loginData = self.model:getLoginData()
        local protocal = {}
        local srv_id = loginData.srv_id or ""
        local device_id = device.getDeviceName()
        local timestamp = LoginPlatForm:getInstance():getTimestamp()
        local sessid = LoginPlatForm:getInstance():getSessid()
        local token = LoginPlatForm:getInstance():getToken()
        local sign = LoginPlatForm:getInstance():getSign()
        local channel = LoginPlatForm:getInstance():getChannel()
        local gettui_cid = device.getuiId()
        local idfa = "windows" --getIdFa()
        local php_ip = self.model.php_ip or ''

        if ICEBIRD_ACCESSTOKEN and ICEBIRD_SY_SIGN then -- 冰鸟校对
            token = ICEBIRD_ACCESSTOKEN or token
            sign = ICEBIRD_SY_SIGN
        end

        -- 是否是模拟器判断
		local is_emulator_str = device.callFunc("inEmulator")
        local is_emulator = "false"
        if is_emulator_str ~= "" then
            local frist_letter = string.sub(is_emulator_str, 1, 1)
            if frist_letter == "1" then
                is_emulator = "true"
            end
        end

        -- 上报选择服务器
        log_select_server(loginData.usrName)

        local logsign = cc.CCGameLib:getInstance():logsign(table.concat({self.account, device_id, idfa, channel, gettui_cid, is_emulator, php_ip}, ''))
        protocal.args = {{key = "account", val=self.account},
                        {key="timestamp", val=timestamp},
                        {key="enter_srv_id", val=srv_id},
                        {key="platform", val=PLATFORM_NAME},
                        {key="device_id", val=device_id},
                        {key="device_type", val=log_get_device_type and log_get_device_type() or ""},
                        {key="gettui_cid", val=gettui_cid},
                        {key="idfa", val=idfa},
                        {key="token", val=token},
                        {key="channel", val=channel},
                        {key="sign", val=sign},
                        {key="ip", val=php_ip},
                        {key="logsign", val=logsign},
                        {key="os_ver", val=callFunc("system_version")},
                        {key="carrier_name", val=callFunc("carrier_name")},
                        {key="net_type", val=device.isWifiState() and "wifi" or "数据"},
                        {key="os", val= device.platform},
                        {key="emulator", val= is_emulator},
                        {key="app_name", val=callFunc("app_name")},
                        {key="package_name", val=callFunc("package_name")},
                        {key="package_version", val=callFunc("package_version")},
                        {key="now_ver", val= string.format("v%s", now_ver())},
                        {key="srv_lock_ver", val= "v200401"},
                        {key="accflag", val= self.model.new_account_flag == 0 and "0" or "1"},
                        {key="icebird_resp", val= ICEBIRD_RESP or ""},
                        {key="icebird_body", val= ICEBIRD_BODY or ""},
                        {key="sessid", val= sessid}
                    }
        dump(protocal, "发送登录协议1110")
        local ret = self:SendProtocal(1110, protocal)
        GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
        self.model:setGatewayCallState(0)
    end
end

--==============================--
--desc:创角
--time:2017-08-07 05:14:11
--@name:
--@sex:
--@career:
--@platform:
--@return
--==============================--
function LoginController:request10101Create(name, sex, career, platform)
    if self.is_ready_enter == true then return end
    local function send_create()
        local protocal = {}
        protocal.sex = sex or 0
        protocal.name = name or ""
        protocal.career = career or 0
        protocal.playform = LoginPlatForm:getInstance():getChannel()
        self:SendProtocal(10101, protocal)
    end
    -- if CHANNEL_NAME == "mlios_zsry" then
    --     local msg = "您好，此应用暂时无法注册，请前往应用商店下载《彼方大陆》进入游戏。详细内容可咨询客服微信公众号：mlgame"
    --     CommonAlert.show(msg, TI18N("确定"), function()
    --         sdkCallFunc("openUrl", "itms://itunes.apple.com/cn/app/%E5%BD%BC%E6%96%B9%E5%A4%A7%E9%99%86-%E5%A5%87%E8%BF%B9%E8%A7%89%E9%86%92/id1288444349?mt=8")
    --     end, nil, nil, CommonAlert.type.common, nil, nil, 22)
    -- else
        send_create()
    -- end
end

--创建角色返回
function LoginController:on10101Create(data)
    if data.code == TRUE then
        local loginData = self.model:getLoginData()
        if NEED_CHECK_CLOSE and GameNet:getInstance():getTime() - loginData.open_time < 0 then
            self.model:showSrvOpen(loginData)
            return
        end

        sdkSubmitUserData(2, data)
        sdkUserEvent("af_createrole")
        self:request10102Login(data.rid, data.srv_id)
        -- 后续添加创建角色成功之后的回调
    else
        message(data.msg)
    end
end

--请求进入游戏
function LoginController:request10102Login(rid, srv_id)
    if self.is_ready_enter == true then return end
    local data = self.model:getLoginData()
    -- 上报创角
    log_create_role(data.usrName)

    if NEED_CHECK_CLOSE and GameNet:getInstance():getTime() - data.open_time < 0 then
        self.model:showSrvOpen(data)
        return
    end
    self.tmp_rid = rid
    self.tmp_srv_id = srv_id
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(10102, protocal)
end

--==============================--
--desc:请求登陆信息
--time:2017-09-14 04:55:22
--@data:
--@return
--==============================--
function LoginController:on10102Login(data)
    GameNet:getInstance():setTime(data.timestamp)       -- 同步服务端时间
    if data.code ==TRUE then
        self.model:cacheNearLoginData(self.account, self.tmp_rid, self.tmp_srv_id)
        self.model:setWorldLev(data.world_lev or 0)
        -- 世界等级以 RoleModel 为准
        RoleController:getInstance():getModel():setWorldLev(data.world_lev or 0)

        -- 初始化完成
        self:SendProtocal(10300, {})

        if not self.is_re_connect then
            self.dispather:Fire(LoginEvent.LOGIN_SUCCESS)
        end
    elseif data.code == 2 then --这个时候弹出提示,直接重启游戏
        CommonAlert.show(data.msg, TI18N("确定"), sdkOnSwitchAccount, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    else
        CommonAlert.show(data.msg, TI18N("确定"), function()
            self:openView(LoginController.type.enter_game)
        end, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    end
end

--[[
    请求断线重连
]]
function LoginController:request10103ReLogin(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(10103, protocal)
end

--==============================--
--desc:断线重连
--time:2017-09-14 04:54:09
--@data:
--@return
--==============================--
function LoginController:on10103ReLogin(data)
    GameNet:getInstance():setTime(data.timestamp)

    RoleController:getInstance():setReconnect(true)

    self:on10102Login(data)
end

--==============================--
--desc:服务端踢出角色
--time:2017-09-14 04:56:59
--@data:
--@return
--==============================--
function LoginController:on10310Offline(data)
    GameNet:getInstance():DisconnectByClient(true)
    if IS_WIN_PLATFORM == true then
        CommonAlert.show(string.format(TI18N("你断线了，原因是：%s"), data.msg), TI18N("确定"), function()
            sdkCallFunc("requestQRCode")
        end, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    else
        CommonAlert.show(string.format(TI18N("你断线了，原因是：%s"), data.msg), TI18N("确定"), sdkOnSwitchAccount, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    end
end

--[[
    获取断线重连状态
]]
function LoginController:getIsReconnect()
    return self.is_re_connect
end

--[[
    设置断线重连状态
]]
function LoginController:setReconnect(status)
    self.is_re_connect = status
end

--==============================--
--desc:断线重连中的黑幕界面
--time:2018-06-26 02:02:11
--@status:
--@return
--==============================--
function LoginController:openReconnect(status)
    if status == true then
        -- 如果是客户端断掉的,不需要出黑幕
        if GameNet:getInstance():isClientDisconnet() == true then return end

        if self.loginView and not tolua.isnull(self.loginView.root_wnd) then return end
        if self.reconnect == nil then
            self.reconnect = ReconnectView.new()
        end
        if not self.reconnect:isOpen() then
            self.reconnect:open()
        end
    else
        if self.reconnect ~= nil then
            self.reconnect:close()
            self.reconnect = nil
        end
    end
    if BattleController:getInstance():isInFight() then
        GlobalEvent:getInstance():Fire(BattleEvent.DISCONNECTVIEW,status)
    end
end

--==============================--
--desc:创建适配窗体
--time:2018-12-26 03:34:06
--@return
--==============================--
function LoginController:createFillView()
    if self.fill_view then return end
    local layout = ViewManager:getInstance():getLayerByTag(ViewMgrTag.LOADING_TAG)
    self.fill_view = FillView.new()
    self.fill_view:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    layout:addChild(self.fill_view, 10)
end

--[[
    @desc: 打开资源加载玩命加载中界面
    author:{author}
    time:2018-05-03 19:53:43
    --@status:
	--@data:
    return
]]
function LoginController:openDownLoadView(status, data)
    if status == true then
        if self.downloadView and not tolua.isnull(self.downloadView) then return end

        if self.downloadView == nil then
            self.downloadView = DownLoadView.new()
        end
        if not self.downloadView:isOpen() then
            self.downloadView:open(data)
        end
    else
        if self.downloadView ~= nil then
            self.downloadView:close()
            self.downloadView = nil
        end
    end
end

--打开用户协议界面 --by lwc
function LoginController:openUserProtoPanel(status, callback)
    if status == true then
        if self.user_proto_panel == nil then
            self.user_proto_panel = UserProtoPanel.New()
        end
        if not self.user_proto_panel:isOpen() then
            self.user_proto_panel:open(callback)
        end
    else
        if self.user_proto_panel ~= nil then
            self.user_proto_panel:close()
            self.user_proto_panel = nil
        end
    end
end

function LoginController:getReconnectView()
    return self.reconnect
end

--[[
    关闭登陆相关界面,主要在进入场景成功之后
]]
function LoginController:closeView()
    if self.loginView then
        self.loginView:close()
        self.loginView = nil
    end
    GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
    self.model:setGatewayCallState(0)
    self.is_ready_enter = false
end

function LoginController:deleteLoginView()
    if self.loginView then
        self.loginView:close()
        self.loginView = nil
    end
end

-- 版本号信息列表 根据cdn地址获取
function LoginController:onVersionStateList(data)
    local list = data.cli_ver_list or {}
    local function applyFun()
		sdkOnSwitchAccount()
	end
	local function cancelFun()
		sdkOnExit()
	end

    local len = #list
    if len == 0 then
    	check_min_ver(function(nowver, minver)
            if nowver == nil or minver == nil then return end
    		if nowver < minver then
				local msg = TI18N("检测到当前游戏不是最新版本，需要重启游戏以更新至最新版本，是否立即更新？")
				CommonAlert.show(msg, TI18N("确定"), applyFun, TI18N("取消"), cancelFun, nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    		end
    	end)
    else
    	for _, v in pairs(list) do
        	if v.cdn_patch == PLATFORM_NAME then
            	local data2 = {cli_ver=v.cli_ver, flag=TRUE}
            	self:onVersionState(data2)
            	break
        	end
    	end
    end
end

-- 版本信息返回
function LoginController:onVersionState(data)
    local ver = now_ver()
    if ver == nil then return end
    local function applyFun()
		sdkOnSwitchAccount()
	end

	local function cancelFun()
		sdkOnExit()
	end

    if ver < data.cli_ver then
		local msg = TI18N("检测到当前游戏不是最新版本，需要重启游戏以更新至最新版本，是否立即更新？")
		CommonAlert.show(msg, TI18N("确定"), applyFun, TI18N("取消"), cancelFun, nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
    end
end


function LoginController:requestSetName(name)
    local protocal = {}
    protocal.name = name or ""
    self:SendProtocal(10342, protocal)
end

--==============================--
--desc:百度云测试需要的
--time:2017-08-11 03:36:08
--@return
--==============================--
function LoginController:testForRquestEnterGame()
	local function enterGame()
    	local data = self.model:getLoginData()
	    if data.srv_id == nil or data.srv_id == "" or data.usrName == "" then
	    	self:openView(LoginController.type.user_input)
	    	return
	    end

    	if data.ip==nil or #data.ip == 0 then
    		message(TI18N("当前服务器不可用"))
	    	self:openView(LoginController.type.server_list)
    		return
    	end

        if self.last_login == nil then
            self.last_login = 0
        end

	    if GameNet:getInstance():getTime() - self.last_login > 1 then
			if GameNet:getInstance():IsServerConnect() or GameNet:getInstance():IsConnecting() then
				return
			end
	        self.last_login = GameNet:getInstance():getTime()
	        self:requestLoginGame(data.usrName, data.ip, data.port, true)
	    end
	end

	local data = self.model:getLoginData()
	if NEED_CHECK_CLOSE and (data.isClose or GameNet:getInstance():getTime() - data.open_time < 0) then
	    self.model:checkReloadServerData(data)
        return
	end
    if not self.model:isNeedReload(TI18N("优先体验服变换，需要重新加载资源才能进入游戏"), data, sdkOnSwitchAccount) then
        self.model:saveCurSrv()
        enterGame()
    end
end


function LoginController:testForRegistAccount()
	local function randomName(str)
		local result = str
		local a = string.char(math.random(65, 90))
		local b = string.char(math.random(97, 122))
		local c = string.char(math.random(48, 57))
		if math.random(3) % 3 == 0 then
			result = result..a
		elseif  math.random(3) % 2 == 0 then
			result = result..b
		else
			result = result..c
		end
		if StringUtil.getStrLen(result)<12 then
			result = randomName(result)
		end
		return result
	end
	local usr = randomName("")
	local password = tostring(math.random(100000000000, 900000000000))

	local data = {}
	data.usrName = usr
	data.password = password
	self:loginPlatformRequest(data)
end

function LoginController:isReadyEnterGame()
    return self.is_ready_enter
end
