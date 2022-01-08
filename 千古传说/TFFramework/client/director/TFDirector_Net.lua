--
-- Author: MiYu
-- Date: 2014-02-12 11:22:13
--

local TFProtocolManager		= require('TFFramework.client.manager.TFProtocolManager')
local TFClientNet = require('TFFramework.net.TFClientNet')
local TFClientNewNet = require('TFFramework.net.TFClientNetVar')
local TFClientNewNetInstance = TFClientVarSocket:GetInstance()
local TFClientNetInstance = TFClientSocket:GetInstance()

TFDirector.nSendCount = 0
TFDirector.nReciveCount = 0

function TFDirector:description(...)
	TFDirector.bUseNewNet    			= nil

	TFDirector:addProto(nProtoType, objTarget, func)
	TFDirector:removeProto(nProtoType, objTarget, func)
	TFDirector:dispatchProtocolWith(nProtoType, tData)
	TFDirector:protoList(nProtoType)
	TFDirector:setUseNewNet( bUseNewNet )
	TFDirector:getNetWork() --返回TFClientNewNet or TFClientNet
	TFDirector:getNetWorkInstance() --返回TFClientNewNetInstance or TFClientNetInstance
	TFDirector:send(nCode, tMsg, rsa)
	TFDirector:connect(szIp, nPort, ConnectCallback, RecvCallback, CloseCallback, nType)
	TFDirector:closeSocket()
	TFDirector:setEncodeKeys(tKeys, bEncode)
	TFDirector:setConnectType(nType)
	TFDirector:setMaxCloseSec(nSec)

end


--------------------------------------------TFProtocolManager began-------------------------------

--[[--
	添加指定对象的指定协议的指定监听
	@param nProtoType:协议号
	@param objTarget:监听对象
	@param func:监听回调
]]
function TFDirector:addProto(nProtoType, objTarget, func)
	TFProtocolManager:addProtocolListener(nProtoType, objTarget, func)
end

--[[--
	移除指定对象的指定协议的指定监听
	@param nProtoType:协议号, 如果为空,表示移除所有协议的监听
	@param objTarget:监听对象, 如果为空,表示移除指定协议的所有监听
	@param func:监听回调, 如果为空,表示移除指定对象的所有监听
]]
function TFDirector:removeProto(nProtoType, objTarget, func)
	TFProtocolManager:removeProtocolListener(nProtoType, objTarget, func)
end

--[[--
	派发指定协议事件
	@param nProtoType:协议号
	@param tData:协议数据
]]
function TFDirector:dispatchProtocolWith(nProtoType, tData)
	TFProtocolManager:dispatchWith(nProtoType, tData)
end

function TFDirector:protoList(nProtoType)
	return TFProtocolManager:list(nProtoType)
end

--------------------------------------------TFProtocolManager ended-------------------------------


--------------------------------------------TFClientNet began-------------------------------
function TFDirector:getNetWork()
	if TFDirector.bUseNewNet == true then
		return TFClientNewNet
	else
		return TFClientNet
	end
end

function  TFDirector:getNetWorkInstance()
	if TFDirector.bUseNewNet == true then
		return TFClientNewNetInstance
	else
		return TFClientNetInstance
	end
end

function TFDirector:setUseNewNet( bUseNewNet )
	TFDirector.bUseNewNet = bUseNewNet
end

function TFDirector:send(nCode, tMsg, rsa)
	TFDirector.nSendCount = TFDirector.nSendCount + 1
	print(string.format("==================== send ============= 0x%04x 发送第%d条, 接收了%d条", nCode, TFDirector.nSendCount, TFDirector.nReciveCount))
	return TFDirector:getNetWork():Send(nCode,tMsg,rsa)
end

function TFDirector:isRecvSerializeEnable()
	return TFDirector:getNetWork().bRecvSerialize
end

function TFDirector:setRecvSerializeEnable(bIsEnabled)
	return TFDirector:getNetWork():setRecvSerialize(bIsEnabled)
end

function TFDirector:isSendSerializeEnable()
	return TFDirector:getNetWork().bSendSerialize
end

function TFDirector:setSendSerializeEnable(bIsEnabled)
	return TFDirector:getNetWork():setSendSerialize(bIsEnabled)
end

function TFDirector:connect(szIp, nPort, ConnectCallback, RecvCallback, CloseCallback, nType)
	return TFDirector:getNetWork():Connect(szIp, nPort, ConnectCallback, RecvCallback, CloseCallback, nType)
end

function TFDirector:closeSocket()
	TFDirector.bUseNewNet = false  --默认使用旧网络
	return TFDirector:getNetWork():CloseSocket()
end

function TFDirector:setEncodeKeys(tKeys, bEncode)
	return TFDirector:getNetWork():SetEncodeKeys(tKeys, bEncode)
end

function TFDirector:setConnectType(nType)
	return TFDirector:getNetWork():setConnectType(nType)
end

function TFDirector:setMaxCloseSec(nSec)
	return TFDirector:getNetWork():setMaxCloseSec(nSec)
end

function TFDirector:SetNetLogEnable(bEnable)
	return TFDirector:getNetWork():SetNetLogEnable(bEnable)
end

--------------------------------------------TFClientNet ended-------------------------------

return TFDirector