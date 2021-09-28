-- wush handler


local WushHandler = class("WushHandler", require("app.network.message.HandlerBase"))
  
function WushHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushInfo, self._recvWushInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushChallenge, self._recvChallengeReport, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushReset, self._recvReset, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushGetBuff, self._recvGetBuff, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushApplyBuff, self._recvApplyBuff, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushRankingList, self._recvRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushBuy, self._recvBuy, self)

    -- 三国无双精英boss相关
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushBossInfo, self._recvWushBossInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushBossChallenge, self._recvWushBossChallenge, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_WushBossBuy, self._recvWushBossBuy, self)
end

function WushHandler:_recvWushInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
   -- dump(decodeBuffer)
    G_Me.wushData:setWushInfo( decodeBuffer )
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_INFO, nil, false,decodeBuffer)
end

function WushHandler:_recvChallengeReport(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushChallenge", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        if rawget(decodeBuffer,"battle_report") and not decodeBuffer.battle_report.is_win then 
            G_Me.wushData:battleLose()
        else
            G_Me.wushData:battleWin(decodeBuffer.index + 1)
        end
        G_Me.wushData._buyId = decodeBuffer.buy_id
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_CHALLENGE_REPORT, nil, false,decodeBuffer)
end

function WushHandler:_recvReset(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushReset", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.wushData:battleReset(rawget(decodeBuffer,"max_clean"))
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_RESET, nil, false,decodeBuffer)
end

function WushHandler:_recvGetBuff(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushGetBuff", msg)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.wushData:setBuffToChoose(decodeBuffer.buff_id)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_GET_BUFF, nil, false,decodeBuffer)
end

function WushHandler:_recvApplyBuff(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushApplyBuff", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.wushData:AddBuff()
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_APPLY_BUFF, nil, false,decodeBuffer)
end

function WushHandler:_recvRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushRankingList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_RANK, nil, false,decodeBuffer)
end

function WushHandler:_recvBuy(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushBuy", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.wushData._bought = true
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_BUY, nil, false,decodeBuffer)
end

-- send
function WushHandler:sendQueryWushInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushInfo, msgBuffer)
end

function WushHandler:sendWushChallenge(_index,_clean,delay)
    G_commonLayerModel:setDelayUpdate(delay)
    local msg = 
    {
        index = _index,
        clean = _clean,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_WushChallenge", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushChallenge, msgBuffer)
end

function WushHandler:sendWushReset()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushReset", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushReset, msgBuffer)
end

function WushHandler:sendWushGetBuff()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushGetBuff", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushGetBuff, msgBuffer)
end

function WushHandler:sendWushApplyBuff(buffId)
    local msg = 
    {
        buff_id = buffId
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushApplyBuff", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushApplyBuff, msgBuffer)
end

function WushHandler:sendWushRank()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushRankingList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushRankingList, msgBuffer)
end

function WushHandler:sendBuy()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushBuy", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_WushBuy, msgBuffer)
end

-- 三国无双精英boss相关协议收发
function WushHandler:_recvWushBossInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushBossInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    -- if decodeBuffer.ret == 1 then
        G_Me.wushData:setBossInfo(decodeBuffer)
    -- end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_BOSS_INFO, nil, false, decodeBuffer)
end

function WushHandler:_recvWushBossChallenge( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushBossChallenge", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_BOSS_CHALLENGE, nil, false, decodeBuffer)
    end
end

function WushHandler:_recvWushBossBuy( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_WushBossBuy", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then
        G_Me.wushData:setBossBuyChallengeTimes(G_Me.wushData:getBossBuyChallengeTimes() + 1)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WUSH_BOSS_BUY, nil, false, decodeBuffer)
end

function WushHandler:sendWushBossInfo(  )
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushBossInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_WushBossInfo, msgBuffer)
end

function WushHandler:sendWushBossChallenge( bossId )
    local msg = 
    {
        id = bossId
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushBossChallenge", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_WushBossChallenge, msgBuffer)
end

function WushHandler:sendWushBossBuy(  )
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_WushBossBuy", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_WushBossBuy, msgBuffer)
end

return WushHandler
