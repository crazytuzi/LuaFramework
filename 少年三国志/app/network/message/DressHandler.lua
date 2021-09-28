-- dress handler


local DressHandler = class("DressHandler", require("app.network.message.HandlerBase"))
  
function DressHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpgradeDress, self._recvUpgrateDress, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddFightDress, self._recvAddFightDress, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDress, self._recvGetDress, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ClearFightDress, self._recvClearFightDress, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecycleDress, self._recvRecycleDress, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetClothSwitch, self._recvClothSwitch, self)
end

function DressHandler:_recvUpgrateDress(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpgradeDress", msg)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DRESS_UPDATE, nil, false,decodeBuffer)
end

function DressHandler:_recvRecycleDress(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecycleDress", msg)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DRESS_RECYCLE, nil, false,decodeBuffer)
end

function DressHandler:_recvAddFightDress(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AddFightDress", msg)
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then 
        G_Me.dressData:updateDress(decodeBuffer.id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ADD_DRESS, nil, false,decodeBuffer)
end

function DressHandler:_recvClearFightDress(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ClearFightDress", msg)

    if decodeBuffer.ret == 1 then 
        G_Me.dressData:updateDress(0)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CLEAR_DRESS, nil, false,decodeBuffer)
end

function DressHandler:_recvGetDress(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDress", msg)
    -- dump(decodeBuffer)
    G_Me.dressData:setDress(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DRESS, nil, false,decodeBuffer)
end


function DressHandler:_recvClothSwitch(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_SetClothSwitch", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.userData:setClothOpen(decodeBuffer.isOpen)
end

-- send
function DressHandler:sendClothSwitch(_isOpen)
    local msg = 
    {
        isOpen = _isOpen,
    }
    local msgBuffer = protobuf.encode("cs.C2S_SetClothSwitch", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetClothSwitch, msgBuffer)
end

function DressHandler:sendUpgradeDress(dressId)
    local msg = 
    {
        id = dressId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_UpgradeDress", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_UpgradeDress, msgBuffer)
end

function DressHandler:sendRecycleDress(dressId,_type)
    local msg = 
    {
        id = dressId,
        type = _type,
    }
    -- dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_RecycleDress", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecycleDress, msgBuffer)
end

function DressHandler:sendAddFightDress(dressId)
    local msg = 
    {
        id = dressId
    }
    local msgBuffer = protobuf.encode("cs.C2S_AddFightDress", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_AddFightDress, msgBuffer)
end

function DressHandler:sendClearFightDress()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ClearFightDress", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ClearFightDress, msgBuffer)
end

return DressHandler
