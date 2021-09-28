local HandlerBase = require("app.network.message.HandlerBase")
local HandBookHandler = class("HandBookHandler", HandlerBase)

local HandBookConst = require("app.const.HandBookConst")

function HandBookHandler:_onCtor( ... )
    -- body
end

function HandBookHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetHandbookInfo, self._recvGetHandbookInfo, self)
end

function HandBookHandler:sendGetHandbookInfo(hand_type)
    local msg = {
        hand_type = hand_type
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetHandbookInfo", msg) 

    self:sendMsg(NetMsg_ID.ID_C2S_GetHandbookInfo, msgBuffer)
end

-- 技能上阵
function HandBookHandler:_recvGetHandbookInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetHandbookInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then

        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            if decodeBuffer.hand_type == HandBookConst.HandType.KNIGHT then
                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HANDBOOK_GETHANDBOOKINFO, nil, false,decodeBuffer.ids)
            elseif decodeBuffer.hand_type == HandBookConst.HandType.PET then
                G_Me.bagData.petData:setPetBookIds(decodeBuffer.ids)
            end
        end
    end
end

return HandBookHandler
