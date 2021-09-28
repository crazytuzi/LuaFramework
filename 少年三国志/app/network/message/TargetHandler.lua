-- target message handler

local TargetHandler = class("TargetHandler", require("app.network.message.HandlerBase"))

function TargetHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TargetInfo, self._receiveTargetInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TargetGetReward, self._receiveTargetReward, self)
end

function TargetHandler:sendTargetInfo()
    local msgBuffer = protobuf.encode("cs.C2S_TargetInfo", {})
    self:sendMsg(NetMsg_ID.ID_C2S_TargetInfo, msgBuffer)
end

function TargetHandler:sendTargetGetReward(targetType)
    local msgBuffer = protobuf.encode("cs.C2S_TargetGetReward", {t=targetType})
    self:sendMsg(NetMsg_ID.ID_C2S_TargetGetReward, msgBuffer)
end

function TargetHandler:_receiveTargetInfo(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_TargetInfo", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    G_Me.achievementData:setData(message)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TARGET_INFO, nil, false, G_Me.achievementData:getData())
end

function TargetHandler:_receiveTargetReward(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_TargetGetReward", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TARGET_GET_REWARD, nil, false, message)
    end
end

return TargetHandler

