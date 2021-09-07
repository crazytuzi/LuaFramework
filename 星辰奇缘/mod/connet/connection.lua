-- socket连接处理相关接口
Connection = Connection or BaseClass(BaseManager)

function Connection:__init()
    Connection.Instance = self

    self.handlers = {} -- 协议回调处理函数
    self.reconnectView = nil
    self.can_delay_reconnect = true

    self.cach_open = false
    --协议簇缓存排除
    self.can_cache_ = {}
    self.cach_data = {}

    self.cach_open_send = false
    --协议簇缓存排除， 发送
    self.can_cache_send = {}
    self.cache_data_send = {}
    self.cacheId = 0

    -- 模拟协议延迟时间，只在debug模式生效
    self.delayTime = 0
end

-- 载入或重载协议配置数据
function Connection:load_matedata()
    local data_protocol = require("data/data_protocol")
    ctx.Socket:LoadProtocalMatedata(data_protocol.recv, data_protocol.send)
    self.can_cache = data_protocol.can_cache
    self.can_cache_send = { }
end

-- socket建立连接时回调
function Connection:on_connected()
    Log.Debug("socket已经建立连接")

    --连上次数清零
    LoginManager.Instance.reconnet_times = 0
    LoginManager.Instance.reconnet_step = 0
    LoginManager.Instance.reconnet_time = 0
    -- WindowManager.Instance:CloseWindowById(id)
    self:CloseReconnectView()
    NoticeManager.Instance.model.confirmTips:Clear()
    NoticeManager.Instance.model.connectionConfirmTips:Clear()
    
    EventMgr.Instance:Fire(event_name.socket_connect)
end

-- socket断开连接时回调
function Connection:on_disconnected()
    if SleepManager.Instance.IsPause then
        Log.Debug("socket在后台断开连接，重新激活程序时进行重新连接")
        LoginManager.Instance.reconnet_time = 0
        LoginManager.Instance.reconnet_step = 0
        LoginManager.Instance.reconnet_onresume = true
        return
    end

    if LoginManager.Instance.timeId ~= 0 then LuaTimer.Delete(LoginManager.Instance.timeId) LoginManager.Instance.timeId = 0 end

    Log.Debug("socket已经断开连接")
    -- LoginManager.Instance.connectiong = false
    if not LoginManager.Instance.remotelogin and not LoginManager.Instance.disconnect_mark then
        if LoginManager.Instance.has_login and not LoginManager.Instance.model.login_visable then -- 如果已经登录成功，则重新登录
            if LoginManager.Instance.reconnet_time ~= 0 and Time.time - LoginManager.Instance.reconnet_time > 300 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Sure
                data.content = TI18N("重连失败，请重新登录")
                data.sureLabel = TI18N("确定")
                data.sureCallback = function() LoginManager.Instance:returnto_login(true) end
                NoticeManager.Instance:ConnectionConfirmTips(data)
                NoticeManager.Instance.model.connectionConfirmTips:SetPanelButtonEnabled(false)
            elseif LoginManager.Instance.reconnet_step == 0 then
                LoginManager.Instance.reconnet_step = 1
                LoginManager.Instance.reconnet_time = Time.time
                self:delay_reconnect(1500)
            elseif LoginManager.Instance.reconnet_step == 1 then
                if Time.time - LoginManager.Instance.reconnet_time > 15 then
                    LoginManager.Instance.reconnet_step = 2
                    LoginManager.Instance.reconnet_time = Time.time
                    self:InitReconnectView(1)
                end
                self:delay_reconnect(1500)
            elseif LoginManager.Instance.reconnet_step == 2 then
                if Time.time - LoginManager.Instance.reconnet_time > 8 then
                    LoginManager.Instance.reconnet_time = Time.time
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("重连失败，是否返回登录界面")
                    data.sureLabel = TI18N("返回")
                    data.cancelLabel = TI18N("重试")
                    if LoginManager.Instance.reconnet_times < 3 then
                        data.cancelSecond = 15
                    end
                    data.cancelCallback = function()
                        LoginManager.Instance.reconnet_step = 1
                        LoginManager.Instance.reconnet_time = Time.time
                        self:InitReconnectView(1)
                    end
                    data.sureCallback = function() LoginManager.Instance:returnto_login(true) end
                    NoticeManager.Instance:ConnectionConfirmTips(data)
                    NoticeManager.Instance.model.connectionConfirmTips:SetPanelButtonEnabled(false)

                    Connection.Instance:CloseReconnectView()
                    LoginManager.Instance.reconnet_step = 3
                    LoginManager.Instance.reconnet_time = Time.time
                    LoginManager.Instance.reconnet_times = LoginManager.Instance.reconnet_times + 1
                end
                self:delay_reconnect(1500)
            elseif LoginManager.Instance.reconnet_step == 3 then
                LoginManager.Instance.reconnet_time = Time.time
                self:delay_reconnect(1500)
            else
                LoginManager.Instance:returnto_login()
            end
        elseif CreateRoleManager.Instance.model.create_role_visable then
            NoticeManager.Instance:FloatTipsByString(TI18N("连接断开，正在重连"))
            self:delay_reconnect(3000)
        else -- 如果未登录成功，则返回登录界面
            Log.Debug("连接失败，请稍后再登录游戏")
            NoticeManager.Instance:FloatTipsByString(TI18N("您的网络好像不稳定，请检查完网络重试！"))
            LoginManager.Instance:returnto_login()
        end
    end
end

-- 设置延迟，1.5秒后断线重连
function Connection:delay_reconnect(time)
    if self.can_delay_reconnect then
        self.can_delay_reconnect = false
        LuaTimer.Add(time, function()
                self.can_delay_reconnect = true
                -- self:reconnect()
                xpcall(function() self:reconnect() end
                    , function() self:on_disconnected() end)
            end)
    end
end

-- 断线重连
function Connection:reconnect()
    Log.Debug("尝试重新连接socket")
    ctx.Socket:CreatSocklet()
    -- EventMgr.Instance:RemoveListener(event_name.socket_connect, mod_login.on_socket_connected)
    -- EventMgr.Instance:AddListener(event_name.socket_connect, mod_login.on_socket_connected)
    if not LoginManager.Instance.relogin and LoginManager.Instance.has_login then LoginManager.Instance.reconnet = true end
    LoginManager.Instance.disconnect_mark = false
    ctx.Socket:Connect(ServerConfig.target_server.host, ServerConfig.target_server.port)
end

-- 连接指定服务器
function Connection:connect(ip, port)
    ctx.Socket:CreatSocklet()
    ctx.Socket:Connect(ip, port)
end

-- 断开连接
function Connection:disconnect()
    if LoginManager.Instance.timeId ~= 0 then LuaTimer.Delete(LoginManager.Instance.timeId) LoginManager.Instance.timeId = 0 end
    -- print("断开连接 "..debug.traceback())
    local call = function() ctx.Socket:Disconnect() end
    xpcall(call, function(errinfo) Log.Error(tostring(errinfo)) end)
end

-- 通过socket发送协议数据
function Connection:send(cmd, data)
    -- BaseUtils.dump(data, string.format("发送协议数据[%s]", cmd))
    -- if LoginManager.Instance.fail_on1010 and cmd ~= 1010 then return end
    if SOCKET_DEBUG then
        local dumpFlag = false
        for _, v in ipairs(SOCKET_DEBUG_CMD) do
            if type(v) == "table" and #v == 2 then
                if cmd >= v[1] and cmd <= v[2] then
                    dumpFlag = true
                    break
                end
            elseif math.floor(cmd / 100) == v then
                dumpFlag = true
                break
            end
        end
        if dumpFlag then
            BaseUtils.dump(data, string.format("<color='#00ff00'>send <<<<<<<< %s</color>", cmd))
        end
    end

    if self.cach_open_send and self.can_cache_send[cmd] then
        table.insert( self.cache_data_send, {cmd = cmd, data = data})
        return
    end
    ctx.Socket:Send(cmd, data)
end

-- 添加协议处理函数(每次协议到达都会调用)
-- 回调格式: callback(协议数据)
function Connection:add_handler(cmd, callback)
    if self.handlers[cmd] == nil then
        self.handlers[cmd] = {}
    end
    local name = tostring(callback)
    self.handlers[cmd][name] = callback
    ctx.Socket:AddHandler(cmd, name)
end

-- 移除协议处理函数
function Connection:remove_handler(cmd, callback)
    if self.handlers[cmd] == nil then
        return
    end
    local name = tostring(callback)
    self.handlers[cmd][name] = nil
    ctx.Socket:RemoveHandler(cmd, name)
end

-- 调用协议回调处理函数(由socket底层回调)
function Connection:call_handlers(cmd)
    local funcs = self.handlers[cmd]
    if funcs == nil then
        return
    end

    if self.cach_open and self.can_cache[cmd] then
        table.insert( self.cach_data, {cmd = cmd, data = connection_recv_data})
        return
    end
    if SOCKET_DEBUG then
        local dumpFlag = false
        for _, v in ipairs(SOCKET_DEBUG_CMD) do
            if type(v) == "table" and #v == 2 then
                if cmd >= v[1] and cmd <= v[2] then
                    dumpFlag = true
                    break
                end
            elseif math.floor(cmd / 100) == v then
                dumpFlag = true
                break
            end
        end
        if dumpFlag then
            BaseUtils.dump(connection_recv_data, string.format("<color='#FF0000'>recv <<<<<<<< %s</color>", cmd))
        end
    end

    -- print(string.format("cmd = %s", cmd))
    if IS_DEBUG then
        if self.delayTime == 0 then
            -- 可以把调用栈打印出来
            for idx, cb in pairs(funcs) do
                local status = xpcall(
                    function() cb(connection_recv_data) end,
                    function(errinfo)
                        Log.Error("处理协议" .. cmd .. "的回调函数时发生异常:" .. tostring(errinfo))
                        Log.Error(debug.traceback())
                    end
                )
                if not status then
                    Log.Error("处理协议" .. cmd .. "的回调函数时发生异常")
                end
            end
        else
            local recv_data = connection_recv_data
            LuaTimer.Add(self.delayTime, function() 
                    -- 可以把调用栈打印出来
                    for idx, cb in pairs(funcs) do
                        local status = xpcall(
                            function() cb(recv_data) end,
                            function(errinfo)
                                Log.Error("处理协议" .. cmd .. "的回调函数时发生异常:" .. tostring(errinfo))
                                Log.Error(debug.traceback())
                            end
                        )
                        if not status then
                            Log.Error("处理协议" .. cmd .. "的回调函数时发生异常")
                        end
                    end
            end)
        end
    else
        for idx, cb in pairs(funcs) do
            cb(connection_recv_data)
        end
    end
end

function Connection:InitReconnectView(showType)
    if self.reconnectView == nil then
        self.reconnectView = ReconnectView.New()
        self.reconnectView:Show()
        self.reconnectView:ShowType(showType)
    else
        self.reconnectView:Show()
        self.reconnectView:ShowType(showType)
    end
end

function Connection:CloseReconnectView()
    if self.reconnectView ~= nil then
        self.reconnectView:DeleteMe()
        self.reconnectView = nil
    end
end

-- 释放协议缓存数据
function Connection:ReleaseCach()
    -- BaseUtils.dump(self.cach_data,"我擦什么鬼啊")
    local lastdata = BaseUtils.copytab(self.cach_data)
    self.cach_data = {}
    for _, data in ipairs(lastdata) do
        local funcs = self.handlers[data.cmd]
        local recv_data = data.data

        if IS_DEBUG and funcs ~= nil then
            -- 可以把调用栈打印出来
            for idx, cb in pairs(funcs) do
                local status = xpcall(
                    function() cb(recv_data) end,
                    function(errinfo)
                        Log.Error("处理协议" .. data.cmd .. "的回调函数时发生异常:" .. tostring(errinfo))
                        Log.Error(debug.traceback())
                    end
                )
                if not status then
                    Log.Error("处理协议" .. data.cmd .. "的回调函数时发生异常")
                end
            end
        elseif funcs ~= nil then
            for idx, cb in pairs(funcs) do
                cb(recv_data)
            end
        end
    end
end

-- 释放协议缓存数据, 发送
function Connection:ReleaseCachSend()
    for _, data in ipairs(self.cache_data_send) do
        ctx.Socket:Send(data.cmd, data.data)
    end
end

function Connection:OpenCach()
    -- print("启动协议缓存")
    local currid = Time.time
    self.cacheId = currid
    self.cach_open = true
    LuaTimer.Add(60000, function()
        -- print("协议缓存超时检查")
        self:CloseCach(currid)
    end)
end

function Connection:CloseCach(id, force)
    -- print("释放协议缓存")
    if id ~= nil and self.cacheId ~= id then
        return
    end
    self.cacheId = 0
    self.cach_open = false
    if force then
        -- 强制情况缓存，用于断线重连
        self.cach_data = {}
    end
    self:ReleaseCach()
end

function Connection:OpenCachSend()
    -- print("启动协议缓存，发送")
    self.cach_open_send = true
end

function Connection:CloseCachSend()
    -- print("释放协议缓存，发送")
    self.cach_open_send = false
    self:ReleaseCachSend()
end
