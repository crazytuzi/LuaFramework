local SpecialActivityHandler = class("SpecialActivityHandler ", require("app.network.message.HandlerBase"))

function SpecialActivityHandler:_onCtor( ... )
    self._saleCount = 0
end

function SpecialActivityHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetSpecialHolidayActivity, self._recvGetSpecialHolidayActivity, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpdateSpecialHolidayActivity, self._recvUpdateSpecialHolidayActivity, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetSpecialHolidayActivityReward, self._recvGetSpecialHolidayActivityReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetSpecialHolidaySales, self._recvGetSpecialHolidaySales, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BuySpecialHolidaySale, self._recvBuySpecialHolidaySale, self)
end

-------------recv messages

function SpecialActivityHandler:_recvGetSpecialHolidayActivity( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetSpecialHolidayActivity", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.specialActivityData:initData(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY, nil, false,decodeBuffer)

end


function SpecialActivityHandler:_recvUpdateSpecialHolidayActivity( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpdateSpecialHolidayActivity", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.specialActivityData:updateInfoList(decodeBuffer.info)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_SPECIAL_HOLIDAY_ACTIVITY, nil, false,decodeBuffer)

end


function SpecialActivityHandler:_recvGetSpecialHolidayActivityReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetSpecialHolidayActivityReward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.specialActivityData:updateInfoList(decodeBuffer.info)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY_REWARD, nil, false, decodeBuffer)
 
end

function SpecialActivityHandler:_recvGetSpecialHolidaySales( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetSpecialHolidaySales", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.specialActivityData:initSaleList(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_SALES, nil, false, decodeBuffer)
 
end

function SpecialActivityHandler:_recvBuySpecialHolidaySale( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BuySpecialHolidaySale", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    decodeBuffer.saleCount = self._saleCount
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.specialActivityData:updateSaleList(decodeBuffer)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BUY_SPECILA_HOLIDAY_SALE, nil, false, decodeBuffer)
 
end


-------------send messages

function SpecialActivityHandler:sendGetSpecialHolidayActivity( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetSpecialHolidayActivity", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetSpecialHolidayActivity, msgBuffer)
end


function SpecialActivityHandler:sendGetSpecialHolidayActivityReward(_id)
    local msg = {
       id = _id
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetSpecialHolidayActivityReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetSpecialHolidayActivityReward, msgBuffer)
end

function SpecialActivityHandler:sendGetSpecialHolidaySales()
    local msg = {
       
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetSpecialHolidaySales", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetSpecialHolidaySales, msgBuffer)
end

function SpecialActivityHandler:sendBuySpecialHolidaySale(_id,_count)
    local msg = {
       id = _id,
       cnt = _count,
    }
    self._saleCount = _count
    local msgBuffer = protobuf.encode("cs.C2S_BuySpecialHolidaySale", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BuySpecialHolidaySale, msgBuffer)
end


return SpecialActivityHandler
