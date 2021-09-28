local MailHandler = class("MailHandler ", require("app.network.message.HandlerBase"))

function MailHandler:_onCtor( ... )

end

function MailHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetSimpleMail, self._recvGetSimpleMail, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddSimpleMail, self._recvAddSimpleMail, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewMailCount, self._recvGetNewMailCount, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetMail, self._recvGetMail, self)
end

-------------recv messages

function MailHandler:_recvGetSimpleMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetSimpleMail", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_GetSimpleMail")
    
    G_Me.mailData:initFromSimpleMailList((decodeBuffer and decodeBuffer.mail) or {})

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAIL_LIST_UPDATE, nil, false)

end


function MailHandler:_recvAddSimpleMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AddSimpleMail", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_AddSimpleMail")
    G_Me.mailData:addSimpleMails((decodeBuffer and decodeBuffer.mail) or {})
    
end


function MailHandler:_recvGetNewMailCount( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewMailCount", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_GetNewMailCount" .. "," .. decodeBuffer.count)
    -- dump(decodeBuffer)
    G_Me.mailData:setNewMailCount(decodeBuffer.count)
    if rawget(decodeBuffer,"recharge") then
        G_Me.mailData:setNewRechargeMailCount(decodeBuffer.recharge)
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAIL_NEW_COUNT, nil, false)

    
end


function MailHandler:_recvGetMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetMail", msg, len)
    
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_GetMail")
  
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.mailData:updateMails(decodeBuffer.mail)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAIL_CONTENT_READY, nil, false)
  
    else
        __LogTag("ldx", "RET = " .. decodeBuffer.ret)
    end
    
end


-------------send messages

function MailHandler:sendGetMail( idList )
    local msg = {
       id = idList
    }
    __LogTag("ldx", "cs.C2S_GetMail")
    local msgBuffer = protobuf.encode("cs.C2S_GetMail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetMail, msgBuffer)
end

function MailHandler:sendTestMail( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_TestMail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TestMail, msgBuffer)
end



return MailHandler
