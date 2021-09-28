-- TitleHandler

local HandlerBase = require ("app.network.message.HandlerBase")
local TitleHandler = class("TitleHandler", HandlerBase)

function TitleHandler:ctor( ... )
	-- body
end

function TitleHandler:initHandler( ... )
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeTitle, self._revChangeTitleResult, self)
end

function TitleHandler:sendChangeTitle( titleId )
	__Log("sendChangeTitle id = %d", titleId)
	local TitleInfo = {
		id = titleId
	}
	local msgBuffer = protobuf.encode("cs.C2S_ChangeTitle", TitleInfo)
	self:sendMsg(NetMsg_ID.ID_C2S_ChangeTitle, msgBuffer)
end

function TitleHandler:_revChangeTitleResult( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ChangeTitle", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	__Log("decodeBuffer")
	if decodeBuffer then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CHANGE_TITLE, nil, false, decodeBuffer)
	end
end

-- 称号过期时需要从服务器拉取新的战力
-- 返回是走玩家信息协议
function TitleHandler:sendUpdateFightValue(  )
	local Msg = {}
	local msgBuffer = protobuf.encode("cs.C2S_UpdateFightValue", Msg)
	-- __Log("TitleHandler:sendUpdateFightValue----------------")
	self:sendMsg(NetMsg_ID.ID_C2S_UpdateFightValue, msgBuffer)
end

return TitleHandler

