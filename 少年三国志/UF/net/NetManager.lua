--NetManager.lua

local NetManager = class ("NetManager")


function NetManager:ctor(  )
	self._socketArr = {}
	self._netMsgHandler = nil
	self._netEventHook = nil
end

function NetManager:init ( )
	if self._netMsgHandler == nil then 
		self._netMsgHandler = MsgProcessHandler:getInstance()

		local handler = function(event, connIndex, msgBuf, msgLen, msgId)
        	if event == "netmsg" then
            	self:onReceiveNetMsg(connIndex, msgBuf, msgLen, msgId)
        	elseif event == "connect_success" then
            	self:onConnectSuccess(connIndex)
        	elseif event == "connect_fail" then
            	self:onConnectFailed(connIndex)
        	elseif event == "connect_broken" then
            	self:onConnectBroken(connIndex)
            	-- now we move download to DownloadManager.lua, so here comment it
        	--elseif event == "download" then
            --	self:onDownloadFinish(connIndex, msgBuf)
        	elseif event == "exception" then
            	self:onNetException(connIndex, msgBuf)
        	end
        end
    	self._netMsgHandler:registerScriptHandler(handler)
	end
end

function NetManager:showNetworkLog( show )
	self:init()
	if self._netMsgHandler ~= nil then
		self._netMsgHandler:showNetworkLog(show)
	else
		__LogTag("UF", "net msg handler is nil")
	end
end

function NetManager:connectToServer( connIndex, ip, port )
	self:init()

	if self:checkConnection(connIndex) then 
		return
	end
	self._netMsgHandler:connectToServer(connIndex, ip, port)
end

function NetManager:removeConnect( connIndex )
	self:init()
	if self._netMsgHandler ~= nil then
		self._netMsgHandler:removeConnect(connIndex)
		self:setConnection(connIndex, false)
	else
		--__Log("net msg handler = nill")
	end
end

function NetManager:onReceiveNetMsg( connIndex, msgBuf, msgLen, msgId )
	uf_messageDispatcher:onNetMessage(msgId, msgBuf, msgLen)

	self:onNetReceiveEvent( msgId, content )
end

function NetManager:onConnectSuccess( connIndex )
	self:setConnection(connIndex, true)
	uf_messageDispatcher:onConnectSuccess(connIndex)
end

function NetManager:onConnectFailed( connIndex )
	self:setConnection(connIndex, false)
	uf_messageDispatcher:onConnectFailed(connIndex)
end

function NetManager:onConnectBroken( connIndex )
	self:setConnection(connIndex, false)
	uf_messageDispatcher:onConnectBroken(connIndex)
end

function NetManager:onNetException( connIndex, reason )
	self:setConnection(connIndex, false)
	uf_messageDispatcher:onNetException(connIndex)
end

function NetManager:sendMsg( msgId, content )
print("==============sendMsg ===================")
	print("url " .. msgId)
	print("===============end sendMsg=================")
	if type(content) ~= "string" or type(msgId) ~= "number" then 
		assert(0, "invalid param type!")
		return 
	end

	local ret = self._netMsgHandler:sendMessageToDefault(msgId, content, #content)

	self:onNetSendEvent( msgId, content )
end

function NetManager:hookNetEvent( func )
	self._netEventHook = func
end

function NetManager:onNetSendEvent( msgId, content )
	if self._netEventHook ~= nil then
		self._netEventHook( 1, msgId, content )
	end
end

function NetManager:onNetReceiveEvent( msgId, content )
	if self._netEventHook ~= nil then
		self._netEventHook( 0, msgId, content )
	end
end

function NetManager:checkConnection( connIndex )
	if type(connIndex) ~= "number" then 
		assert(0, "invalid parameter!")
		return true
	end

	local strConn = ""..connIndex
	if self._socketArr[strConn] ~= nil then
		return true
	end

	return false
end

function NetManager:setConnection(connIndex, connect )
	local strConn = ""..connIndex
	if connect then
		self._socketArr[strConn] = true
	else
		self._socketArr[strConn] = nil
	end
end

function NetManager:createHTTPRequestGet( url, callback, target )
	print("==============create HTTP Request ===================")
	print("url " .. url)
	print("===============end create=================")
  	local httpHandler = function ( event )
        if target ~= nil and callback ~= nil then
            callback(target, event)
        elseif callback ~= nil then
            callback(event)
        end
    end
  	local request = network.createHTTPRequest(httpHandler, url, "GET")

    return request
end

function NetManager:createHttpRequestPost( url, callback, target )
	print("==============create HTTP Request ===================")
	print("url " .. url)
	print("===============end create=================")
  	local httpHandler = function ( event )
        if target ~= nil and callback ~= nil then
            callback(target, event)
        elseif callback ~= nil then
            callback(event)
        end
    end
  	local request = network.createHTTPRequest(httpHandler, url, "POST")

    return request
end

return NetManager