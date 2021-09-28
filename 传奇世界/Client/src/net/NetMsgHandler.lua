local msgDispacher = class("msgDispacher")
require "src/net/NetMsgDef"
function msgDispacher:ctor()
	--消息关联
	self.handlerTable = {}
end

--数据按照格式封装发送 -- i(int) b(bool) c(char) s(short) S(string) d(double) ..
-- function msgDispacher:sendNetDataByFmtEx(msgID,pro_str,...)
-- 	local luaEventMgr = LuaEventManager:instance()
-- 	local buffer = luaEventMgr:getLuaEventEx(msgID)
	
-- 	local netSim = require("src/net/NetSimulation")
-- 	if netSim.isRecvMsg then
-- 		netSim:logSendMsgInfo(msgID, 1)
-- 	end	

-- 	if pro_str then
-- 		buffer:writeByFmt(pro_str,...)
-- 	end
-- 	LuaSocket:getInstance():sendSocket(buffer)

-- 	log("send msg"..msgID)
-- end

-- function msgDispacher:sendNetDataByFmt(msgID,pro_str,...)
-- 	local luaEventMgr = LuaEventManager:instance()
-- 	local buffer = luaEventMgr:getLuaEvent(msgID)
	
-- 	local netSim = require("src/net/NetSimulation")
-- 	if netSim.isRecvMsg then
-- 		netSim:logSendMsgInfo(msgID, 1)
-- 	end	
	
-- 	if pro_str then
-- 		buffer:writeByFmt(pro_str,...)
-- 	end
-- 	LuaSocket:getInstance():sendSocket(buffer)
	
-- 	log("send msg"..msgID)
-- end

-- function msgDispacher:sendNetDataByFmtExEx(msgID,pro_str,...)
-- 	local luaEventMgr = LuaEventManager:instance()
-- 	local buffer = luaEventMgr:getLuaEventExEx(msgID)
	
-- 	local netSim = require("src/net/NetSimulation")
-- 	if netSim.isRecvMsg then
-- 		netSim:logSendMsgInfo(msgID, 1)
-- 	end	

-- 	if pro_str then
-- 		buffer:writeByFmt(pro_str,...)
-- 	end
-- 	LuaSocket:getInstance():sendSocket(buffer)
-- 	log("send msg"..msgID)
-- end

function msgDispacher:getNetDataById(buffer,msgId)
	if PRO_FMT_TAB[msgId] then
		return buffer:readByFmt(PRO_FMT_TAB[msgId])
	end
end

function msgDispacher:getNetDataByFmt(buffer,format)
	if format then
		return buffer:readByFmt(format)
	end
end


function msgDispacher:registerMsgHandler(msgId,handler)
	if msgId then
		if handler then
			cclog("~~~"..msgId)
		else
			cclog("~~~unregister"..msgId)
		end
		self.handlerTable[msgId] = handler
	end
end

function msgDispacher:getMsgHandler(msgId)
    return self.handlerTable[msgId]
end

function msgDispacher:registerPB()
	-- reset恢复env原始状态之后再重新加载   
    --注册PB
    require "src/protobuf"
    local buffer = cc.FileUtils:getInstance():getStringFromFile("res/protocol.pb")
    --protobuf.reset()
    protobuf.register(buffer)
end

function msgDispacher:convertBufferToTable(protoMsgName, buffer)
	local mb = buffer:getMsgBody()
    local len = buffer:getMsgBodyLen()
    if mb == nil or len == 0 then
        local t = protobuf.decode(protoMsgName, "")

        if isWindows() then
			GetProtoWriter():LogProto(msgID, protoMsgName, t, "")
		end
        
        return t
    else
        local t = protobuf.decode(protoMsgName, mb, len)
        if isWindows() then
        	GetProtoWriter():LogProto(msgID, protoMsgName, t, mb, true)
        end
        return t
    end
end

function msgDispacher:sendNetDataByTable(msgID, protoMsgName, t)
    local luaEventMgr = LuaEventManager:instance()
	local buffer = luaEventMgr:getLuaEvent(msgID)		
	if buffer then
        local cb = function(buf, len)
            --buffer:pushShort(len)
            buffer:pushData(buf, len)
        end
        
        protobuf.encode(protoMsgName, t, cb)
        if isWindows() then
	        GetProtoWriter():LogProto(msgID, protoMsgName, t, sendBuf)
	    end
	end
	LuaSocket:getInstance():sendSocket(buffer)
	log("send msg"..msgID)

	local netSim = require("src/net/NetSimulation")
	if netSim.isRecvMsg then
		netSim:logSendMsgInfo(msgID, 1, protoMsgName, t)
	end
end

function msgDispacher:sendNetDataByTableEx(msgID, protoMsgName, t)
    local luaEventMgr = LuaEventManager:instance()
	local buffer = luaEventMgr:getLuaEventEx(msgID)		
	if buffer then
        local cb = function(buf, len)
            --buffer:pushShort(len)
            buffer:pushData(buf, len)
        end
        
        protobuf.encode(protoMsgName, t, cb)
        if isWindows() then
	        GetProtoWriter():LogProto(msgID, protoMsgName, t, sendBuf)
	    end
	end
	LuaSocket:getInstance():sendSocket(buffer)
	log("send msg"..msgID)

	local netSim = require("src/net/NetSimulation")

	if netSim.isRecvMsg then
		netSim:logSendMsgInfo(msgID, 1, protoMsgName, t)
	end	
end

function msgDispacher:sendNetDataByTableExEx(msgID, protoMsgName, t)
    local luaEventMgr = LuaEventManager:instance()
	local buffer = luaEventMgr:getLuaEventExEx(msgID)		
	if buffer then
        local cb = function(buf, len)
            --buffer:pushShort(len)
            buffer:pushData(buf, len)
        end
        
        protobuf.encode(protoMsgName, t, cb)
        if isWindows() then
	        GetProtoWriter():LogProto(msgID, protoMsgName, t, sendBuf)
	    end
	end
	LuaSocket:getInstance():sendSocket(buffer)
	log("send msg, msgId:"..msgID .. ";msgName:" .. protoMsgName)

	local netSim = require("src/net/NetSimulation")
	if netSim.isRecvMsg then
		netSim:logSendMsgInfo(msgID, 1, protoMsgName, t)
	end
end

return msgDispacher
