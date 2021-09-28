local TreasureHandler = class("TreasureHandler ", require("app.network.message.HandlerBase"))

function TreasureHandler:_onCtor( ... )

end

function TreasureHandler :initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RefiningTreasure, self._recvRefiningTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpgradeTreasure, self._recvUpgradeTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TreasureSmelt, self._recvSmeltTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TreasureForge, self._recvForgeTreasure, self)
end

-------------recv messages

function TreasureHandler:_recvRefiningTreasure( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RefiningTreasure", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_REFINE, nil, false,decodeBuffer)
end


function TreasureHandler:_recvUpgradeTreasure( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpgradeTreasure", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_STRENGTH, nil, false,decodeBuffer)
end

function TreasureHandler:_recvSmeltTreasure( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TreasureSmelt", msg, len)
    if type(decodeBuffer) ~= "table" then
      return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_SMELT, nil, false)
    end
end

function TreasureHandler:_recvForgeTreasure( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TreasureForge", msg, len)
    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_FORGE, nil, false, decodeBuffer.id)
    end
end

-------------send messages

function TreasureHandler:sendUpgradeTreasure(_upgrade_id,_treasure_list)
    local msg = {
       -- todo
       upgrade_id = _upgrade_id,
       treasure_list = _treasure_list
    }
    local msgBuffer = protobuf.encode("cs.C2S_UpgradeTreasure", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_UpgradeTreasure, msgBuffer)
end


function TreasureHandler:sendRefiningTreasure(_refining_id,_treasure_list)
    local msg = {
       -- todo
       refining_id = _refining_id,
       treasure_list = _treasure_list,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RefiningTreasure", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RefiningTreasure, msgBuffer)
end

function TreasureHandler:sendSmeltTreasure(_smelt_index, _treasure_ids)
    local msg = {
        index = _smelt_index,
        treasure_ids = _treasure_ids
    }
    local msgBuffer = protobuf.encode("cs.C2S_TreasureSmelt", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_TreasureSmelt, msgBuffer)
end

function TreasureHandler:sendForgeTreasure(_treasure_id)
    local msg = {
        id = _treasure_id
    }
    local msgBuffer = protobuf.encode("cs.C2S_TreasureForge", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_TreasureForge, msgBuffer)
end

return TreasureHandler
