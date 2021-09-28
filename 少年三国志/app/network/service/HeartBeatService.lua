
-- 心跳服务
local HeartBeatService =  class("HeartBeatService")

local SECONDS = 15000 -- 每X秒一次心跳
local TIMEOUT_SECONDS = 50000 -- X秒内都没收到过心跳包

function HeartBeatService:ctor(networkManager)
     --self._lastSendTime = 0
     self._networkManager = networkManager

     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NETWORK_ALIVE, self._onAlive, self)

     local scheduler = require("framework.scheduler")   
     self._timer = scheduler.scheduleGlobal(handler(self, self._onTimer), 1)    

     self._lastSendCounter = 0
     self._lastRecvCounter = 0

end



-- -- 启动心跳包发送
function HeartBeatService:start()
    --self:sendLoginGame()
    local t = FuncHelperUtil:getTickCount() 
    self._lastSendCounter = t
    self._lastRecvCounter = t

    self:_send()
end

function HeartBeatService:_onAlive()
    self._lastRecvCounter = FuncHelperUtil:getTickCount()
end

-- 定时发送心跳包
function HeartBeatService:_onTimer()
    local t = FuncHelperUtil:getTickCount() 
    local elapsedSend = t - self._lastSendCounter
    local elapsedRecv = t - self._lastRecvCounter


    if not self._networkManager:isConnected() then
        return
    end

   

    if elapsedRecv >= TIMEOUT_SECONDS then
        --shit ,timeout
        self._lastRecvCounter = t
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NETWORK_DEAD, nil, false, nil) 

        return
    end

    if elapsedSend >= SECONDS then
        self:_send()
    end

end



function HeartBeatService:_send()
    self._lastSendCounter = FuncHelperUtil:getTickCount() 
    G_HandlersManager.coreHandler:sendKeepAlive()

end

function HeartBeatService:clear()
    if self._timer ~= nil then
        local scheduler = require("framework.scheduler")   
        scheduler.unscheduleGlobal(self._timer)
        self._timer = nil
    end

end


return HeartBeatService
