-- share message handler
require "app.cfg.share_info"
local ShareHandler = class("ShareHandler", require("app.network.message.HandlerBase"))

function ShareHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Share, self._receiveShare, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetShareState, self._receiveShareState, self)
end

function ShareHandler:sendShare(configId)
    local msgBuffer = protobuf.encode("cs.C2S_Share", {id=configId, extra=1})
    self:sendMsg(NetMsg_ID.ID_C2S_Share, msgBuffer)
end

function ShareHandler:sendShareState(_t)
    local msgBuffer = protobuf.encode("cs.C2S_GetShareState", {t=_t})
    self:sendMsg(NetMsg_ID.ID_C2S_GetShareState, msgBuffer)
end

function ShareHandler:_receiveShare(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_Share", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_SHARE_FINISH, nil, false, message)
end

function ShareHandler:_receiveShareState(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_GetShareState", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    -- dump(message)
    for i=1, #message.state do
        local info = share_info.get(message.state[i].id)
        assert(info, "Could not find the share info with id: "..message.state[i].id)

        if info.use_type == 1 then  -- 1表示分享项，这里认为发来的都是1
            G_Me.activityData.share:set(message.state)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_SHARE_INFO, nil, false, message)
            break
        elseif info.use_type == 2 then  -- 2表示手机绑定项，同上认为发来的也都是2
            G_Me.activityData.phone:setState(message.state[i].step)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_PHONE_BIND_NOTI, nil, false, message)
            break
        end
    end
end

return ShareHandler
