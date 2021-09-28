
-- 服务器时间同步服务
local ServerTimeService =  class("ServerTimeService")

local SECONDS = 300 -- 每X秒一次同步


function ServerTimeService:ctor(networkManager)
     --self._lastSendTime = 0
     self._counter = 0
     self._networkManager = networkManager
end

function ServerTimeService:start()
    if self._timer == nil then
        local scheduler = require("framework.scheduler")   
        
        self._timer = scheduler.scheduleGlobal(handler(self, self._checkServerTime), 1)    
    end
    self:_sendGetServerTime()
end

function ServerTimeService:_checkServerTime()
    if not self._networkManager:isConnected() then
        return
    end
    
    self._counter  = self._counter + 1

    if self._counter >= SECONDS then
        
        self:_sendGetServerTime()
    end

end
function ServerTimeService:_sendGetServerTime()
    G_HandlersManager.coreHandler:sendGetServerTime()

    self._counter = 0
end

function ServerTimeService:clear()
    if self._timer ~= nil then
        local scheduler = require("framework.scheduler")   
        scheduler.unscheduleGlobal(self._timer)
        self._timer = nil
    end

end








return ServerTimeService
