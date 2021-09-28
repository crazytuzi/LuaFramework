
-- 服务器时间同步服务
local RequestService =  class("RequestService")

local NetRequest = require("app.network.NetRequest")


function RequestService:ctor()
    if patchMe and patchMe("request", self) then return end  

   self._requestList = {}
   self._cacheRequestList = {}  --这里一般是空,当断线后, 把requestList的东西挪动到_cacheReuqestList里, 登陆成功后, 重新把 self._cacheRequestList发一遍


    self._waitTimer = GlobalFunc.addTimer(1, handler(self, self._onTimer))

    uf_netManager:hookNetEvent(function ( flag, msgId, content )
        if flag == 0 then
            self:_onNetReceiveEvent( msgId, content )
        elseif flag == 1 then 
            -- self:_onNetSendEvent( msgId, content )
        end
    end)
end

function RequestService:hasRequestInQueue(id)
    local finded = false
    for i,request in ipairs(self._requestList) do 
         local id2 = request:getId()
         if id2 == id then
            finded = true
            break
        end
    end
    return finded
end


function RequestService:addRequest(id, msg)

    local request = NetRequest.new(id, msg)
    if not G_NetworkManager:isConnected() then 
        --登录协议永远不可能放入队列， 登录协议是连接服务器后默认发送的
        --flush永远不可能放入cache中，因为flush永远是连接成功，登录成功后发送的
        if id == NetMsg_ID.ID_C2S_FLUSH or id == NetMsg_ID.ID_C2S_Login then
            return
        end

        self:_addCacheRequest(request)
    else
        --如果现在没有login过游戏，也就是没有取到过session id,那么只有心跳跟login协议才能直接发送，其他协议都只能先放入缓存
        if G_NetworkManager:getSessionId() == 0 then
            if id == NetMsg_ID.ID_C2S_FLUSH then
                return
            end

            if id == NetMsg_ID.ID_C2S_Login then
                --开始登录吧少年， 这个地方，self._requestList 不可能有值， 因为断线的时候清空过， 
                --不过保险起见， 先清空吧
                self._requestList = {}
                table.insert(self._requestList, request)

            else
                self:_addCacheRequest(request)
            end

        else
            --session id不为0 说明已经登录过了，怎么可能会发送login协议
            if id == NetMsg_ID.ID_C2S_Login then
                return
            end
            table.insert(self._requestList, request)
        end


    end
    
    self:sendAll()
end



function RequestService:sendAll() 
    if not G_NetworkManager:isConnected() then 
        return false
    end



    for i,request in ipairs(self._requestList) do 
        if not request:isSent() then
            request:send()
            if G_Report then
                G_Report:addHistory("send", request:getId())
            end
        end
    end

    self:_checkWaiting()

    return true
end





function RequestService:_onNetReceiveEvent( msgId, content )
    GlobalFunc.trace("receive " .. msgId)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NETWORK_ALIVE, nil, false, nil) 

    if G_Report then
        G_Report:addHistory("recv", msgId)
    end
    for i,request in ipairs(self._requestList) do 
        if request:isSent() then
            if request:checkResponse(msgId) then
                table.remove(self._requestList, i , 1)
                break
            end
        end
    end

    self:_checkWaiting()
end

function RequestService:_checkWaiting() 


    --self:_showLoading(self:hasWaiting())
end


function RequestService:hasWaiting() 
    local waiting = false
    for i,request in ipairs(self._requestList) do 
        if request:isWaiting() then
            local id = request:getId()
            waiting = true
            break
        end
    end

    return waiting
end


function RequestService:_showLoading(b) 
    G_WaitingLayer:show(b)
end



function RequestService:_addCacheRequest(request) 
    local id = request:getId()
    if id ~= NetMsg_ID.ID_C2S_KeepAlive and id ~= NetMsg_ID.ID_C2S_Login then
        table.insert(self._cacheRequestList, request)
    end
end


function RequestService:onDisconnected() 
    --self._cacheRequestList = {}
    for i,request in ipairs(self._requestList) do 
        if not request:isSent()   then
            self:_addCacheRequest(request)
        end
    end
    self._requestList = {}
    self:_checkWaiting()
end


function RequestService:onLoginedGame() 
    for i,request in ipairs(self._cacheRequestList) do 
        table.insert(self._requestList, request)
    end
    self._cacheRequestList = {}

    self:sendAll()
end

function RequestService:_onTimer() 
    if not G_NetworkManager:isConnected() then 
        -- self:_checkWaiting()
        return false
    end

    --check timeout
    local timeout = false
    local tick = FuncHelperUtil:getTickCount()
    for i,request in ipairs(self._requestList) do 
        if request:isTimeout(tick) then
            timeout = true
            GlobalFunc.trace("timeout for " .. request:getId())

            if request:getId() == NetMsg_ID.ID_C2S_Login then 
              
                GlobalFunc.uploadLog({{event_id="C2SLoginTimeout"}})
            elseif  request:getId() == NetMsg_ID.ID_C2S_Flush then 
              
                GlobalFunc.uploadLog({{event_id="C2SFlushTimeout"}})
            end

            
            break
        end
    end

    if timeout then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NETWORK_TIMEOUT, nil, false, nil)
    end
end



function RequestService:clear( )
    self._requestList = {}
    self._cacheRequestList = {}
end

function RequestService:dumpRequestService( ... )
    __Log("----------dumpRequestService----------")
    for i, request in ipairs(self._requestList) do 
        request:dumpRequestInfo()
    end
    __Log("--------------------------------------")
end

return RequestService
