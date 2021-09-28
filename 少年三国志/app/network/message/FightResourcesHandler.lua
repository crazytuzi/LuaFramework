--FightResourcesHandler.lua



local HandlerBase = require("app.network.message.HandlerBase")
local FightResourcesHandler = class("FightResourcesHandler", HandlerBase)

function FightResourcesHandler:_onCtor( ... )
    self._hasEffectEquip = false
end

function FightResourcesHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FightResource, self._onReceiveFightResource, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddFightEquipment, self._onReceiveAddFightEquipment, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ClearFightEquipment, self._onReceiveClearFightEquipment, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddFightTreasure, self._onReceiveAddFightTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ClearFightTreasure, self._onReceiveClearFightTreasure, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetPetProtect, self._onReceiveGetPetProtect, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetPetProtect, self._onReceiveSetPetProtect, self)
end

function FightResourcesHandler:unInitHandler( ... )
    self._hasEffectEquip = false
end

function FightResourcesHandler:_onReceiveFightResource( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_FightResource", msg)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.formationData:resetEquipmentFormation(decodeBuffer.fight_equipments)
    G_Me.formationData:resetTreasureFormation(decodeBuffer.fight_treasures)

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_FIGHT_RESOUCES, nil, false )

    self:checkEffectEquip(1, "_onReceiveFightResource")
end

function FightResourcesHandler:sendAddFightEquipment( teamId, posId, slotId, equipId )
 	local msg = 
    {
        team = teamId,
        pos = posId,
        slot = slotId,
        id = equipId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_AddFightEquipment", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_AddFightEquipment, msgBuffer)
end

function FightResourcesHandler:_onReceiveAddFightEquipment( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_AddFightEquipment", msg, len)
    --self:_disposeErrorMsg(decodeBuffer.ret)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.formationData:addFightEquipment(decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_ADD_FIGHT_EQUIPMENT, nil, false, decodeBuffer.ret,
    	decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.id, decodeBuffer.old_id )

    self:checkEffectEquip(decodeBuffer.slot, "_onReceiveAddFightEquipment")
end

function FightResourcesHandler:sendClearFightEquipment( teamId, posId, slotId )
 	local msg = 
    {
        team = teamId,
        pos = posId,
        slot = slotId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_ClearFightEquipment", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_ClearFightEquipment, msgBuffer)
end

function FightResourcesHandler:_onReceiveClearFightEquipment( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ClearFightEquipment", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.formationData:clearFightEquipment(decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_CLEAR_FIGHT_EQUIPMENT, nil, false, decodeBuffer.ret,
    	decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.old_id )

    self:checkEffectEquip(decodeBuffer.slot, "_onReceiveClearFightEquipment")
end

function FightResourcesHandler:sendAddFightTreasure( teamId, posId, slotId, treasureId )
 	local msg = 
    {
        team = teamId,
        pos = posId,
        slot = slotId,
        id = treasureId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_AddFightTreasure", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_AddFightTreasure, msgBuffer)
end

function FightResourcesHandler:_onReceiveAddFightTreasure( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_AddFightTreasure", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.formationData:addFightTreasure(decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_ADD_FIGHT_TREASURE, nil, false, decodeBuffer.ret,
    	decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.id, decodeBuffer.old_id )
    
    self:checkEffectEquip(decodeBuffer.slot, "_onReceiveAddFightTreasure")
end

function FightResourcesHandler:sendClearFightTreasure( teamId, posId, slotId )
 	local msg = 
    {
        team = teamId,
        pos = posId,
        slot = slotId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_ClearFightTreasure", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_ClearFightTreasure, msgBuffer)
end

function FightResourcesHandler:_onReceiveClearFightTreasure( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ClearFightTreasure", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.formationData:clearFightTreasure(decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_CLEAR_FIGHT_TREASURE, nil, false, decodeBuffer.ret,
    	decodeBuffer.team, decodeBuffer.pos, decodeBuffer.slot, decodeBuffer.old_id )

    self:checkEffectEquip(decodeBuffer.slot, "_onReceiveClearFightTreasure")
end

function FightResourcesHandler:checkEffectEquip( slotId, logPath )
    slotId = slotId or 1
    local flag = G_Me.formationData:checkEffectiveEquip(slotId)
    if flag ~= self._hasEffectEquip then 
        self._hasEffectEquip = flag
        __Log("[checkEffectEquip] log:%s, flag=%d", logPath or "null", self._hasEffectEquip and 1 or 0)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EQUIP_DIRTY_FLAG_CHANGED, nil, false, self._hasEffectEquip)
    end
end

function FightResourcesHandler:getEffectEquipFlag( ... )

    -- 战宠护佑要重新检查一下
    self:checkEffectEquip(7, "getEffectEquipFlag")

    return self._hasEffectEquip
end

-- 获取护佑的战宠们
function FightResourcesHandler:sendGetPetProtect()

    local msg = {}

    local msgBuffer = protobuf.encode("cs.C2S_GetPetProtect", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetPetProtect, msgBuffer)
end

function FightResourcesHandler:_onReceiveGetPetProtect(msgId, msg, len)

    local decodeBuffer = self:_decodeBuf("cs.S2C_GetPetProtect", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    

    if rawget(decodeBuffer, "pet_id") then
        G_Me.formationData:resetProtectPetFormation(decodeBuffer.pet_id)
        self:checkEffectEquip(7, "_onReceiveGetPetProtect")
    end

end

function FightResourcesHandler:sendSetPetProtect(pos, pet_id)

    local msg = {
        pos = pos,
        pet_id = pet_id,
    }

    local msgBuffer = protobuf.encode("cs.C2S_SetPetProtect", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_SetPetProtect, msgBuffer)
end

function FightResourcesHandler:_onReceiveSetPetProtect(msgId, msg, len)

    local decodeBuffer = self:_decodeBuf("cs.S2C_SetPetProtect", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        G_Me.formationData:addProtectPet(1, decodeBuffer.pos, decodeBuffer.pet_id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SET_PET_PRITECT, nil, false, decodeBuffer)

        self:checkEffectEquip(7, "_onReceiveSetPetProtect")
    end
end

return FightResourcesHandler