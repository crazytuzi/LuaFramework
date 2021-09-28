-- friend handler


local FriendHandler = class("FriendHandler", require("app.network.message.HandlerBase"))

function FriendHandler:_onCtor( ... )

end

function FriendHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFriendList, self._recvGetFriendList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFriendReqList, self._recvGetFriendReqList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RequestAddFriend, self._recvRequestAddFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RequestDeleteFriend, self._recvRequestDeleteFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ConfirmAddFriend, self._recvConfirmAddFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FriendPresent, self._recvFriendPresent, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFriendPresent, self._recvGetFriendPresent, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddFriendRespond, self._recvAddFriendNotify, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DelFriend, self._recvDeleteFriendNotify, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChooseFriend, self._recvChooseFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFriendsInfo, self._recvFriendsInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KillFriend, self._recvKillFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetPlayerInfo, self._recvPlayerInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Mail, self._recvMail, self)
end


function FriendHandler:_recvGetFriendList(msgId, msg, len)
    if len > 0 then
        local decodeBuffer = self:_decodeBuf("cs.S2C_GetFriendList", msg, len)
    --    dump(decodeBuffer)
        if decodeBuffer then
            if rawget(decodeBuffer, "friend") then
                G_Me.friendData:setFriendList(decodeBuffer.friend)
                G_Me.dailyPvpData:updateFriends(decodeBuffer.friend)
            end
            if rawget(decodeBuffer, "black_list") then
                G_Me.friendData:setBlackList(decodeBuffer.black_list)
            end
        
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_LIST, nil, false, decodeBuffer)
        end
    else
        --更新好友数据模型 
        G_Me.friendData:setFriendList({})
        G_Me.friendData:setBlackList({})
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_LIST, nil, false, nil)
    end
end

function FriendHandler:_recvGetFriendReqList( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFriendReqList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if rawget(decodeBuffer, "friend") ~= nil then
            G_Me.friendData:setAddList(decodeBuffer.friend)
        else
            G_Me.friendData:setAddList({})
        end
        G_Me.friendData:setNewFriend(false)
        
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_REQUEST_LIST, nil, false, decodeBuffer)
    end
    

end

function FriendHandler:_recvRequestAddFriend( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RequestAddFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.friend_type == 2 then
            G_Me.friendData:addBlack(decodeBuffer.friend)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_ADD, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvAddFriendNotify( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AddFriendRespond", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
--    dump(decodeBuffer)
    if decodeBuffer then
        G_Me.friendData:addFriend(decodeBuffer.friend)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_ADD_NOTIFY, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvDeleteFriendNotify( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_DelFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.friendData:deleteFriend(decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_ADD_NOTIFY, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvRequestDeleteFriend( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RequestDeleteFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            if decodeBuffer.friend_type == 1 then
                G_Me.friendData:deleteFriend(decodeBuffer.id)
            else
                G_Me.friendData:deleteBlack(decodeBuffer.id)
            end
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_DELETE, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvConfirmAddFriend( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ConfirmAddFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == 1 then
        if decodeBuffer.accept then
            G_Me.friendData:addFriend(decodeBuffer.friend)
        end
        G_Me.friendData:deleteAdd(decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_CONFIRM, nil, false, decodeBuffer)
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_FRIEND_FULL_2 then
        G_Me.friendData:deleteAdd(decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_CONFIRM, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvFriendPresent( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FriendPresent", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if rawget(decodeBuffer, "present") ~= nil then
            G_Me.friendData:updatePresent(decodeBuffer.id, decodeBuffer.present,decodeBuffer.getpresent)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_GIVE, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvGetFriendPresent( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFriendPresent", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            -- G_Me.friendData:updatePresent(decodeBuffer.id, decodeBuffer.present,decodeBuffer.getpresent)
            if rawget(decodeBuffer, "get_present_times") ~= nil then
                G_Me.friendData:setPresentLeftDir(decodeBuffer.get_present_times)
            end
            -- if rawget(decodeBuffer, "present") ~= nil then
            --     G_Me.friendData:updatePresent(decodeBuffer.id[1], decodeBuffer.present,decodeBuffer.getpresent)
            -- end
            for k,v in pairs(decodeBuffer.id) do
                G_Me.friendData:updatePresentRev(v)
            end
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_PRESENT_RECEIVE, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvChooseFriend( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChooseFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.friendData:setFriendSugList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_CHOOSE_LIST, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvFriendsInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetFriendsInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.friendData:setPresentLeft(decodeBuffer.getPresentCount)
        G_Me.friendData:setNewFriend(decodeBuffer.newFriend)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_INFO, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvKillFriend( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_KillFriend", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_KILL, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvPlayerInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetPlayerInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_PLAYINFO, nil, false, decodeBuffer)
    end
end

function FriendHandler:_recvMail( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Mail", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_MAIL, nil, false, decodeBuffer)
    end
end


--send
--friend
function FriendHandler:sendFriendList()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFriendList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFriendList, msgBuffer)
end

function FriendHandler:sendFriendAddInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFriendReqList", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFriendReqList, msgBuffer)
end

function FriendHandler:sendConfirmFriend(uid, isaccept)
    local msg = 
    {
        id = uid,
        accept = isaccept
    }
    local msgBuffer = protobuf.encode("cs.C2S_ConfirmAddFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ConfirmAddFriend, msgBuffer)
end

function FriendHandler:sendAddFriend(username)
    local msg = 
    {
        name = username,
        friend_type = 1,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RequestAddFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RequestAddFriend, msgBuffer)
end

function FriendHandler:sendDeleteFriend(uid)
    
    local msg = 
    {
        id = uid,
        friend_type = 1,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RequestDeleteFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RequestDeleteFriend, msgBuffer)
end

function FriendHandler:sendAddBlack(username)

    local msg = 
    {
        name = username,
        friend_type = 2,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RequestAddFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RequestAddFriend, msgBuffer)
end

function FriendHandler:sendDeleteBlack(uid)
    
    local msg = 
    {
        id = uid,
        friend_type = 2,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RequestDeleteFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RequestDeleteFriend, msgBuffer)
end

function FriendHandler:sendGivePresent(uid)
    local msg = 
    {
        id = uid
    }
    local msgBuffer = protobuf.encode("cs.C2S_FriendPresent", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FriendPresent, msgBuffer)
end

function FriendHandler:sendReceivePresent(uid)
    local msg = 
    {
        id = uid
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFriendPresent", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFriendPresent, msgBuffer)
end

function FriendHandler:sendChooseFriendList()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChooseFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChooseFriend, msgBuffer)
end

function FriendHandler:sendFriendsInfo()
    local msg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetFriendsInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetFriendsInfo, msgBuffer)
end

function FriendHandler:sendKillFriend(uid)
    local msg = 
    {
        targetId = uid,
    }
    local msgBuffer = protobuf.encode("cs.C2S_KillFriend", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_KillFriend, msgBuffer)
end

function FriendHandler:sendGetPlayerInfo(uid,uname)
    local msg = 
    {
        id = uid,
        name = uname,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetPlayerInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetPlayerInfo, msgBuffer)
end

function FriendHandler:sendMail(ucontent,uuid)
    local msg = 
    {
        content = ucontent,
        uid = uuid,
    }
    local msgBuffer = protobuf.encode("cs.C2S_Mail", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Mail, msgBuffer)
end

return FriendHandler
