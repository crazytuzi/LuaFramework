-- City message handler

local AwakenShopHandler = class("AwakenShopHandler", require("app.network.message.HandlerBase"))

function AwakenShopHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AwakenShopInfo, self._receiveAwakenShopInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AwakenShopRefresh, self._receiveAwakenShopRefresh, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetShopTag, self._receiveGetShopTag, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddShopTag, self._receiveAddShopTag, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DelShopTag, self._receiveDelShopTag, self)

end

function AwakenShopHandler:sendGetShopTag()
    local msgBuffer = protobuf.encode("cs.C2S_GetShopTag", {})
    self:sendMsg(NetMsg_ID.ID_C2S_GetShopTag, msgBuffer)
end

-- 返回被标记的所有觉醒道具的id
function AwakenShopHandler:_receiveGetShopTag(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_GetShopTag", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then 
        G_Me.shopData:setAwakenTags(message.ids)
    end 
    -- 设置一下list 
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GetShopTag, nil, false )
end

function AwakenShopHandler:sendAddShopTag(_id )
    if G_Me.shopData:isAwakenTags(_id) then 
        return 
    end 
    local msgBuffer = protobuf.encode("cs.C2S_AddShopTag", {id = _id})
    self:sendMsg(NetMsg_ID.ID_C2S_AddShopTag, msgBuffer)
end

 
function AwakenShopHandler:_receiveAddShopTag(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_AddShopTag", msg ,len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then 
        G_Me.shopData:setAwakenTags(message.ids)
    end 
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AddShopTag, nil, false )
end

function AwakenShopHandler:sendDelShopTag(_id )
    if not G_Me.shopData:isAwakenTags(_id) then 
        return 
    end 
    local msgBuffer = protobuf.encode("cs.C2S_DelShopTag", {id = _id })
    self:sendMsg(NetMsg_ID.ID_C2S_DelShopTag, msgBuffer)
end

function AwakenShopHandler:_receiveDelShopTag(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_DelShopTag", msg ,len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then 
        G_Me.shopData:setAwakenTags(message.ids)
    end 
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DelShopTag, nil, false )
end




function AwakenShopHandler:sendAwakenShopInfo()
    local msgBuffer = protobuf.encode("cs.C2S_AwakenShopInfo", {})
    self:sendMsg(NetMsg_ID.ID_C2S_AwakenShopInfo, msgBuffer)
end

function AwakenShopHandler:sendAwakenShopRefresh(_type)
    local msgBuffer = protobuf.encode("cs.C2S_AwakenShopRefresh", {type=_type})
    self:sendMsg(NetMsg_ID.ID_C2S_AwakenShopRefresh, msgBuffer)
end

function AwakenShopHandler:_receiveAwakenShopInfo(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_AwakenShopInfo", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AWAKEN_SHOP_REFRESH_COUNT_NOTI, nil, false, message.refresh_count, message.free_refresh_count)

    -- 免费刷新次数
    G_Me.shopData:setAwakenShopFreeCount(message.free_refresh_count)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_HAS_FREE_REFRESH_COUNT, nil, false)
end

function AwakenShopHandler:_receiveAwakenShopRefresh(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_AwakenShopRefresh", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AWAKEN_SHOP_REFRESH_NOTI, nil, false, message)

    -- 免费刷新次数
    G_Me.shopData:setAwakenShopFreeCount(message.free_refresh_count)
end

return AwakenShopHandler


