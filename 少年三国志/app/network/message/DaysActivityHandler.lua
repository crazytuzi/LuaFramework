--DaysActivityHandler.lua


local HandlerBase = require("app.network.message.HandlerBase")

local DaysActivityHandler = class("DaysActivityHandler", HandlerBase)


function DaysActivityHandler:_onCtor( ... )
end

function DaysActivityHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDaysActivityInfo, self._onReceiveDaysActivityInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishDaysActivity, self._onReceiveFinishDaysActivity, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDaysActivitySell, self._onReceiveDaysActivitySell, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushDaysActivity, self._onReceiveDaysActivityFlush, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PurchaseActivitySell, self._onReceivePurchaseActivitySellInfo, self)

end

function DaysActivityHandler:unInitHandler( ... )
end

function DaysActivityHandler:sendGetDaysActivityInfo( ... )
local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDaysActivityInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDaysActivityInfo, msgBuffer)
end

function DaysActivityHandler:_onReceiveDaysActivityInfo(  msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDaysActivityInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.days7ActivityData:updateActivityData(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FLUSH_ACTIVITY_INFO, nil, false, decodeBuffer.ret)
    end
end

function DaysActivityHandler:sendFinishDaysActivity( activityId, indexId )
	local buffer = 
    {
        id = activityId,
        index = indexId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_FinishDaysActivity", buffer)
    self:sendMsg(NetMsg_ID.ID_C2S_FinishDaysActivity, msgBuffer)
end

function DaysActivityHandler:_onReceiveFinishDaysActivity(  msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_FinishDaysActivity", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_ACTIVITY_INFO, nil, false, decodeBuffer)
end

function DaysActivityHandler:sendDaysActivitySellInfo( ... )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDaysActivitySell", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDaysActivitySell, msgBuffer)
end

function DaysActivityHandler:_onReceiveDaysActivitySell( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDaysActivitySell", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.days7ActivityData:updateActivitySellInfo(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DAYS_ACTIVITY_SELL_INFO, nil, false, decodeBuffer.ret)
    end
end

function DaysActivityHandler:sendPurchaseActivitySell( sellId )
	local buffer = 
    {
    	id = sellId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_PurchaseActivitySell", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_PurchaseActivitySell, msgBuffer)
end

function DaysActivityHandler:_onReceivePurchaseActivitySellInfo( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_PurchaseActivitySell", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.days7ActivityData:updateSellInfo(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PURCHASE_ACTIVITY_SELL, nil, false, decodeBuffer)
    end
end

function DaysActivityHandler:_onReceiveDaysActivityFlush( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_FlushDaysActivity", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.days7ActivityData:flushActivityData(decodeBuffer.activitys)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FLUSH_ACTIVITY_INFO, nil, false, 1)
end

return DaysActivityHandler
