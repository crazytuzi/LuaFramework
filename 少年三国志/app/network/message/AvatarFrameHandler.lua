-- user avatar frame handler


local AvatarFrameHandle = class("AvatarFrameHandle", require("app.network.message.HandlerBase"))
  
function AvatarFrameHandle:initHandler(...)
    
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetPictureFrame, self._recvSetPictureFrame, self)

end

--------------------------receive

function AvatarFrameHandle:_recvSetPictureFrame(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_SetPictureFrame", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        if not rawget(decodeBuffer,"fid") then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AVATAR_FRAME_ERROR"))
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_AVATAR_FRAME_OK"))
            G_Me.userData:setFrameId(decodeBuffer.fid)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AVATAR_FRAME_CHANGE, nil, false, decodeBuffer)
        end
    end
    
end


--------------------------send


function AvatarFrameHandle:sendSetPictureFrame(_fid)
    local msg = 
    {
        fid = _fid
    }

    if type(_fid) ~= "number" or _fid < 0 then 
        return 
    end
    
    local msgBuffer = protobuf.encode("cs.C2S_SetPictureFrame", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetPictureFrame, msgBuffer)
end


return AvatarFrameHandle
