-- recycle message handler

local RecycleHandler = class("RecycleHandler", require("app.network.message.HandlerBase"))

local QUIPMENT_REBORN_RESULT = 0    
local QUIPMENT_REBORN_PREREVIEW = 1

function RecycleHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecycleKnight, self._receiveRecycleKnight, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecycleEquipment, self._receiveRecycleEquipment, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecycleTreasure, self._receiveRecycleTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecyclePet, self._receiveRecyclePet, self)

    -- 装备重生
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebornEquipment, self._receiveRebornEquipment, self)
end

function RecycleHandler:sendRecycleKnight(knights)
    local msgBuffer = protobuf.encode("cs.C2S_RecycleKnight", knights)
    self:sendMsg(NetMsg_ID.ID_C2S_RecycleKnight, msgBuffer)
end

function RecycleHandler:sendRecycleEquipment(equipments)
    local msgBuffer = protobuf.encode("cs.C2S_RecycleEquipment", equipments)
    self:sendMsg(NetMsg_ID.ID_C2S_RecycleEquipment, msgBuffer)
end

function RecycleHandler:sendRecycleTreasure(treasures)
    local msgBuffer = protobuf.encode("cs.C2S_RecycleTreasure", treasures)
    self:sendMsg(NetMsg_ID.ID_C2S_RecycleTreasure, msgBuffer)
end

function RecycleHandler:_receiveRecycleKnight(msgId, msg, len)
    -- handle recycle message
    local message = self:_decodeBuf("cs.S2C_RecycleKnight", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    local recycleType = rawget(message, "type")

    if not (recycleType == 2 or recycleType == 3) then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_RESULT, nil, false, message)
    else
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_PREVIEW, nil, false, message)
    end
end

function RecycleHandler:_receiveRecycleEquipment(msgId, msg, len)
    -- handle recycle message
    local message = self:_decodeBuf("cs.S2C_RecycleEquipment", msg, len)
    if type(message) ~= "table" then 
        return 
    end

    local recycleType = rawget(message, "type")
    if recycleType == 1 then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_EQUIPMENT_PREVIEW, nil, false, message) 
    else
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_EQUIPMENT_RESULT, nil, false, message) 
    end
end

function RecycleHandler:_receiveRecycleTreasure(msgId, msg, len)
    -- handle recycle message
    local message = self:_decodeBuf("cs.S2C_RecycleTreasure", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    local recycleType = rawget(message, "type")
    if recycleType == 0 then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_TREASURE_RESULT, nil, false, message)
    else
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_TREASURE_PREVIEW, nil, false, message)
    end
end

function RecycleHandler:sendRecyclePet(petId, type_)

    local msg = 
    {
        pet_id = petId,
        type = type_, -- 0:分解 1:重生 2:分解预览 3:重生预览
    }

    local msgBuffer = protobuf.encode("cs.C2S_RecyclePet", msg) 

    self:sendMsg(NetMsg_ID.ID_C2S_RecyclePet, msgBuffer)
end

function RecycleHandler:_receiveRecyclePet(msgId, msg, len)

    local db = self:_decodeBuf("cs.S2C_RecyclePet", msg, len)

    if type(db) ~= "table" then 
        return 
    end

    if db.ret == NetMsg_ERROR.RET_OK then 

        local recycleType = db.type
        if not (recycleType == 2 or recycleType == 3) then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_PET_RESULT, nil, false, db)
        else
            if db == nil then assert(false) end
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_PET_PREVIEW, nil, false, db)
        end
    end
end

-- @param msgType 0: 重生 1:重生预览
function RecycleHandler:sendRebornEquipment( equipIds, msgType )
    local msg = 
    {
        equip_id = equipIds,
        type = msgType,
    }

    local msgBuffer = protobuf.encode("cs.C2S_RebornEquipment", msg)

    self:sendMsg(NetMsg_ID.ID_C2S_RebornEquipment, msgBuffer)
end

function RecycleHandler:_receiveRebornEquipment( msgId, msg, len )
    local message = self:_decodeBuf("cs.S2C_RebornEquipment", msg, len)
    if type(message) ~= "table" then
        return
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        if message.type == QUIPMENT_REBORN_PREREVIEW then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_REBORN_EQUIPMENT_PREVIEW, nil, false, message)
        elseif message.type == QUIPMENT_REBORN_RESULT then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECYCLE_REBORN_EQUIPMENT_RESULT, nil, false, message)
        else 
            assert("reborn s2c type error")
        end
    end
end

return RecycleHandler