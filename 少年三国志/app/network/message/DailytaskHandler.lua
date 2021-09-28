-- vip handler


local DailytaskHandler = class("DailytaskHandler", require("app.network.message.HandlerBase"))
  
function DailytaskHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDailyMission, self._recvGetDailyMission, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishDailyMission, self._recvFinishDailyMission, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDailyMissionAward, self._recvGetDailyMissionAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushDailyMission, self._recvFlushDailyMission, self)
end

function DailytaskHandler:_recvGetDailyMission(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDailyMission", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.dailytaskData:setData(decodeBuffer)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSION, nil, false,decodeBuffer)
end

function DailytaskHandler:_recvFinishDailyMission(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FinishDailyMission", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == 1 then 
        G_Me.dailytaskData:flushData(decodeBuffer.daily_mission)
        G_Me.dailytaskData:setScore(decodeBuffer.score)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DAILYTASK_FINISHDAILYMISSION, nil, false,decodeBuffer)
end

function DailytaskHandler:_recvGetDailyMissionAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDailyMissionAward", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then 
        G_Me.dailytaskData:flushBox(decodeBuffer.id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSIONAWARD, nil, false,decodeBuffer)
end

function DailytaskHandler:_recvFlushDailyMission(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushDailyMission", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.dailytaskData:flushData(decodeBuffer.daily_mission)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DAILYTASK_FLUSH, nil, false,decodeBuffer)
end

-- send
function DailytaskHandler:sendGetDailyMission()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDailyMission", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDailyMission, msgBuffer)
end

function DailytaskHandler:sendFinishDailyMission(missionId)
    local msg = 
    {
        id = missionId
    }
    local msgBuffer = protobuf.encode("cs.C2S_FinishDailyMission", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FinishDailyMission, msgBuffer)
end

function DailytaskHandler:sendGetDailyMissionAward(missionId)
    local msg = 
    {
        id = missionId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDailyMissionAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDailyMissionAward, msgBuffer)
end

return DailytaskHandler
