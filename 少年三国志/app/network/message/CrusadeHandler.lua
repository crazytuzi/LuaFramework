-- crusade handler


local CrusadeHandler = class("CrusadeHandler", require("app.network.message.HandlerBase"))
  
function CrusadeHandler:initHandler(...)
    
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBattleFieldInfo, self._recvGetBattleFieldInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BattleFieldDetail, self._recvGetBattleFieldDetail, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChallengeBattleField, self._recvChallengeBattleField, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BattleFieldAwardInfo, self._recvBattleFieldAwardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBattleFieldAward, self._recvGetBattleFieldAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BattleFieldShopInfo, self._recvBattleFieldShopInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BattleFieldShopRefresh, self._recvBattleFieldShopRefresh, self)
    --uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushBattleFieldInfo, self._recvFlushBattleFieldInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBattleFieldRank, self._recvBattleFieldRank, self)


end

--------------------------receive

function CrusadeHandler:_recvGetBattleFieldInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBattleFieldInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.crusadeData:setBattleFieldInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO, nil, false, decodeBuffer)
    end
    
end

function CrusadeHandler:_recvGetBattleFieldDetail(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BattleFieldDetail", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.crusadeData:setBattleFieldDetail(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_DETAIL, nil, false, decodeBuffer)
    end
    
end

function CrusadeHandler:_recvChallengeBattleField(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChallengeBattleField", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.crusadeData:setChallengeInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_CHALLENGE_REPORT, nil, false, decodeBuffer)
    end
    
end

function CrusadeHandler:_recvBattleFieldAwardInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BattleFieldAwardInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.crusadeData:setTreasureInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, nil, false, decodeBuffer)
    end
    
end

function CrusadeHandler:_recvGetBattleFieldAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBattleFieldAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.crusadeData:setTreasureInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_GET_AWARD, nil, false, decodeBuffer)
        --刷新开宝箱界面
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, nil, false, decodeBuffer)
    end
    
end

function CrusadeHandler:_recvBattleFieldShopRefresh(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BattleFieldShopRefresh", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_REFRESH_SHOP, nil, false, decodeBuffer)

        -- 免费刷新次数
        G_Me.shopData:setPetShopFreeCount(decodeBuffer.free_refresh_count)
    end  
end

function CrusadeHandler:_recvBattleFieldShopInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BattleFieldShopInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if rawget(decodeBuffer, "refresh_count") then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_GET_SHOP_INFO, nil, false, decodeBuffer.refresh_count, decodeBuffer.free_refresh_count)

        -- 免费刷新次数
        G_Me.shopData:setPetShopFreeCount(decodeBuffer.free_refresh_count)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_HAS_FREE_REFRESH_COUNT, nil, false)
    end  
end

function CrusadeHandler:_recvFlushBattleFieldInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushBattleFieldInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if rawget(decodeBuffer, "battle_field") then
        G_Me.crusadeData:setBattleFieldSample(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_FLUSH_BATTLEFIELD_INFO, nil, false, decodeBuffer)
    end

end

function CrusadeHandler:_recvBattleFieldRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBattleFieldRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CRUSADE_GET_RANK, nil, false, decodeBuffer)
    end
    
end

--------------------------send

--请求关卡信息1、进入下一关2、重置关卡3、
function CrusadeHandler:sendGetBattleFieldInfo(_type)

    if type(_type) ~= "number" or _type < 1 then 
        return 
    end

    local msg = 
    {
        bf_type = _type
    }

    --dump(msg)

    G_Me.crusadeData:setBattleFieldType(_type)

    local msgBuffer = protobuf.encode("cs.C2S_GetBattleFieldInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetBattleFieldInfo, msgBuffer)
end

--请求据点详细信息
function CrusadeHandler:sendGetBattleFieldDetail(gateId)
    local msg = 
    {
        id = gateId
    }

    if type(gateId) ~= "number" or gateId < 1 then 
        return 
    end
    
    local msgBuffer = protobuf.encode("cs.C2S_BattleFieldDetail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BattleFieldDetail, msgBuffer)
end

--获取宝藏信息
function CrusadeHandler:sendGetAwardInfo()
    local msg = 
    {
    
    }
    
    local msgBuffer = protobuf.encode("cs.C2S_BattleFieldAwardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BattleFieldAwardInfo, msgBuffer)
end

--获取宝藏
function CrusadeHandler:sendGetAward()
    local msg = 
    {
    
    }
    
    local msgBuffer = protobuf.encode("cs.C2S_GetBattleFieldAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetBattleFieldAward, msgBuffer)
end


--挑战
function CrusadeHandler:sendChallenge(gateId)
    local msg = 
    {
        id = gateId
    }

    if type(gateId) ~= "number" or gateId < 1 then 
        return 
    end
    
    local msgBuffer = protobuf.encode("cs.C2S_ChallengeBattleField", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChallengeBattleField, msgBuffer)
end

--请求商店信息
function CrusadeHandler:sendShopInfo()
    local msg = 
    {
    }
    
    local msgBuffer = protobuf.encode("cs.C2S_BattleFieldShopInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BattleFieldShopInfo, msgBuffer)
end

--刷新商店
function CrusadeHandler:sendRefreshShop(_type)
    local msg = 
    {
        type = _type
    }

    if type(_type) ~= "number" or _type < 0 then 
        return 
    end
    
    local msgBuffer = protobuf.encode("cs.C2S_BattleFieldShopRefresh", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BattleFieldShopRefresh, msgBuffer)
end

function CrusadeHandler:sendGetRankList()
    local msg = 
    {
    }
    
    local msgBuffer = protobuf.encode("cs.C2S_GetBattleFieldRank", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetBattleFieldRank, msgBuffer)
    
end

return CrusadeHandler
