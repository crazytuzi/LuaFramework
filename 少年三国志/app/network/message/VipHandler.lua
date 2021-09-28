-- vip handler


local VipHandler = class("VipHandler", require("app.network.message.HandlerBase"))
  
function VipHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetVip, self._recvGetVip, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteVipDungeon, self._recvExecuteVipDungeon, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetVipDungeonCount, self._recvResetVipDungeonCount, self)

    -- 新的日常副本
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DungeonDailyInfo, self._recvDungeonDailyInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DungeonDailyChallenge, self._recvDungeonDailyChallenge, self)
end

function VipHandler:_recvGetVip(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetVip", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.userData:setVip(decodeBuffer.level)
    G_Me.vipData:setVip(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIP_GETVIP, nil, false,decodeBuffer)
end

function VipHandler:_recvExecuteVipDungeon(msgId, msg, len)
    print("_recvExecuteVipDungeon")
    local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteVipDungeon", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)

    if decodeBuffer.ret == 1 then 
        G_Me.vipData:setLeftCount(decodeBuffer.vip_dungeon_count)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIP_EXECUTE, nil, false,decodeBuffer)
end

function VipHandler:_recvResetVipDungeonCount(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ResetVipDungeonCount", msg)
    -- dump(decodeBuffer)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == 1 then 
        G_Me.vipData:setVipResetCost(decodeBuffer.vip_reset_cost)
        G_Me.vipData:setLeftCount(decodeBuffer.vip_dungeon_count)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIP_RESET, nil, false,decodeBuffer)
end

-- 新的日常副本
function VipHandler:_recvDungeonDailyInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_DungeonDailyInfo", msg, len)
    if type(decodeBuffer) ~= "table" then
        return
    end

    -- dump(decodeBuffer)
    -- 后端传过来的是已经打过的副本
    if rawget(decodeBuffer, "dids") then
        G_Me.vipData:setUnbeatenDungeons(decodeBuffer.dids)
    else
        local dids = {}
        G_Me.vipData:setUnbeatenDungeons(dids)
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_DAILY_INFO, nil, false, decodeBuffer)
end

function VipHandler:_recvDungeonDailyChallenge( msgId, msg, len )
    __Log("VipHandler:_recvDungeonDailyChallenge")
    local decodeBuffer = self:_decodeBuf("cs.S2C_DungeonDailyChallenge", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end
    -- dump(decodeBuffer.dids)
    -- 此时进行所有副本状态的更新，以防战斗播放的时候断网，回来造成副本状态没有刷新的情况
    if rawget(decodeBuffer, "dids") then
        G_Me.vipData:setUnbeatenDungeons(decodeBuffer.dids)
    else
        local dids = {}
        G_Me.vipData:setUnbeatenDungeons(dids)
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_DAILY_CHALLENGE, nil, false, decodeBuffer)
    end
end


-- send
function VipHandler:sendGetVip()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetVip", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetVip, msgBuffer)
end

function VipHandler:sendExecuteVipDungeon(stageId)
    local msg = 
    {
        id = stageId
    }
    local msgBuffer = protobuf.encode("cs.C2S_ExecuteVipDungeon", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExecuteVipDungeon, msgBuffer)
end

function VipHandler:sendResetVipDungeonCount()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetVipDungeonCount", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetVipDungeonCount, msgBuffer)
end

-- 新的日常副本
function VipHandler:sendGetDungeonDailyInfo(  )
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_DungeonDailyInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_DungeonDailyInfo, msgBuffer)
    __Log("VipHandler:sendGetDungeonDailyInfo")
end

function VipHandler:sendDungeonDailyChallenge( id, hardLevel  )
    local msg = 
    {
        did = id,
        hard_level = hardLevel
    }
    local msgBuffer = protobuf.encode("cs.C2S_DungeonDailyChallenge", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_DungeonDailyChallenge, msgBuffer)
    __Log("VipHandler:sendDungeonDailyChallenge")
end

return VipHandler
