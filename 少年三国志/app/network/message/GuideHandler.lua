--GuideHandler.lua


local HandlerBase = require("app.network.message.HandlerBase")
local GuideHandler = class("GuideHandler", HandlerBase)


function GuideHandler:_onCtor( ... )
	
end


function GuideHandler:initHandler(...)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGuideId, self._onReceiveGetGuideId, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SaveGuideId, self._onReceiveSaveGuideId, self)
end

function GuideHandler:_onReceiveGetGuideId( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetGuideId", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GUIDE_ID, nil, false, decodeBuffer.ret, decodeBuffer.id)
end

function GuideHandler:_onReceiveSaveGuideId( msgId, msg, len )
	
end

function GuideHandler:sendGetGuideId( ... )
	local msg = 
    {

    }

    local msgBuffer = protobuf.encode("cs.C2S_GetGuideId", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetGuideId, msgBuffer)
end

function GuideHandler:sendSaveGuideId( guideId )
	local msg = 
    {
        id = guideId,
    }

    -- temp codes for test guiding bug
    if G_Me.userData.level > 30 then
        return 
    end

    local msgBuffer = protobuf.encode("cs.C2S_SaveGuideId", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_SaveGuideId, msgBuffer)
end

return GuideHandler
