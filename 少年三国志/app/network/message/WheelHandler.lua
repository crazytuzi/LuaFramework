-- wheel handler


local WheelHandler = class("WheelHandler", require("app.network.message.HandlerBase"))
  
function WheelHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WheelInfo, self._recvWheelInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PlayWheel, self._recvPlayWheel, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WheelReward, self._recvWheelReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WheelRankingList, self._recvWheelRankingList, self)
end

function WheelHandler:_recvWheelInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WheelInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.wheelData:updateInfo(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WHEEL_INFO, nil, false,decodeBuffer)
end

function WheelHandler:_recvPlayWheel(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PlayWheel", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        G_Me.wheelData:play(decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR1 then
        self:sendWheelInfo()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PLAY_WHEEL, nil, false,decodeBuffer)
end

function WheelHandler:_recvWheelReward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WheelReward", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.wheelData.got_reward = true
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR1 then
        self:sendWheelInfo()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WHEEL_REWARD, nil, false,decodeBuffer)
end

function WheelHandler:_recvWheelRankingList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WheelRankingList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.wheelData:setList(decodeBuffer.ranking)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR1 then
        self:sendWheelInfo()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WHEEL_RANK, nil, false,decodeBuffer)
end

-- send
function WheelHandler:sendWheelInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WheelInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WheelInfo, msgBuffer)
end

function WheelHandler:sendPlayWheel(_id , _times)
    local msg = 
    {
        id = _id,
        times = _times,
    }
    dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_PlayWheel", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PlayWheel, msgBuffer)
end

function WheelHandler:sendWheelReward()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WheelReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WheelReward, msgBuffer)
end

function WheelHandler:sendWheelRankingList()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WheelRankingList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WheelRankingList, msgBuffer)
end

return WheelHandler
