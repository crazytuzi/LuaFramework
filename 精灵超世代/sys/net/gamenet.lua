----------------------------------------------------
---- 游戏网络相关
---- @author whjing2011@gmail.com
------------------------------------------------------
GameNet = GameNet or BaseClass()

function GameNet:__init()
    if GameNet.Instance ~= nil then
		error("[GameNet] accempt to create singleton twice!")
        return 
    end
    GameNet.Instance = self
    -- if GLOBALSOCKET then
        -- self.net_manager = GLOBALSOCKET
    -- else
        self.net_manager = cc.SmartSocket:getInstance()
        self.net_manager:Start() 
    -- end
    self.proto_mgr = ProtoMgr:getInstance()
    self.timer = GlobalTimeTicket:getInstance()

    -- login server 的链接信息
    self.is_server_disconnet = false
    self.is_server_info_set = false
    self.is_server_connected = false
    self.is_client_disconnet = false

    self.tryconnect_num = 0 
    self.game_net_id = -1
    self.timeout = 3000
    --当前指令来自的net_id
    self.time_diff = 0      -- 时间差
    -- self.msg_list = List:New()
    self.msg_list = List.New()
    self.check_time = 0

    self.re_connest_time = 0

    self:initSchedule()
    self:registerProtocals()
    self.send_cmd_idx = 0
    self.local_srv_diff_time = 0
end

function GameNet:getInstance()
	if GameNet.Instance == nil then 
        GameNet.New()
	end
	return GameNet.Instance
end

function GameNet:initSchedule()
    self.schedule_id = self.timer:add(function()
        if cc.Director:getInstance():getDeltaTime() == 0 then return end
        -- FPS_RATE = FPS_RATE + (math.max(0.1, 1 / cc.Director:getInstance():getDeltaTime() / display.DEFAULT_FPS / 0.75) - FPS_RATE)/6
        self.net_manager:Update()
        if not self.is_server_connected then return end
        self.last_heartbeat_time = self.last_heartbeat_time + 1
        if self.last_heartbeat_time >= 600 then                   -- 10秒内没收到协议，尝试对一下时间
            self:request1199()
            self.last_heartbeat_time = 0
        end
        for i = 1, 5 do 
            if not self:doOneMsg() then 
                break
            end
        end
    end, 1/display.DEFAULT_FPS)
end

-- 注册协议
function GameNet:registerProtocals()
    self.proto_mgr:RegisterCmdCallback(1044, "on1044", self)
    self.proto_mgr:RegisterCmdCallback(1098, "on1098", self)
    self.proto_mgr:RegisterCmdCallback(1196, "on1196", self)
    self.proto_mgr:RegisterCmdCallback(1199, "on1199", self)
end

-- 接收到服务器时间同步
function GameNet:on1044(data)
    self:setTime(data.time)
end

-- 接收到服务端校准时间
function GameNet:on1196(data)
    self.local_srv_diff_time = data.time - os.time({year =2019, month = 1, day =1, hour =0, min =0, sec = 00})
    -- print("==on1196=>>", self.local_srv_diff_time, data.time, os.time({year =2019, month = 1, day =1, hour =0, min =0, sec = 00}))
end

-- 接收到心跳包返回
function GameNet:on1098(data)
    self:setTime(data.srv_time)
end

-- 设置登录ip和port
function GameNet:SetServerInfo(host_name, host_port)
	self.is_server_info_set = true
	self.server_host_name = host_name
	self.server_host_port = host_port
end

-- 异步连接
function GameNet:Connect(timeout, num)
    if self.is_server_connected or self.in_async_connect then return end
	if not self.is_server_info_set then
		return false
	end

    if timeout then -- 设置超时时间
        self.timeout = timeout
    end
    if num then -- 设置尝试次数
        self.tryconnect_num = num
    end

    print("GameNet:Connect,host&port=",self.server_host_name, self.server_host_port)
	local tmp_id = self.net_manager:ConnectAsyn(self.server_host_name, self.server_host_port, self.timeout)
	if tmp_id == -1 then
		-- Debug.error("Connect failed")
		return false
	end
    self.game_net_id = tmp_id
    self.in_async_connect = true

    -- 异步连接时间给5秒.连不上就断掉重新尝试连接
    local call_back = function()
        if not self:IsServerConnect() then
            self:DisconnectServer(false)
            self:tryReconnect()
        end
    end
    self.connet_timer_id = self.timer:add(call_back, RECONNEST_INTERVAL or 5, 1)
	return true
end

-- 发送前提协议
function GameNet:SendPrev(cmd)
    if SEND_CMD_CHECK == false then return end
    if cmd == 10300 or cmd == 16601 or cmd  == 16602 or cmd == 16603 then return end
    local num = math.floor(cmd / 100)
    if num == 111 or num == 200 then return end
    self.send_cmd_idx = self.send_cmd_idx + 1
    local idx = self.send_cmd_idx
    local time = self:getTime()
    local key = "__sszg666__" or CMD_KEY
    local sign = cc.CCGameLib:getInstance():md5str(table.concat({idx, time, cmd, key}, ''))
    local data = {idx = idx, time = time, code = cmd + (idx + 5) % 16, sign = sign}
    -- print("====", idx, time, cmd, sign)
    self.net_manager:Send(self.game_net_id, 1197, data)
end

-- 协议发送
function GameNet:Send(cmd, data, timeout, timeout_call)
    if not self.is_server_connected then
        -- Debug.log("发送协议数据出错 连续已断开", cmd)
        if timeout_call then timeout_call() end
        return false
    end
    self:SendPrev(cmd)
    local result = self.net_manager:Send(self.game_net_id, cmd, data)
    if result then
        if timeout and timeout_call then 
            self.timer:add(timeout_call, timeout, 1, "send_timeout_"..cmd)
        end
        -- Debug.socket(cmd, "send", cmd, data)
    else
        if timeout_call then timeout_call() end
        -- Debug.error("发送协议数据出错", cmd)
    end
    return result
end

-- 接收到协议数据
function GameNet:Recv(cmd, netid, length)
	if self.game_net_id ~= netid then return end
    if not self.proto_mgr:hasReg(cmd) then
        -- Debug.socket(cmd, "接收到协议，但该协议未注册处理函数", cmd)
        return
    end
    -- 只要收到协议,心跳包及时就重新开始计算,
    local data, result = self.net_manager:GetRecv(cmd)
    if result and data then 
        List.PushBack(self.msg_list, {cmd, data})
        self.check_time = 0
    else 
        -- Debug.error("读取协议数据出错", cmd)
        sendErrorToSrv(string.format("协议[%s]读取出错", cmd))
    end
end

-- 处理一条信息
function GameNet:doOneMsg()
    if not List.Empty(self.msg_list) then -- self.msg_len > 0  
        local data = List.PopFront(self.msg_list)
        self.proto_mgr:cmd_callback(data[1], data[2])
        return true
    else 
        return false
    end
end

--==============================--
--desc:尝试连接
--time:2018-06-26 02:36:32
--@num:
--@return 
--==============================--
function GameNet:tryReconnect(num)
    if self.in_async_connect then return end 
    if num then
        self.tryconnect_num = num
    end
    if self.tryconnect_num > 0 then
        self:Connect()
        self.tryconnect_num = self.tryconnect_num - 1
    elseif self.tryconnect_num == 0 then
        GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
        if LoginController ~= nil then
            LoginController:getInstance():openReconnect(false)
        end
        if self.connect_alert == nil then
            self.connect_alert = CommonAlert.show(TI18N("您的网络不稳定，是否重新尝试连接"), TI18N("确定"), function()
                if LoginController ~= nil then
                    LoginController:getInstance():openReconnect(true)
                end
                self:Connect(nil, 3)
                self.connect_alert = nil
            end, TI18N("取消"), function()
                sdkOnExit()
                self.connect_alert = nil
            end, nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
        end
    end
end

--==============================--
--desc:异步链接成功之后需要把链接计时器干掉
--time:2017-09-28 02:14:49
--@is_suc:
--@netid:
--@return 
--==============================--
function GameNet:Connected(is_suc, netid)
	-- Debug.log("异步链接成功", netid, self.game_net_id)
	if self.game_net_id ~= netid then return end

    GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
    self.game_net_id = netid
    self.in_async_connect = false
	self.is_server_connected = true
    self.last_heartbeat_time = 0
    self.tryconnect_num = 3
    self.re_connest_time = 0
    self.is_server_disconnet = false
    self.is_client_disconnet = false
    self.send_cmd_idx = 0
    GlobalEvent:getInstance():Fire(EventId.CONNECTED)
    -- 确认窗体
    if self.connect_alert ~= nil then
        self.connect_alert:close()
        self.connect_alert = nil
    end
end

-- 设置服务器时间 
function GameNet:setTime(time)
    self.time_diff = time - os.time()
    -- print("===============os.date()==",os.date("%Y-%m-%d %H:%M:%S",self:getSrvLocalTime()))
    -- print("===============os.date()==",os.date("%Y-%m-%d %H:%M:%S",self:getTime()))
end

-- 尝试一次
function GameNet:tryNum()
    self.re_connest_time = self.re_connest_time + 1
    return self.re_connest_time
end

-- 获取服务器时间
function GameNet:getTime()
    return os.time() + self.time_diff
end

-- 获取服务器对应本地时间
function GameNet:getSrvLocalTime()
    return os.time() + self.time_diff - self.local_srv_diff_time
end

-- 把一个服务器时间转化为本地时间
function GameNet:toSrvLocalTime(time)
    return time - self.local_srv_diff_time
end

function GameNet:getTimeFloat()
    return os.clock()
end

-- 是否已连接
function GameNet:IsServerConnect()
    return self.is_server_connected
end

-- 是否正在建立连接
function GameNet:IsConnecting()
    return self.in_async_connect
end

--==============================--
--desc:C++那边的断开连接
--time:2018-06-26 02:30:16
--@netid:
--@return 
--==============================--
function GameNet:Disconnect(netid)
    -- 断开连接的时候要清掉这些协议,断线重连会出处理
    List.clean(self.msg_list)

    if(netid ~= self.game_net_id) then return end
    self.timer:remove(self.connet_timer_id)
    self.is_server_connected = false
    self.in_async_connect = false
    self.game_net_id = -1
    GlobalEvent:getInstance():Fire(EventId.DISCONNECT,true)
end

--==============================--
--desc:客户端主动断开连接
--time:2018-06-26 12:28:12
--@force:是否是客户端断掉的,连接过程中超时则重置掉客户端断掉状态
--@return 
--==============================--
function GameNet:DisconnectServer(force)
    self.timer:remove(self.connet_timer_id)
    if self.game_net_id ~= -1 then
        self.net_manager:Disconnect(self.game_net_id)
    end
    self.is_server_connected = false
    self.in_async_connect = false
    -- self.game_net_id = -1  -- 这里不知道为什么需要设置网关为-1,现在先注释掉
    self.is_client_disconnet = force
end

--==============================--
--desc:客户端断开连接
--time:2018-06-26 12:29:47
--@is_server:是不是服务端主动踢掉的
--@return 
--==============================--
function GameNet:DisconnectByClient(is_server, is_client)
    if is_client == nil then is_client = true end
    self:DisconnectServer(is_client)
    self:setServerDisconnect(is_server)
end

-- 销毁
function GameNet:__delete()
    self.timer:remove(self.connet_timer_id)
    self.timer:remove(self.schedule_id)
	self:DisconnectServer(true)
    self.net_manager:Stop()
    self.net_manager:DeleteMe()
    self.net_manager = nil	
	-- 这里需要注销更新函数
end

--==============================--
--desc:是否是服务器主动关闭连接的
--time:2018-06-26 12:06:03
--@return 
--==============================--
function GameNet:isServerDisconnet()
    return self.is_server_disconnet
end

--==============================--
--desc:是否是服务器断掉连接
--time:2018-06-26 12:05:02
--@bool:
--@return 
--==============================--
function GameNet:setServerDisconnect(bool)
    self.is_server_disconnet = bool
end

--==============================--
--desc:客户端断开连接的时候,不需要弹出正在连接中的黑屏窗体
--time:2018-06-26 01:56:40
--@return 
--==============================--
function GameNet:isClientDisconnet()
    return self.is_client_disconnet
end

--==============================--
--desc:当前网关
--time:2018-06-26 12:05:16
--@return 
--==============================--
function GameNet:getGameNetid()
    return self.game_net_id
end

--==============================--
--desc:心跳包
--time:2018-06-26 12:05:30
--@return 
--==============================--
function GameNet:request1199()
    -- 如果是服务端主动断开链接
    if self.is_server_disconnet == true then return end
    -- 超过两次没有心跳包的话,判定断开链接
    self.check_time = self.check_time + 1
    if self.check_time > 1 then
        self:DisconnectByClient(false, false)
        self.check_time = 0
    else
        self:Send(1199, {})
    end
end

-- 心跳包数据
function GameNet:on1199(data)
    self:setTime(data.time)
end
