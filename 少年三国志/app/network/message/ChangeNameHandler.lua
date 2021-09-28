-- 改名功能协议handler

local ChangeNameHandler = class("ChangeNameHandler", require("app.network.message.HandlerBase"))


function ChangeNameHandler:initHandler(  )
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeName, self._recvChangeName, self)
	__Log("[ChangeNameHandler:initHandler]")
end


function ChangeNameHandler:sendChangeName( newName )
	local msg = {new_name = newName}

	local msgBuffer = protobuf.encode("cs.C2S_ChangeName", msg) 
	self:sendMsg(NetMsg_ID.ID_C2S_ChangeName, msgBuffer)
end


function ChangeNameHandler:_recvChangeName( msgId, msg, len )
	-- __Log("[ChangeNameHandler:_recvChangeName] start")
	local decodeBuffer = self:_decodeBuf("cs.S2C_ChangeName", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end


    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	if rawget(decodeBuffer, "new_name") then
    		-- __Log("[ChangeNameHandler:_recvChangeName] before1 dispatchEvent")
    		G_Me.userData:setName(decodeBuffer.new_name)
            -- 已有推送
            -- G_Me.userData:addChangeNameCnt()
    		G_Me.bagData.knightsData:changeNameSucceed()
    		-- __Log("[ChangeNameHandler:_recvChangeName] before dispatchEvent")
    		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CHANGE_ROLE_NAME_SUCCEED, nil, false, decodeBuffer)
    		-- __Log("[ChangeNameHandler:_recvChangeName] after dispatchEvent")
    	end
    end
end


return ChangeNameHandler

