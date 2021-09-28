--MessageDispatcher.lua


local MessageDispatcher = class ("MessageDispatcher")

function MessageDispatcher:ctor(  )
	self._msgMap = {}
	self._connectFun = nil
	self._connectTarget = nil
end

function MessageDispatcher:bindMsg( msgId, fun, target )
	if type(msgId) ~= "number" or fun == nil then 
		__Error("[MessageDispatcher:bindMsg] param is invalid!")
		return 
	end

	self._msgMap[""..msgId] = {fun, target}
end

function MessageDispatcher:clearMsg( ... )
	self._msgMap = {}
	self._connectFun = nil
	self._connectTarget = nil
end

function MessageDispatcher:setConnectHandler( fun, target )
	self._connectFun = fun
	self._connectTarget = target
end

function MessageDispatcher:onNetMessage( msgId, msg, len )
 	local idKey = ""..msgId
 	--__Log("[MessageDispatcher:onNetMessage] key=%s, msg=%s, len=%d", idKey, msg, len)
 	if self._msgMap[idKey] ~= nil then
 		local fun = self._msgMap[idKey][1]
 		local target = self._msgMap[idKey][2]

 		if fun ~= nil and target ~= nil then
 			fun(target, msgId, msg, len)
 		elseif fun ~= nil then
 			fun(msgId, msg, len)
 		end
 	end
end 

function MessageDispatcher:onConnectSuccess( connectIndex )
	if self._connectFun ~= nil and self._connectTarget ~= nil then
 		self._connectFun( self._connectTarget, 0, connectIndex )
 	elseif self._connectFun ~= nil then
 		self._connectFun( 0, connectIndex )
 	end
end

function MessageDispatcher:onConnectFailed( connectIndex )
	if self._connectFun ~= nil and self._connectTarget ~= nil then
 		self._connectFun( self._connectTarget, 1, connectIndex )
 	elseif self._connectFun ~= nil then
 		self._connectFun( 1, connectIndex )
 	end
end

function MessageDispatcher:onConnectBroken( connectIndex )
	if self._connectFun ~= nil and self._connectTarget ~= nil then
 		self._connectFun( self._connectTarget, 2, connectIndex )
 	elseif self._connectFun ~= nil then
 		self._connectFun( 2, connectIndex )
 	end
end

function MessageDispatcher:onNetException( connectIndex )
	if self._connectFun ~= nil and self._connectTarget ~= nil then
 		self._connectFun( self._connectTarget, 3, connectIndex )
 	elseif self._connectFun ~= nil then
 		self._connectFun( 3, connectIndex )
 	end
end

return MessageDispatcher