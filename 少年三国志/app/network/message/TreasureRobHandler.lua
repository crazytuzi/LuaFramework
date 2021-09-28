
-- treasure rob handler


local TreasureRobHandler = class("TowerHandler", require("app.network.message.HandlerBase"))

function TreasureRobHandler:_onCtor( ... )
    
end
  
function TreasureRobHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTreasureFragmentRobList, self._recvRoblistInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RobTreasureFragment, self._recvRobResultInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ComposeTreasure, self._recvComposeInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TreasureFragmentForbidBattle, self._recvForbidInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FastRobTreasureFragment, self._recvUFastRob, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_OneKeyRobTreasureFragment, self._recvOneKeyRob, self)
end

function TreasureRobHandler:_recvTreasureFragment(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetTreasureFragment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    self._onGetTreasureFragment()
end

function TreasureRobHandler:_recvRoblistInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetTreasureFragmentRobList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_ROB_LIST, nil, false,decodeBuffer)
end

function TreasureRobHandler:_recvRobResultInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RobTreasureFragment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_ROB_RESULT, nil, false,decodeBuffer)
end

function TreasureRobHandler:_recvComposeInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ComposeTreasure", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_COMPOSE, nil, false,decodeBuffer)
end

function TreasureRobHandler:_recvForbidInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TreasureFragmentForbidBattle", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_FORBID_BATTLE, nil, false,decodeBuffer)
end

function TreasureRobHandler:_recvUFastRob(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FastRobTreasureFragment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ARENA_SAO_DANG, nil, false, decodeBuffer)
    end
end 

function TreasureRobHandler:_recvOneKeyRob(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_OneKeyRobTreasureFragment", msg, len)
    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_ONE_KEY_ROB, nil, false, decodeBuffer)
    end
end

function TreasureRobHandler:sendTreasureFragmentRobList(fragmentId)
    local msg = 
    {
        base_id = fragmentId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetTreasureFragmentRobList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetTreasureFragmentRobList, msgBuffer)
end

function TreasureRobHandler:sendRobTreasureFragment(idx)
    G_commonLayerModel:setDelayUpdate(true)
    local msg = 
    {
        index = idx
    }
    local msgBuffer = protobuf.encode("cs.C2S_RobTreasureFragment", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RobTreasureFragment, msgBuffer)
end

function TreasureRobHandler:sendComposeTreasure(treasureId, composeNum)
    if composeNum == nil then
        composeNum = 1
    end

    local msg = 
    {
        treasure_id = treasureId,
        num = composeNum
    }
    local msgBuffer = protobuf.encode("cs.C2S_ComposeTreasure", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ComposeTreasure, msgBuffer)
end

function TreasureRobHandler:sendForbidBattle(itemId)
    local msg = 
    {
        item_id = itemId
    }
    local msgBuffer = protobuf.encode("cs.C2S_TreasureFragmentForbidBattle", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TreasureFragmentForbidBattle, msgBuffer)
end

--扫荡
function TreasureRobHandler:sendFastRob(_index)
    local user = {
        index = _index
    }
    local msgBuffer = protobuf.encode("cs.C2S_FastRobTreasureFragment", user) 
    
    self:sendMsg(NetMsg_ID.ID_C2S_FastRobTreasureFragment, msgBuffer)
end

-- 一键夺宝
function TreasureRobHandler:sendOneKeyRob(_fragmentID)
    local msg = 
    {
        base_id = _fragmentID
    }
    local msgBuffer = protobuf.encode("cs.C2S_OneKeyRobTreasureFragment", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_OneKeyRobTreasureFragment, msgBuffer)
end

return TreasureRobHandler

