----------------------------------------------------
---- SmartSocket网络回调处理
---- @author whjing2011@gmail.com
------------------------------------------------------

-- 接收到协议数据
function OnNetRecv(cmd, netid, length)
    GameNet:getInstance():Recv(cmd, netid, length)
end

--[[
	链接断开回调
	这里需要判断一下是否需要断线重连
]]
function OnNetDisconnect(netid)
	-- 服务器主动断开的,不做任何处理
    if GameNet:getInstance() and 
        GameNet:getInstance():getGameNetid() > 0 and 
        (GameNet:getInstance():getGameNetid() ~= netid or GameNet:getInstance():isServerDisconnet()) then 
        return 
    end
    -- 处理断开链接相关数据
    GameNet:getInstance():Disconnect(netid)
end

-- 连接成功回调
function OnNetAsyncConnected(result, netid)
	if LoginController and LoginController:getInstance() then
		LoginController:getInstance():openReconnect(false)
	end
    GameNet:getInstance():Connected(result, netid)
end

-- 发送数据
function Send(cmd, data, timeout, timeout_call)
    return GameNet:getInstance():Send(cmd, data, timeout, timeout_call)
end
