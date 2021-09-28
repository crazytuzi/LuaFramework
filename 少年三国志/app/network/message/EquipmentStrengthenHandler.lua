

local EquipmentStrengthenHandler = class("EquipmentStrengthenHandler", require("app.network.message.HandlerBase"))

function EquipmentStrengthenHandler:_onCtor( ... )

end
  
function EquipmentStrengthenHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpgradeEquipment, self._recvEquipmentStrengthenInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RefiningEquipment, self._recvEquipmentRefineInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpStarEquipment, self._recvUpStarEquipment, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FastRefineEquipment, self._recvFastRefineEquipment, self)

end

function EquipmentStrengthenHandler:_recvEquipmentStrengthenInfo(msgId, msg, len)

    local decodeBuffer,err = self:_decodeBuf("cs.S2C_UpgradeEquipment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EQUIPMENT_STRENGTHEN, nil, false, decodeBuffer)
end

function EquipmentStrengthenHandler:_recvEquipmentRefineInfo(msgId, msg, len)

    local decodeBuffer,err = self:_decodeBuf("cs.S2C_RefiningEquipment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EQUIPMENT_REFINE, nil, false, decodeBuffer)
end

function EquipmentStrengthenHandler:_recvFastRefineEquipment(msgId, msg, len)

    local decodeBuffer,err = self:_decodeBuf("cs.S2C_FastRefineEquipment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EQUIPMENT_FASTREFINE, nil, false, decodeBuffer)
end

function EquipmentStrengthenHandler:sendEquipmentStrengthen(eid, times)
    local msg = 
    {
        equipment_id = eid,
        times  = times
    }

    local msgBuffer = protobuf.encode("cs.C2S_UpgradeEquipment", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_UpgradeEquipment, msgBuffer)
end

function EquipmentStrengthenHandler:sendEquipmentRefine(eid, itemId,_num)
    local msg = 
    {
        equipment_id = eid,
        item_id = itemId,
        num = _num
    }
    local msgBuffer = protobuf.encode("cs.C2S_RefiningEquipment", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RefiningEquipment, msgBuffer)
end

function EquipmentStrengthenHandler:sendFastRefineEquipment(eid, items)
    local msg = 
    {
        eid = eid,
        consume_item  = items
    }

    local msgBuffer = protobuf.encode("cs.C2S_FastRefineEquipment", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FastRefineEquipment, msgBuffer)
end

function EquipmentStrengthenHandler:sendUpStarEquipment(cost_type, equip_id)
    local msg = {
        cost_type = cost_type,
        equip_id = equip_id,
    }

    -- dump(msg)

    local msgBuffer = protobuf.encode("cs.C2S_UpStarEquipment", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_UpStarEquipment, msgBuffer)
end

function EquipmentStrengthenHandler:_recvUpStarEquipment(msgId, msg, len)
    
    local decodeBuffer,err = self:_decodeBuf("cs.S2C_UpStarEquipment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return
    end

    -- dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EQUIPMENT_STAR, nil, false, decodeBuffer)
    end
end

return EquipmentStrengthenHandler
