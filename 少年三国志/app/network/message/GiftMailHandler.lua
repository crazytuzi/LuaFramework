local GiftMailHandler = class("GiftMailHandler ", require("app.network.message.HandlerBase"))

function GiftMailHandler:_onCtor( ... )

end

function GiftMailHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGiftMailCount, self._recvGetGiftMailCount, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGiftMail, self._recvGetGiftMail, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ProcessGiftMail, self._recvProcessGiftMail, self)
end

-------------recv messages

function GiftMailHandler:_recvGetGiftMailCount( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetGiftMailCount", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_GetGiftMailCount")
    G_Me.giftMailData:setNewMailCount(decodeBuffer.count)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GIFT_MAIL_NEW_COUNT, nil, false)

end


function GiftMailHandler:_recvGetGiftMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetGiftMail", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_GetGiftMail")
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.giftMailData:initFromGiftMailList(decodeBuffer.mail)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GIFT_MAIL_CONTENT_READY, nil, false)
  
    end

end


function GiftMailHandler:_recvProcessGiftMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ProcessGiftMail", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_ProcessGiftMail")
    local mail 
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        mail = G_Me.giftMailData:getMailById(decodeBuffer.id)
        G_Me.giftMailData:processMail(decodeBuffer.id)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GIFT_MAIL_PROCESS, nil, false, {ret=decodeBuffer.ret, mail=mail})
 
end


-------------send messages

function GiftMailHandler:sendGetGiftMail( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetGiftMail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGiftMail, msgBuffer)
end


function GiftMailHandler:sendProcessGiftMail(giftMailId)
    local msg = {
       id = giftMailId
    }
    local msgBuffer = protobuf.encode("cs.C2S_ProcessGiftMail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ProcessGiftMail, msgBuffer)
end


return GiftMailHandler
