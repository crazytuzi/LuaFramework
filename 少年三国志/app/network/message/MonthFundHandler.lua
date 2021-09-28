-- month fund handler


local MonthFundHandler = class("MonthFundHandler", require("app.network.message.HandlerBase"))
  
function MonthFundHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetMonthFundBaseInfo, self._recvGetMonthFundBaseInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetMonthFundAwardInfo, self._recvGetMonthFundAwardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetMonthFundAward, self._recvGetMonthFundAward, self)

end

--------------------------receive

function MonthFundHandler:_recvGetMonthFundBaseInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetMonthFundBaseInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then 
        G_Me.monthFundData:updateBaseInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MONTH_FUND_BASE_INFO, nil, false,decodeBuffer)
        --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    --else
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_ERROR_CONFIG"))
        --print(G_lang:get("LANG_MONTH_FUND_ERROR_CONFIG"))
    end
    
end

function MonthFundHandler:_recvGetMonthFundAwardInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetMonthFundAwardInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then 
        G_Me.monthFundData:updateAwardInfo(decodeBuffer.fund)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MONTH_FUND_AWARD_INFO, nil, false,decodeBuffer.fund)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)

    --else
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_GET_AWARD_ERROR"))
    end
end


function MonthFundHandler:_recvGetMonthFundAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetMonthFundAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then 
        G_Me.monthFundData:updateAward(decodeBuffer.fund)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MONTH_FUND_GET_AWARD, nil, false,decodeBuffer.fund)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    --elseif decodeBuffer.ret == NetMsg_ERROR.RET_MONTH_FUND_AWARD_HAS_ACQUIRED then
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_AWARD_HAS_ACQUIRED"))  
    --else
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_AWARD_ERROR"))  
    end
    
end

--------------------------send

function MonthFundHandler:sendGetMonthFundBaseInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetMonthFundBaseInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetMonthFundBaseInfo, msgBuffer)
end

function MonthFundHandler:sendGetMonthFundAwardInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetMonthFundAwardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetMonthFundAwardInfo, msgBuffer)
end


function MonthFundHandler:sendGetMonthFundAward(_day,_type)
    local msg = 
    {
        day = _day,
        type = _type,
    }

    local msgBuffer = protobuf.encode("cs.C2S_GetMonthFundAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetMonthFundAward, msgBuffer)
end


return MonthFundHandler
