-- RCardHandler


local RCardHandler = class("RCardHandler", require("app.network.message.HandlerBase"))
  
function RCardHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RCardInfo, self._recvRCardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PlayRCard, self._recvPlayRCard, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetRCard, self._recvResetRCard, self)
end

function RCardHandler:_recvRCardInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RCardInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.rCardData:updateInfo(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RCARDINFO, nil, false,decodeBuffer)
end

function RCardHandler:_recvPlayRCard(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PlayRCard", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        G_Me.rCardData:play(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RCARDPLAY, nil, false,decodeBuffer)
    end
end

function RCardHandler:_recvResetRCard(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ResetRCard", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.rCardData:resetRCard(decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RCARDRESET, nil, false,decodeBuffer)
    end
end

-- send
function RCardHandler:sendRCardInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RCardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RCardInfo, msgBuffer)
end

function RCardHandler:sendPlayRCard(_id,_pos)
    local msg = 
    {
        id = _id,
        pos = _pos,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_PlayRCard", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PlayRCard, msgBuffer)
end

function RCardHandler:sendResetRCard(_id)
    local msg = 
    {
        id = _id,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_ResetRCard", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetRCard, msgBuffer)
end

return RCardHandler
