
-- 网络连接 断开 重连 平台登录
local NetworkManager =  class("NetworkManager")
local ReconnectLayer = require("app.scenes.common.ReconnectLayer")

local TimeoutJob = require("app.common.tools.TimeoutJob")
function NetworkManager:ctor()
    if patchMe and patchMe("networkmanager", self) then return end

    self._hearBeartService = require("app.network.service.HeartBeatService").new(self)
    self._serverTimeService =  require("app.network.service.ServerTimeService").new(self)
    self._requestService = require("app.network.service.RequestService").new()
    self._connectingJob = nil --是否正在尝试连接
    self._dead = false  --收不到心跳包
    self._connectIndex = 0
    self._serverId = 0
    self._sessionid = 0

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NETWORK_DEAD, self._onDeadNetwork, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NETWORK_TIMEOUT, self._onNetworkTimeout, self)


end

--获取网络连接状态
function NetworkManager:isConnected()
    if self._dead then
        return false
    end
    return uf_netManager:checkConnection(self._connectIndex)
end


function NetworkManager:onLoginedGame()
    self._requestService:onLoginedGame()
end

function NetworkManager:_onDeadNetwork()
    GlobalFunc.trace("on dead connect")
    G_Report:addHistory("network", "dead")

    local isWaiting = self._requestService:hasWaiting()

    

    --如果现在有网络在等待， 断开后弹框提示

    if isWaiting then
        self:reset()

        ReconnectLayer.show(G_lang:get("LANG_NEED_RECONNECT"))
    else
        self:disconnect()
    end


    if G_Me and G_ServerTime then
        if G_Me.lastFlushDataTime > G_Me.lastOutofNetworkTime then
            G_Me.lastOutofNetworkTime = G_ServerTime:getTime()
        end
    end
end




function NetworkManager:_onNetworkTimeout()
    GlobalFunc.trace("_onNetworkTimeout")
    G_Report:addHistory("network", "timeout")

    self:reset()
    ReconnectLayer.show(G_lang:get("LANG_NEED_RECONNECT"))
end

function NetworkManager:disconnect()
    if self._dead then
        GlobalFunc.trace("dead already")
        return
    end
    GlobalFunc.trace("want disconnect")
    if uf_netManager:checkConnection(self._connectIndex) then
        GlobalFunc.trace("remove connect")
        uf_netManager:removeConnect(self._connectIndex)
    end
    

    self._requestService:onDisconnected()
    self._dead = true

end

--重新连接服务器
function NetworkManager:reconnect()
    if  not self:isConnected() then
        --如果已经连接上， 不要重新连接
        G_PlatformProxy:loginGame()
    end
    
end

--开始连接服务器
function NetworkManager:_connectToServer()

    local serverInfo = G_PlatformProxy:getLoginServer()
    self._serverId = serverInfo.id
    self._connectIndex = self._connectIndex 

    --use dns pod
    if G_Setting:get("open_dnspod") == "1" then
        require("app.common.network.DnsPod").getIp(serverInfo.gateway, function(ip) 
            if ip == "" then
                --error
                ip = serverInfo.gateway
            end

            uf_netManager:connectToServer(self._connectIndex,  ip, serverInfo.port)

        end)
    else
        uf_netManager:connectToServer(self._connectIndex,  serverInfo.gateway, serverInfo.port)

    end
    
    uf_messageDispatcher:setConnectHandler(self._onConnectServer, self)

    G_Report:addHistory("network", "connect")

end



function NetworkManager:_showLoading(b) 
    G_WaitingLayer:show(b)
end

--准备发送消息
function NetworkManager:sendMsg(id, buff) 
    self._requestService:addRequest(id, buff)


    self:checkConnection()
end

function NetworkManager:setSessionId(sessionid) 
    MsgProcessHandler:getInstance():setSessionId(sessionid)

    self._sessionid = sessionid
end

function NetworkManager:getSessionId() 
    return self._sessionid 
end

--如果现在网络没有联通, 进行连接
function NetworkManager:checkConnection() 
   
    if not self:isConnected() then 
        GlobalFunc.trace("find server not connected")
        G_Report:addHistory("network", "check")

        --没有连接过服务器, 先开始连接服务器
        if  self._connectingJob == nil then

            self._connectingJob = TimeoutJob.new(
                function()
                    GlobalFunc.trace("start connect..")

                    --开始连接吧,少年, 需要显示菊花
                    self:_showLoading(true)
                    self:_connectToServer()

                end,
                function(job, finish)                     
                    if finish then
                        --一般不会走到这个分支
                        self._connectingJob:stop()
                    else
                       --超时了  
                       self:_showLoading(false)

                       if not self:isConnected() then
                            self:reset()
                        end
                       GlobalFunc.trace("connect timeout!!!")

                       --弹框, 重连
                       ReconnectLayer.show(G_lang:get("LANG_NEED_RECONNECT"))
                    end

                    self._connectingJob = nil
                end,
                10
            )

        end
        
        return
    end
end

local ever_connect_ok =false

-- 连接成功失败socket相关消息
function NetworkManager:_onConnectServer(ret,connectIndex)
    if ret == 0 then -- socket连接成功 发送心跳包 绑定消息
        __LogTag("NetworkManager","@@@@@@@@@@@@ conect the game server success")

        if ever_connect_ok == false then
            ever_connect_ok = true
        end
        


        G_Report:addHistory("network", "conected")

        self:_showLoading(false)
        if self._connectingJob ~= nil then
            self._connectingJob:finish()
            self._connectingJob = nil
        else
            assert("not connecting job ")
        end
        self._dead = false

        ReconnectLayer.hide()
        self:setSessionId(0)

        self._hearBeartService:start()
        G_PlatformProxy:sendLoginGame()
      --MsgProcessHandler:getInstance():reconnect()
   else  -- socket 断开 
        print("!!disconnect")
        G_Report:addHistory("network", "disconnect")
        self:disconnect()
    

        if self._connectingJob ~= nil then
           self._connectingJob:timeout()   
        end
        
   end
end




function NetworkManager:startServerTimeService()
    self._serverTimeService:start()
end

--回到登陆界面时需要重置
function NetworkManager:reset() 
    G_Report:addHistory("network", "reset")

    self:disconnect()
    self._requestService:clear()
end

function NetworkManager:dumpRequest( ... )
    if self._requestService then 
        self._requestService:dumpRequestService()
    end
end


return NetworkManager
