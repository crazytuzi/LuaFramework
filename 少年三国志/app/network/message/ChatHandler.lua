--ChatHandler.lua

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local HandlerBase = require("app.network.message.HandlerBase")
local ChatHandler = class("ChatHandler", HandlerBase)

function ChatHandler:_onCtor( ... )
    self._worldMsg = {}
    self._unionMsg = {}
    self._someoneMsg = {}
    self._teamMsg = {}
    self._lastChatTime = os.time() - 20

    self._worldMsgDirty = false
    self._unionMsgDirty = false
    self._someoneMsgDirty = false
    self._teamMsgDirty = false
end

function ChatHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChatRequest, self._onReceiveChatRequestRet, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Chat, self._onReceiveChatMessage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Notify, self._onReceiveNotify, self)
end

function ChatHandler:unInitHandler( ... )
    self._worldMsg = {}
    self._unionMsg = {}
    self._someoneMsg = {}
    self._teamMsg = {}

    self._worldMsgDirty = false
    self._unionMsgDirty = false
    self._someoneMsgDirty = false
    self._teamMsgDirty = false
end

function ChatHandler:sendChatRequest( msg_type, msg_content, msg_reciver, kid )
    local chatMsg = 
    {
        channel = msg_type,
        content = msg_content,
        reciver = msg_reciver,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChatRequest", chatMsg)
    self:sendMsg(NetMsg_ID.ID_C2S_ChatRequest, msgBuffer)

    if msg_type == 2 then 
        chatMsg.receive_kid = kid
    end
    self:_onSendMsg(chatMsg)
end

function ChatHandler:_onReceiveChatRequestRet( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChatRequest", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    self._lastChatTime = os.time()
    if decodeBuffer then 
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_CHAT_REQUEST_RET, nil, false,decodeBuffer.ret)
    end

    if decodeBuffer and decodeBuffer.ret ~= NetMsg_ERROR.RET_OK then 
        self:delSomeMsyByIndex(1)
    end    
end

function ChatHandler:_onReceiveChatMessage( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_Chat", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then 
        if self:_onReceiveMsg(decodeBuffer) then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_CHAT_MSG, nil, false, 
                decodeBuffer.channel, decodeBuffer.sender, decodeBuffer.senderId, decodeBuffer.kid, 
                decodeBuffer.content, decodeBuffer.vip, decodeBuffer.dress_id, decodeBuffer.title_id,
                rawget(decodeBuffer,"fid") and decodeBuffer.fid or 0,  decodeBuffer.clid , decodeBuffer.cltm ,decodeBuffer.clop)
        end
    end
end

function ChatHandler:_onReceiveNotify( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_Notify", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then 
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_NOTIFY, nil, false,decodeBuffer)
    end
end

function ChatHandler:_onReceiveMsg( buffer )
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHAT) then 
        return 
    end
    
    if not buffer or buffer.channel < 1 or buffer.channel > 4 then 
        return false
    end

    if G_Me.friendData:isBlack(buffer.sender) then 
        __Log("user is in black list!")
        return false
    end

    if buffer.channel == 1 then 
        table.insert(self._worldMsg, 1, 
            {msg_sender = buffer.sender, msg_senderId = buffer.senderId, msg_kid = buffer.kid,
             msg_content = buffer.content, msg_vip=buffer.vip, dress_id = buffer.dress_id, title_id = buffer.title_id,
             frameId = rawget(buffer,"fid") and buffer.fid or 0, clid = buffer.clid , cltm = buffer.cltm ,clop = buffer.clop})
        self:_removeMoreMsg(self._worldMsg)
        self:setMsgFlag(1, true)
    elseif buffer.channel == 2 then 
        table.insert(self._someoneMsg, 1, 
            {msg_sender = buffer.sender, msg_senderId = buffer.senderId, msg_kid = buffer.kid, 
            msg_content = buffer.content, msg_vip=buffer.vip, dress_id = buffer.dress_id, title_id = buffer.title_id,
            frameId = rawget(buffer,"fid") and buffer.fid or 0, clid = buffer.clid , cltm = buffer.cltm,clop = buffer.clop})
        self:_removeMoreMsg(self._someoneMsg)
        self:setMsgFlag(2, true)
    elseif buffer.channel == 3 then 
        table.insert(self._unionMsg, 1, 
            {msg_sender = buffer.sender, msg_senderId = buffer.senderId, msg_kid = buffer.kid, 
            msg_content = buffer.content, msg_vip=buffer.vip, dress_id = buffer.dress_id, title_id = buffer.title_id,
            frameId = rawget(buffer,"fid") and buffer.fid or 0, clid = buffer.clid , cltm = buffer.cltm,clop = buffer.clop})
        self:_removeMoreMsg(self._unionMsg)
        self:setMsgFlag(3, true)
    elseif buffer.channel == 4 then 
        table.insert(self._teamMsg, 1, 
            {msg_sender = buffer.sender, msg_senderId = buffer.senderId, msg_kid = buffer.kid, 
            msg_content = buffer.content, msg_vip=buffer.vip, dress_id = buffer.dress_id, title_id = buffer.title_id,
            frameId = rawget(buffer,"fid") and buffer.fid or 0, clid = buffer.clid , cltm = buffer.cltm,clop = buffer.clop})
        self:_removeMoreMsg(self._teamMsg)
        self:setMsgFlag(4, true)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMCHATMSG, nil, false,buffer)
    end

    return true
end

function ChatHandler:_onSendMsg( buffer )
    if not buffer then 
        return 
    end

    if buffer.channel == 2 then 
        local knightInfo = G_Me.bagData.knightsData:getMainKightInfo()
        table.insert(self._someoneMsg, 1, 
            {msg_sender = G_Me.userData.name, 
            msg_senderId = G_Me.userData.id, 
            msg_vip = G_Me.userData.vip,
            msg_kid = knightInfo and knightInfo["base_id"] or 0, 
            msg_content = buffer.content, 
            msg_receive = buffer.reciver,
            msg_receive_kid = buffer.receive_kid,
            title_id = G_Me.userData:getTitleId()})
        self:_removeMoreMsg(self._someoneMsg)
    -- elseif buffer.channel == 3 then 
    --     local knightInfo = G_Me.bagData.knightsData:getMainKightInfo()
    --     table.insert(self._unionMsg, 1, 
    --         {msg_sender = G_Me.userData.name, 
    --         msg_senderId = G_Me.userData.id, 
    --         msg_kid = knightInfo and knightInfo["base_id"] or 0, 
    --         msg_content = buffer.content, 
    --         msg_receive = buffer.reciver,
    --         msg_receive_kid = buffer.receive_kid})
    --     self:_removeMoreMsg(self._unionMsg)
    end
end

function ChatHandler:_removeMoreMsg( msgList )
    if type(msgList) ~= "table" then 
        return 
    end

    while #msgList > 30 do 
        table.remove(msgList, #msgList)
    end
end

function ChatHandler:getWorldMsgList( ... )
    self:setMsgFlag(1, false)
    return self._worldMsg
end

function ChatHandler:getTeamMsgList( ... )
    self:setMsgFlag(4, false)
    return self._teamMsg
end

function ChatHandler:getUnionMsgList( ... )
    self:setMsgFlag(3, false)
    return self._unionMsg
end

function ChatHandler:delUnionMsyByIndex( index )
    if not index or not self._unionMsg or #self._unionMsg < 1 then 
        return nil 
    end

    if #self._unionMsg < index or index < 1 then 
        return 
    end

    self._unionMsg[index] = nil
end

function ChatHandler:getUnionMsgByIndex( index )
    if not index or not self._unionMsg or #self._unionMsg < 1 then 
        return nil 
    end

    self:setMsgFlag(3, false)
    return self._unionMsg[index]
end


function ChatHandler:getSomeoneMsgList( ... )
    self:setMsgFlag(2, false)
    return self._someoneMsg
end

function ChatHandler:delSomeMsyByIndex( index )
    if not index or not self._someoneMsg or #self._someoneMsg < 1 then 
        return nil 
    end

    if #self._someoneMsg < index or index < 1 then 
        return 
    end

    self._someoneMsg[index] = nil
end

function ChatHandler:getSomeoneMsgByIndex( index )
    if not index or not self._someoneMsg or #self._someoneMsg < 1 then 
        return nil 
    end

    self:setMsgFlag(2, false)
    return self._someoneMsg[index]
end

function ChatHandler:getMsgFlag( channel )
    channel = channel or 1
    if channel == 1 then 
        return self._worldMsgDirty
    elseif channel == 2 then 
        return self._someoneMsgDirty
    elseif  channel == 3 then 
        return self._unionMsgDirty
    elseif  channel == 4 then 
        return self._teamMsgDirty
    end

    return false
end

function ChatHandler:hasMsgDirty( ... )
    return self._worldMsgDirty or self._someoneMsgDirty or self._unionMsgDirty or self._teamMsgDirty
end

function ChatHandler:setMsgFlag( channel, dirty )
    channel = channel or 0
    dirty = dirty or false

    if channel < 1 or channel > 4 then 
        return 
    end

    local oldFlag = self._worldMsgDirty or self._someoneMsgDirty or self._unionMsgDirty or self._teamMsgDirty
    if channel == 1 then 
        self._worldMsgDirty = dirty
    elseif channel == 2 then 
        self._someoneMsgDirty = dirty
    elseif channel == 3 then 
        self._unionMsgDirty = dirty
    elseif channel == 4 then 
        self._teamMsgDirty = dirty
    end

    local newFlag = self._worldMsgDirty or self._someoneMsgDirty or self._unionMsgDirty or self._teamMsgDirty
    if (oldFlag and (not newFlag)) or ((not oldFlag) and newFlag) then
        __Log("flag changed:world:%d, someone:%d, union:%d", 
            self._worldMsgDirty and 1 or 0, self._someoneMsgDirty and 1 or 0, self._unionMsgDirty and 1 or 0 )
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MSG_DIRTY_FLAG_CHANGED, nil, false, newFlag)
    end
end

function ChatHandler:getNewMsgChannel(  )
    local arr = {}
    if self._worldMsgDirty then 
        table.insert(arr, #arr + 1, 1)
    elseif self._unionMsgDirty then 
        table.insert(arr, #arr + 1, 3)
    elseif self._someoneMsgDirty then 
        table.insert(arr, #arr + 1, 2)
    elseif self._teamMsgDirty then 
        table.insert(arr, #arr + 1, 4)
    end

    return arr
end

function ChatHandler:getLastChatTime( ... )
    return self._lastChatTime
end

return ChatHandler

