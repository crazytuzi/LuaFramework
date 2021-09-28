local HandlerBase = require("app.network.message.HandlerBase")
local NoticeHandler = class("NoticeHandler",HandlerBase)

function NoticeHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Notify , self._recvNotice, self)
end

function NoticeHandler:_recvNotice(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Notify", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Notice:addNotice(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NOTICE, nil, false,nil)
    end
end

return NoticeHandler

