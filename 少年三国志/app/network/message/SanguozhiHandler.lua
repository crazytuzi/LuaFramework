local SanguozhiHandler = class("SanguozhiHandler", require("app.network.message.HandlerBase"))
  
function SanguozhiHandler:ctor(...)
     
end

function SanguozhiHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetMainGrouthInfo, self._recvMainGrouthInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UseMainGrouthInfo, self._recvUseMainGrouthInfo, self)
end

function SanguozhiHandler:_recvMainGrouthInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetMainGrouthInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_Me.sanguozhiData:setUsedInfo(decodeBuffer.used_mg)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_MAIN_GROUTH_INFO, nil, false,decodeBuffer)
    end
end

-- send
function SanguozhiHandler:sendGetMainGrouthInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetMainGrouthInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetMainGrouthInfo, msgBuffer)
end


function SanguozhiHandler:_recvUseMainGrouthInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UseMainGrouthInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_Me.sanguozhiData:setLastUsedId(decodeBuffer.id)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_USE_MAIN_GROUTH_INFO, nil, false,decodeBuffer)
    end
end

-- send
function SanguozhiHandler:sendUseMainGrouthInfo(_id,_index)
    local msg = 
    {
        id = _id,
        index = _index,
    }
    local msgBuffer = protobuf.encode("cs.C2S_UseMainGrouthInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_UseMainGrouthInfo, msgBuffer)
end


return SanguozhiHandler
