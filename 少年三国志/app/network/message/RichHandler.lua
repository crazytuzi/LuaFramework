-- rich handler


local RichHandler = class("RichHandler", require("app.network.message.HandlerBase"))
  
function RichHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RichInfo, self._recvRichInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RichMove, self._recvRichMove, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RichReward, self._recvRichReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RichRankingList, self._recvRichRankingList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RichBuy, self._recvRichBuy, self)
end

function RichHandler:_recvRichInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RichInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.richData:updateInfo(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RICH_INFO, nil, false,decodeBuffer)
end

function RichHandler:_recvRichMove(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RichMove", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        G_Me.richData:play(decodeBuffer,self._dice)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR2 then
        self:sendRichInfo()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RICH_MOVE, nil, false,decodeBuffer)
end

function RichHandler:_recvRichReward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RichReward", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.richData:refreshReward(self.sendRewardType,self.sendRewardId)
        decodeBuffer["type"]=self.sendRewardType
        decodeBuffer["id"]=self.sendRewardId
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR2 then
        self:sendRichInfo()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RICH_REWARD, nil, false,decodeBuffer)
end

function RichHandler:_recvRichRankingList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RichRankingList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.richData:setList(decodeBuffer.ranking)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RICH_RANK, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR2 then
        self:sendRichInfo()
    end
    
end

function RichHandler:_recvRichBuy(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RichBuy", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        G_Me.richData:buySuccess(self._buyId,self._buyCount)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR2 then
        self:sendRichInfo()
    end
    decodeBuffer["id"]=self._buyId
    decodeBuffer["count"]=self._buyCount
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RICH_BUY, nil, false,decodeBuffer)
end

-- send
function RichHandler:sendRichInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RichInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RichInfo, msgBuffer)
end

function RichHandler:sendRichMove(_id , _times)
    local msg = 
    {
        dice = _id,
        count = _times,
        step = G_Me.richData:getStep(),
    }
    -- dump(msg)
    self._dice = _id
    local msgBuffer = protobuf.encode("cs.C2S_RichMove", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RichMove, msgBuffer)
end

function RichHandler:sendRichReward(_type,_id)
    _id = _id or 0
    local msg = 
    {
        type = _type,
        id = _id,
    }
    self.sendRewardType = _type
    self.sendRewardId = _id
    local msgBuffer = protobuf.encode("cs.C2S_RichReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RichReward, msgBuffer)
end

function RichHandler:sendRichRankingList()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RichRankingList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RichRankingList, msgBuffer)
end

function RichHandler:sendRichBuy(_id ,_count)
    local msg = 
    {
        id = _id,
        count = _count,
    }
    self._buyId = _id
    self._buyCount = _count
    local msgBuffer = protobuf.encode("cs.C2S_RichBuy", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RichBuy, msgBuffer)
end

return RichHandler
