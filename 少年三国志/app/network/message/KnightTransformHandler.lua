local HandlerBase = require("app.network.message.HandlerBase")
local KnightTransformHandler = class("KnightTransformHandler", HandlerBase)

function KnightTransformHandler:_onCtor()
	
end

function KnightTransformHandler:initHandler()
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KnightTransform, self._recvKnightTransform, self)
end

function KnightTransformHandler:sendKnightTransform(nKnightId, nAdvancedCode)
    local tMsg = {
        knight_id = nKnightId,
        advanced_code = nAdvancedCode,
    }
    local msgBuffer = protobuf.encode("cs.C2S_KnightTransform", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_KnightTransform, msgBuffer)
end

function KnightTransformHandler:_recvKnightTransform(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_KnightTransform", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_TRANSFORM_SUCC, nil, false, decodeBuffer)
    end
end

return KnightTransformHandler