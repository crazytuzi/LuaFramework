Network = {}

-- 订阅注册 消息列表
Network.MsgList = {}
-- 消息队列
Network.SendMessages = {}
Network.ReceiveMessages = {}
function Network.Start()
	Network.againFailTimes = 0 -- 总再次连接不成功次数
	Network.port = 0 -- 默认端口
	Network.MsgList = {}
	Network.ReceiveMessages = {}
	Network.SendMessages = {}
	Network.isBreakNet = false -- 是否已经断开网络
	Network.coDealMessage = coroutine.start(Network.DealMessage)
	Network.coSendMessage = coroutine.start(Network.SendMessage)
end

function Network.DealMessage()
	while true do
		for i=1,50 do -- 每次最多x条协议处理
			if next(Network.ReceiveMessages) then
				local msg = table.remove(Network.ReceiveMessages, 1)
				-- if GameConst.PRINT_PROTO then
				-- 	if msg[1]~=4015 then
				-- 		print("[@]收到  协议: " .. msg[1])
				-- 	end
				-- end
				local handler = Network.HasProtocal(msg[1])
				if handler then handler(msg[2]) end
			else
				break
			end
		end
		coroutine.step() -- coroutine.wait(0.1, co)
	end
end
function Network.SendMessage()
	while true do
		if next(Network.SendMessages) then
			local msg = table.remove(Network.SendMessages, 1)
			-- if GameConst.PRINT_PROTO then
			-- 	print("[@]发送  协议: " .. msg[1])
			-- end
			if Network.IsConneted() and not Network.isBreakNet then
				if msg[2] then
					local buff = msg[2]:SerializeToString() -- 直接
					if buff then
						networkMgr:SendMsg(buff, msg[1])
					else
						print("!!!!!!!!协议有错!!!!!!!!")
						debugFollow()
					end
				end
			else
				Network.BreakSocket()
			end
		end
		coroutine.step() -- coroutine.wait(0.1, co)
	end
end

-- 重置连接socket 次数(重新登录时使用)
function Network.ResetLinkTimes()
	networkMgr.connectTimes = 0
end
-- 是否在连接网状态
function Network.IsConneted()
	return networkMgr.isConnected
end
-- 连接游戏建立时
function Network.OnConnect()
	logWarn("[@]Game Server connected!! ")
	Network.againFailTimes = 0
	Network.isBreakNet = false
	GlobalDispatcher:DispatchEvent(EventName.NET_CONNECTED)
end
-- 重新连接游戏建立时
function Network.OnReConnect() 
	logWarn("[@]Game Server reconnected!! ")
	Network.againFailTimes = 0
	Network.isBreakNet = false
	GlobalDispatcher:DispatchEvent(EventName.NET_RECONNECT)
end
-- 通知被主动断开
function Network.OnDisconnect()
	Network.isBreakNet = true
	GlobalDispatcher:Fire(EventName.NET_DISCONNECT)
	Network.againFailTimes = Network.againFailTimes + 1
end

-- 连接
function Network.LinkServer(ip, port)
	if not port then UIMgr.Win_FloatTip("选择服务器端口不对!") return end
	if not ip then UIMgr.Win_FloatTip("选择服务器端口不对!") return end
	Network.ip = ip
	Network.port = port
	print("连接----->>", Network.ip, Network.port)
	networkMgr:SendConnect(Network.ip, Network.port)
end
function Network.ReLinkServer()
	networkMgr:SendConnect(Network.ip, Network.port)
end


-- 发送pb | 仅id 协议消息
function Network.SendMsg(msg, msgid)
	table.insert(Network.SendMessages, {msgid, msg})
end
function Network.OnMessage(msgid, buff)
	table.insert(Network.ReceiveMessages, {msgid, buff})
end
function Network.ParseMsg(pbModel, buff)
	pbModel:ParseFromString(buff)
	return pbModel
end

-- 注册协议到监听消息中， 注意不可能一消息注册多个执行器
function Network.RegistProtocal(msgid, handle)
	if Network.HasProtocal( msgid ) then
		logWarn("[@]多次订阅协议->"..msgid)
		return 
	end
	Network.MsgList[msgid] = handle
end
-- 移除协议消息监听
function Network.RemoveProtocal(msgid)
	if Network.HasProtocal( msgid ) then
		Network.MsgList[msgid] = nil
	end
end
-- 是否已经有协议消息监听器
function Network.HasProtocal( msgid )
	return Network.MsgList[msgid]
end

-- 卸载网络监听-- 
function Network.Unload()
	Network.MsgList = {}
	Network.SendMessages = {}
	Network.ReceiveMessages = {}
	if Network.coDealMessage then
		coroutine.stop(Network.coDealMessage)
		Network.coDealMessage=nil
	end
	if Network.coSendMessage then
		coroutine.stop(Network.coSendMessage)
		Network.coSendMessage=nil
	end
end
-- 关掉socket
function Network.CloseSocket()
	Network.isBreakNet = true
	Network.SendMessages = {}
	Network.ReceiveMessages = {}
	networkMgr:Close()
end
-- 主动断开并再重新启动重连
function Network.BreakSocket()
	Network.isBreakNet = true
	networkMgr:DoDisconnect()
end

-- 连接网络超时或不通提示
function Network.ShowTimeOut( msg )
	if Network.IsConneted() then return end
	Network.isBreakNet = true
	local delay = Network.againFailTimes * 5
	DelayCall(function ()
		if Network.IsConneted() then return end
		UIMgr.Win_Alter("提示", msg, "尝试连接", function ()
			if Network.IsConneted() then return end
			if Network.againFailTimes >= 3 then
				Network.againFailTimes = 0
				UIMgr.Win_Alter("提示", "非常抱歉，连接不到游戏服务器，请退出再尝试！", "退出游戏", function ()
					UnityEngine.Application.Quit()
				end)
			else
				Network.againFailTimes = Network.againFailTimes + 1
				GameLoader.LinkLoginSvr()
			end
		end)
	end, delay)
	if not Network.IsConneted() then
		GlobalDispatcher:DispatchEvent(EventName.NET_TIMEOUT)
	end
	-- LoginController:GetInstance():UserExitGame()
	
end
