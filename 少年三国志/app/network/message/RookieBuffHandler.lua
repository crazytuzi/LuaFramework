-- rookie buff handler


local RookieBuffHandle = class("RookieBuffHandle", require("app.network.message.HandlerBase"))
  
function RookieBuffHandle:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RookieInfo, self._recvGetRookieInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRookieReward, self._recvGetRookieReward, self)

end

--------------------------receive

function RookieBuffHandle:_recvGetRookieInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RookieInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --if decodeBuffer.ret == NetMsg_ERROR.RET_OK then 
        G_Me.rookieBuffData:updateRookieInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROOKIE_GET_INFO, nil, false, decodeBuffer)
    --end
    
end


function RookieBuffHandle:_recvGetRookieReward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRookieReward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then 
        G_Me.rookieBuffData:updateAward(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROOKIE_GET_REWARD, nil, false, decodeBuffer)
    end
    
end

--------------------------send

function RookieBuffHandle:sendGetRookieInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RookieInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RookieInfo, msgBuffer)
end


function RookieBuffHandle:sendGetRookieReward(_id)
    local msg = 
    {
        id = _id
    }

    local msgBuffer = protobuf.encode("cs.C2S_GetRookieReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRookieReward, msgBuffer)
end


return RookieBuffHandle
