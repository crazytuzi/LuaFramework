--基础消息处理


local CoreHandler = class("CoreHandler", require("app.network.message.HandlerBase"))
local ComSdkUtils = require("upgrade.ComSdkUtils")

--登录时把flush拆成多条协议来发， 一条协议包含n个字段
CoreHandler.nKeyPerFlush = 2


-- 刷新数据
--全部
local flushAllKeys = 
{
    "user",
    "knight",
    "item",
    "fragment" ,
    "equipment" ,
    "mail" ,
    "gift_mail",
    "treasure_fragment" ,
    "treasure",
    "fight_resource" ,
    "fight_knight",
    "vip" ,
    "recharge" ,
    "chapter",
    "main_grouth" ,
    "hof_points",
    "dress",
    "awaken_item",
    "pet",
}

--短时间内断线重连
local flushMainKeys =  {
    "user",
    "fragment" ,
    "equipment" ,
    "mail" ,
    "gift_mail" ,
    "treasure_fragment",
    "treasure",
    "chapter",
    "awaken_item",
}



function CoreHandler:_onCtor( ... )
    self.cacheRoleName = ""
    self.cacheLoginData = require("app.data.CacheLoginData").new()
end

function CoreHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KeepAlive, self._recvActiveMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Login, self._recvLoginMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Create, self._recvCreateRoleMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Flush, self._recvFlushMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetUser, self._recvRoleInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetServerTime, self._recvGetServerTime, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GiftCode, self._recvGetGiftCode, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RollNotice, self._recvGetRollNotice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_HOF_Points, self._recvHofPoints, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBlackcardWarning, self._onReceiveBlackcardWarning, self) 
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PushSingleInfo, self._recvPushSingleInfo, self) 

end



-- 发送创建角色信息
function CoreHandler:sendCreateRole(roleName, heroType)
    local CreateRoleMsg = 
    {
        name = roleName,
        type = heroType
    }
    --fuck , 其实创角成功的返回协议里应该带role name的。。协议没设计好
    self.cacheRoleName = roleName
    local msgBuffer = protobuf.encode("cs.C2S_Create", CreateRoleMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Create, msgBuffer)
end




function CoreHandler:_sendFlush(flushKeys)
    
    local msgBuffer = protobuf.encode("cs.C2S_Flush", flushKeys) 
    self:sendMsg(NetMsg_ID.ID_C2S_Flush, msgBuffer)
end



function CoreHandler:sendFlush()


    local flushSourceKeys = flushAllKeys
    if  G_Me and G_ServerTime then
        local now = G_ServerTime:getTime()

        if now - G_Me.lastOutofNetworkTime < 180 then
            --3分钟内重连不再拉取大量的flush data,
            flushSourceKeys = flushMainKeys
        end
    end
    local flushKeys = {}
    local n = 0
    local segmentKeys = {}
    local nKeyPerFlush = toint(G_Setting:get("flush_segment_n"))
    if nKeyPerFlush == 0 then
        nKeyPerFlush = CoreHandler.nKeyPerFlush
    end

    --if we use cache login data, then we don't need to use flush proto for fetching data
    if G_Setting:get("open_cache_login") == "1" then

        if self.cacheLoginData:hasBaseData() then
            local newFlushSourceKeys = {}
            for i, k in ipairs(flushSourceKeys) do 
                if k == "user" then
                    self:_setRoleData(self.cacheLoginData:getBaseData())
                else
                   table.insert(newFlushSourceKeys, k) 
                end
            end
            flushSourceKeys = newFlushSourceKeys
        end
    end
    
    for i=1,#flushSourceKeys do 

        table.insert(segmentKeys, flushSourceKeys[i])
        if #segmentKeys >= nKeyPerFlush then
            table.insert(flushKeys, segmentKeys)
            segmentKeys = {}
        end
    end
    if  #segmentKeys > 0 then
        table.insert(flushKeys, segmentKeys)
    end

    self._loginFlushKeys = flushKeys
    self:_sendFlushSegment()

end

function CoreHandler:_sendFlushSegment()
    local segment = table.remove(self._loginFlushKeys, 1)
    if segment then
        GlobalFunc.trace("send segment" .. tostring(table.concat(segment,",")))

        local  flushMsg = {}
        for i,k in ipairs(flushAllKeys) do
            flushMsg[k] = false
        end
        for i,k in ipairs(segment) do
            flushMsg[k] = true
        end
        self:_sendFlush(flushMsg)
    else
        --finish
        if G_Me and G_ServerTime then
            local now = G_ServerTime:getTime()
            G_Me.lastFlushDataTime = now
        end
        self._loginFlushKeys = nil
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECV_FLUSH_DATA, nil, false) 
    end
    
end

function CoreHandler:sendFlushUser()
    if self._loginFlushKeys then
        --flushing, ignore
        return
    end
    
    local flushMsg = {}
    for i,k in ipairs(flushAllKeys) do
        flushMsg[k] = false
    end

    flushMsg['hof_points'] = true
    flushMsg['user'] = true

    self:_sendFlush(flushMsg)
end



function CoreHandler:sendLoginGame(token, sid, channel_id, device_id)
    local LoginMsg = 
    {
        token = token,
        sid =  sid,
        channel_id= channel_id,
        device_id = device_id,
        version=getRealVersionNo()
   }

   local logData = {{event_id="C2SLogin_TRY"}, {sid=tostring(sid)}, {uid=tostring(G_PlatformProxy:getPlatformUid())}}

   
   -- GlobalFunc.uploadLog(logData)

    local msgBuffer = protobuf.encode("cs.C2S_Login", LoginMsg)
    self:sendMsg(NetMsg_ID.ID_C2S_Login, msgBuffer)
end




--发送心跳消息
function CoreHandler:sendKeepAlive()
    __LogTag("ldx", "heart beat")
    local ActiveMsg = { }
    local msgBuffer = protobuf.encode("cs.C2S_KeepAlive", ActiveMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_KeepAlive, msgBuffer)
end


--获取服务器时间
function CoreHandler:sendGetServerTime()
    
    local msgBuffer = protobuf.encode("cs.C2S_GetServerTime", {})
    self:sendMsg(NetMsg_ID.ID_C2S_GetServerTime, msgBuffer)
    
end

-- test battle
function CoreHandler:sendBattleTest()
    
    local msgBuffer = protobuf.encode("cs.C2S_TestBattle", {})
    self:sendMsg(NetMsg_ID.ID_C2S_TestBattle, msgBuffer)
    
end



function CoreHandler:sendGiftCode(code)
    
    local msgBuffer = protobuf.encode("cs.C2S_GiftCode", {code=code})
    self:sendMsg(NetMsg_ID.ID_C2S_GiftCode, msgBuffer)
    
end

function CoreHandler:sendGetBlackcardWarning(  )
    local msgBuffer = protobuf.encode("cs.C2S_GetBlackcardWarning", {code=code})
    self:sendMsg(NetMsg_ID.ID_C2S_GetBlackcardWarning, msgBuffer)
end

function CoreHandler:sendCDLevel(level)
    
    local msgBuffer = protobuf.encode("cs.C2S_SetCDLevel", {level=level})
    self:sendMsg(NetMsg_ID.ID_C2S_SetCDLevel, msgBuffer)
    
end


function CoreHandler:_onReceiveBlackcardWarning( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBlackcardWarning", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BLACKCARD_WARNING, nil, false,  decodeBuffer.warning) 
end

function CoreHandler:_recvActiveMsg()
   uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NETWORK_ALIVE, nil, false, nil) 
end

-- 网络错误消息

function CoreHandler:_recvLoginMsg( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Login", msg, len)
    --dump(decodeBuffer)
    

    if type(decodeBuffer) ~= "table" then 
        -- GlobalFunc.uploadLog({{event_id="S2CLoginFailed"}})
        return 
    end
    if rawget(decodeBuffer, "platform_uid") then
        G_PlatformProxy:setUid(decodeBuffer.platform_uid)

    end
    if rawget(decodeBuffer, "yzuid") then
        G_PlatformProxy:setYzuid(decodeBuffer.yzuid, true)
    end

    local logData = {{event_id="S2CLogin"}, {ret=tostring(decodeBuffer.ret)}}
    -- GlobalFunc.uploadLog(logData)


    if decodeBuffer.ret == NetMsg_ERROR.RET_USER_NOT_EXIST then
        G_NetworkManager:setSessionId(decodeBuffer.sid)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NEED_CREATE_ROLE, nil, false, nil)
    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_LOGIN_REPEAT then    
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NEED_RELOGIN, nil, false, nil) 
    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_SERVER_MAINTAIN then    
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAINTAIN, nil, false, nil) 
    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_LOGIN_BAN_USER then 
          --被封号了
          uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BAN_USER, nil, false, nil) 

    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_LOGIN_TOKEN_TIME_OUT then 
          --登录token无效
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TOKEN_EXPIRED, nil, false, nil) 
    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_LOGIN_BAN_USER2 then 
        --不在白名单内
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NOT_ALLOWED, nil, false, nil) 

    elseif  decodeBuffer.ret == NetMsg_ERROR.RET_VERSION_ERR then 
        --版本号错误
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_WRONG_VERSION, nil, false, nil) 

    elseif decodeBuffer.ret == NetMsg_ERROR.RET_SERVER_USER_OVER_CEILING then  --服务器到达承载上线
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SERVER_CROWD, nil, false, nil) 
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_LOGIN_BLACKCARD_USER then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BLACKCARD_USER, nil, false, nil) 
    else
        
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            MsgProcessHandler:getInstance():setUserId(decodeBuffer.uid)
            G_NetworkManager:setSessionId(decodeBuffer.sid)
            self:_onLogin()
        end
    end
end

-- 创建角色信息
function CoreHandler:_recvCreateRoleMsg(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Create", msg, len)
    --dump(decodeBuffer)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
       
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            MsgProcessHandler:getInstance():setUserId(decodeBuffer.uid)
            G_NetworkManager:setSessionId(decodeBuffer.sid)

            if self.cacheRoleName ~= "" then
                G_Me.userData.name = self.cacheRoleName
            end

            self:_onLogin()
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CREATED_ROLE, nil, false, nil)


            
        --else
           -- G_MovingTip:showMovingTip(G_NetMsgError.getMsg(decodeBuffer.ret))
        end
    end
end

function CoreHandler:_onLogin()
    G_Me.isLogin = true
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_LOGIN_SUCCESS, nil, false, nil)
end




-- 刷新数据消息
function CoreHandler:_recvFlushMsg( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Flush", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end



    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
  
        --判断是否登录时取得flush数据
        if self._loginFlushKeys ~= nil then
            self:_sendFlushSegment()            
        else
        end


    end
end


function CoreHandler:_setRoleData( user )
   
    G_Me.userData:setBaseData(user)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, nil, false, nil)

end

function CoreHandler:_recvRoleInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetUser", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    self:_setRoleData(decodeBuffer.user)
    self.cacheLoginData:setBaseData(decodeBuffer.user)

end


function CoreHandler:_recvGetServerTime( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetServerTime", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    local zoneMiniutes = decodeBuffer.zone
    local t = decodeBuffer.time
    zoneMiniutes = zoneMiniutes - 720
    local zone = zoneMiniutes / 60
    -- dump(decodeBuffer)

    G_ServerTime:setTime(t, zone)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SERVER_TIME_UPDATE, nil, false)
end

function CoreHandler:_recvGetGiftCode( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetGiftCode", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)

   
end

function CoreHandler:_recvHofPoints(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_HOF_Points", msg, len)
    G_Me.userData:setHofPoints(decodeBuffer.points)
end

function CoreHandler:_recvGetRollNotice( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RollNotice", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end


    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROLL_NOTICE, nil, false, decodeBuffer)

end

function CoreHandler:sendPushSingleInfo()
    local buffer = {}
    local msgBuffer = protobuf.encode("cs.C2S_PushSingleInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_PushSingleInfo, msgBuffer)
end

function CoreHandler:_recvPushSingleInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PushSingleInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if rawget(decodeBuffer, "content") and decodeBuffer.content ~= "" then
        if rawget(decodeBuffer, "level") and G_Me.userData.level >= decodeBuffer.level then
            if rawget(decodeBuffer, "vip_level") and G_Me.userData.vip >= decodeBuffer.vip_level then
                if rawget(decodeBuffer, "pushtime") then
                    local pushTime = decodeBuffer.pushtime - G_ServerTime:getTime()
                    if pushTime >= 0 then
                        G_NotifycationManager:addGMNotifycation(pushTime, decodeBuffer.content)
                    end
                end
            end
        end
    end
end

return CoreHandler

