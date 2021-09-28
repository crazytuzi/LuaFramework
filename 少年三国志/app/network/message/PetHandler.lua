-- pet handler


local PetHandler = class("PetHandler", require("app.network.message.HandlerBase"))
  
function PetHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetPet, self._recvGetPet, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeFightPet, self._recvChangeFightPet, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PetUpLvl, self._recvPetUpLvl, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PetUpStar, self._recvPetUpStar, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PetUpAddition, self._recvPetUpAddition, self)
    
end

function PetHandler:_recvGetPet(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetPet", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __Log("-- 上线获取宠物列表")
    -- dump(decodeBuffer)
    G_Me.bagData.petData:storeFightPetId(decodeBuffer.fight_pet)
    G_Me.bagData.petData:storePetList(decodeBuffer.pets)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PET_GET, nil, false, decodeBuffer)
end

function PetHandler:_recvPetUpLvl(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PetUpLvl", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PET_UPLVL, nil, false,decodeBuffer)
end

function PetHandler:_recvPetUpStar(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PetUpStar", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == 1 then 
        
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PET_UPSTAR, nil, false,decodeBuffer)
end

function PetHandler:_recvPetUpAddition(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PetUpAddition", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PET_UPADDITION, nil, false,decodeBuffer)
end

function PetHandler:_recvChangeFightPet(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChangeFightPet", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.bagData.petData:storeFightPetId(decodeBuffer.pet_id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_PET_CHANGE, nil, false,decodeBuffer)
end



-- send
function PetHandler:sendPetUpLvl(id, items)
    local itemData = {}
    for k , v in pairs(items) do 
        table.insert(itemData,#itemData+1,{id=v,num=1})
    end
    local msg = 
    {
        pet_id = id,
        consume_items = itemData,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_PetUpLvl", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PetUpLvl, msgBuffer)
end

function PetHandler:sendPetUpStar(id)
    local msg = 
    {
        pet_id = id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_PetUpStar", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PetUpStar, msgBuffer)
end

function PetHandler:sendPetUpAddition(id,itemId,count)
    local msg = 
    {
        pet_id = id,
        consume_item = {{id=itemId,num=count}},
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_PetUpAddition", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PetUpAddition, msgBuffer)
end

function PetHandler:sendPetFastUpAddition(id,items)
    local msg = 
    {
        pet_id = id,
        consume_item = items,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_PetUpAddition", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PetUpAddition, msgBuffer)
end

function PetHandler:sendChangeFightPet(id)
    local msg = 
    {
        pet_id = id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChangeFightPet", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChangeFightPet, msgBuffer)
end

return PetHandler
