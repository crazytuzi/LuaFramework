-- fund handler


local FundHandler = class("FundHandler", require("app.network.message.HandlerBase"))
  
function FundHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFundInfo, self._recvGetFundInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetUserFund, self._recvGetUserFund, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BuyFund, self._recvBuyFund, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFundAward, self._recvGetFundAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFundWeal, self._recvGetFundWeal, self)
end

function FundHandler:_recvGetFundInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFundInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.fundData:updateInfo(decodeBuffer)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FUND_INFO, nil, false,decodeBuffer)
end

function FundHandler:_recvGetUserFund(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetUserFund", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == 1 then 
        G_Me.fundData:updateUserInfo(decodeBuffer.fund)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FUND_USER_FUND, nil, false,decodeBuffer)
end

function FundHandler:_recvBuyFund(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BuyFund", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.fundData:updateUserInfo(decodeBuffer.fund)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FUND_BUY_FUND, nil, false,decodeBuffer)
end

function FundHandler:_recvGetFundAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFundAward", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.fundData:updateUserInfo(decodeBuffer.fund)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FUND_AWARD, nil, false,decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
end

function FundHandler:_recvGetFundWeal(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFundWeal", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.fundData:updateUserInfo(decodeBuffer.fund)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FUND_WEAL, nil, false,decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
end

-- send
function FundHandler:sendGetFundInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFundInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFundInfo, msgBuffer)
end

function FundHandler:sendGetUserFund()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetUserFund", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetUserFund, msgBuffer)
end

function FundHandler:sendBuyFund()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_BuyFund", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BuyFund, msgBuffer)
end

function FundHandler:sendGetFundAward(missionId)
    local msg = 
    {
        id = missionId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFundAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFundAward, msgBuffer)
end

function FundHandler:sendGetFundWeal(missionId)
    local msg = 
    {
        id = missionId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFundWeal", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFundWeal, msgBuffer)
end

return FundHandler
