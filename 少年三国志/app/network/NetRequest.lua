
local NetRequest =  class("NetRequest")
local MonitorProtocal = require("app.network.MonitorProtocal")

local TimeoutJob = require("app.common.tools.TimeoutJob")

local TIMEOUT = 60000

function NetRequest:ctor(id, msg)
    if patchMe and patchMe("netrequest", self) then return end  

    self._id = id 
    self._msg = msg
    self._sent = false  --是否已经发送
    self._reponseId = MonitorProtocal[id] or 0 --响应的msgId, 只有monitor的协议,这个字段才有意义
    self._responsed = false --是否已经得到响应, 只有monitor的协议,这个字段才有意义
    self._sendTime = 0
end


function NetRequest:isSent()
    return self._sent
end

function NetRequest:send()
    uf_messageSender:sendMsg(self._id, self._msg)
    self._sendTime = FuncHelperUtil:getTickCount()
    self._sent = true

    if self._id == NetMsg_ID.ID_C2S_Login then
        local logData = {{event_id="C2SLogin"},  {uid=tostring(G_PlatformProxy:getPlatformUid())}  }

        -- GlobalFunc.uploadLog(logData)
    elseif self._id == NetMsg_ID.ID_C2S_Flush then

        local logData = {{event_id="C2SFlush"}}

        -- GlobalFunc.uploadLog(logData)
    end


    
    GlobalFunc.trace("send .." .. self._id)
end

function NetRequest:checkResponse(responseId)
    if self._responsed then
       return false
    end
    if type(self._reponseId) == "table" then 
        for key, value in pairs(self._reponseId) do 
            if value == responseId then 
                self._responsed = true
            end
        end
    elseif (type(self._reponseId) == "number") and (self._reponseId == responseId) then
       self._responsed = true
    end
    return self._responsed
end

function NetRequest:getId()
    return self._id

end

function NetRequest:getResponseMsgId()
    return self._reponseId
end

function NetRequest:isWaiting()
    if self._reponseId == 0 then
      return false
    end

    if self._sent then
        return not self._responsed
    else
        return false
    end
end

function NetRequest:isTimeout(now)
    if self._reponseId == 0 then
        return false
    end
    if self._responsed  then
        return false
    end

    if TIMEOUT <= now - self._sendTime then
        return true
    end
    return false
end

function NetRequest:dumpRequestInfo( ... )
    local requestIdStr = "["
    if type(self._reponseId) == "table" then 
        for key, value in pairs(self._reponseId) do 
            requestIdStr = requestIdStr..value..", "
        end
    elseif (type(self._reponseId) == "number" and self._reponseId > 0) then
        requestIdStr = requestIdStr..self._reponseId
    else
        return 
    end
    requestIdStr = requestIdStr.."]"

    __Log("[NetRequest] send id=[%d], wait request id=%s", self._id, requestIdStr)
end


return NetRequest
