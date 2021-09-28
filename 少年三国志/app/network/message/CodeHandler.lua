--基础消息处理


local CodeHandler = class("CodeHandler", require("app.network.message.HandlerBase"))



function CodeHandler:_onCtor( ... )
    
end

function CodeHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCodeId, self._recvGetCodeId, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCode, self._recvGetCode, self)

end



function CodeHandler:sendGetCodeId()
  
    local msgBuffer = protobuf.encode("cs.C2S_GetCodeId", {}) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCodeId, msgBuffer)
end

function CodeHandler:sendGetCode()
  
    local msgBuffer = protobuf.encode("cs.C2S_GetCode", {}) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCode, msgBuffer)
end




function CodeHandler:_recvGetCodeId( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCodeId", msg, len)
    

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CODEID, nil, false, decodeBuffer.id)

end

function CodeHandler:_recvGetCode( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCode", msg, len)
    

     uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CODE, nil, false, decodeBuffer.code)

end


return CodeHandler

