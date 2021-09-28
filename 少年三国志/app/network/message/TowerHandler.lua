-- tower handler


local TowerHandler = class("TowerHandler", require("app.network.message.HandlerBase"))

function TowerHandler:_onCtor( ... )
    -- self.time = 0
end
  
function TowerHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerInfo, self._recvTowerInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerChallenge, self._recvChallengeReport, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerStartCleanup, self._recvStartCleanup, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerStopCleanup, self._recvStopCleanup, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerReset, self._recvReset, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerGetBuff, self._recvGetBuff, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerRfBuff, self._recvRefreshBuff, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TowerRankingList, self._recvRank, self)
end

function TowerHandler:_recvTowerInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    local timeLeft = decodeBuffer.cleanup_time - G_ServerTime:getTime()
    G_Me.towerData:setTowerInfo( decodeBuffer )
    if decodeBuffer.doing_cleanup then 
        if timeLeft > 0 then
            self:startCount(decodeBuffer.cleanup_time)
        else
            self:sendTowerRequestAward()
            self:sendQueryTowerInfo()
        end
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_INFO, nil, false,decodeBuffer)
end

function TowerHandler:startCount(time)
    -- self.time = time
    G_Me.towerData:setCleanTime(time)
end

function TowerHandler:stopCount()
    -- self.time = -1
    G_Me.towerData:setCleanTime(-1)
end

function TowerHandler:getTime()
    -- return self.time
    return G_Me.towerData:getCleanTime()
end

function TowerHandler:_recvChallengeReport(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerChallenge", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    print("ldx----------get S2C_TowerChallenge-----------------------" .. tostring(self))

    local info = G_Me.towerData:getTowerInfo()
    if decodeBuffer.battle_report.is_win then 
        info.floor = info.floor  + 1
        if info.floor >= info.next_challenge then 
            info.next_challenge = info.floor + 1
        end
    end
    G_Me.towerData:setTowerInfo(info)

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_CHALLENGE_REPORT, nil, false,decodeBuffer)
end

function TowerHandler:_recvStartCleanup(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerStartCleanup", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    self:startCount(decodeBuffer.cleanup_time)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_START_CLEANUP, nil, false,decodeBuffer)
end

function TowerHandler:_recvStopCleanup(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerStopCleanup", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    self:stopCount()
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_STOP_CLEANUP, nil, false,decodeBuffer)
end

function TowerHandler:_recvReset(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerReset", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_RESET, nil, false,decodeBuffer)
end

function TowerHandler:_recvGetBuff(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerGetBuff", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_GET_BUFF, nil, false,decodeBuffer)
end

function TowerHandler:_recvRefreshBuff(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerRfBuff", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_REFRESH_BUFF, nil, false,decodeBuffer)
end

function TowerHandler:_recvRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TowerRankingList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOWER_RANK, nil, false,decodeBuffer)
end

-- send
function TowerHandler:sendQueryTowerInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerInfo, msgBuffer)
end

function TowerHandler:sendTowerChallenge(buffId)
    local msg = 
    {
        buff_id = buffId
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerChallenge", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerChallenge, msgBuffer)
end

function TowerHandler:sendTowerStartCleanup()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerStartCleanup", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerStartCleanup, msgBuffer)
end

function TowerHandler:sendTowerStopCleanup()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerStopCleanup", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerStopCleanup, msgBuffer)
end

function TowerHandler:sendTowerReset()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerReset", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerReset, msgBuffer)
end

function TowerHandler:sendTowerGetBuff(fid)
    local msg = 
    {
        floor = fid
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerGetBuff", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerGetBuff, msgBuffer)
end

function TowerHandler:sendTowerRefreshBuff()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerRfBuff", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerRfBuff, msgBuffer)
end

function TowerHandler:sendTowerRequestAward()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerRequestReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerRequestReward, msgBuffer)
end

function TowerHandler:sendTowerRank()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_TowerRankingList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TowerRankingList, msgBuffer)
end

return TowerHandler
