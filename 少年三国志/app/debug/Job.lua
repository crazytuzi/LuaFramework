
local Job  = class("Job")

local ComSdkUtils = require("upgrade.ComSdkUtils")

Job.checkUpdateInterval = 60000 * 15 -- seconds
Job.waitingCodeInterval =    60000*5

-- G_HandlersManager.codeHandler:sendGetCode()

function Job:ctor() 
    self._idHistory = {}
    self._waitingCodeId = ""
    self._lastGetCodeIdTime = 0
    self._waitingStartTime = 0
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CODEID, self._onGetCodeId, self )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CODE, self._onGetCode, self )
end


function Job:_onGetCodeId(id)
    if self._idHistory[id]  then
        --ignore
        --print("ignore")
    else
        local serverTime = G_ServerTime:getTime()
        if self._waitingCodeId == id and  (serverTime - self._waitingStartTime ) < Job.waitingCodeInterval   then
            --waiting
            --print("waiting")
        else
            --print("go get code")
            self._waitingCodeId = id 
            self._waitingStartTime = G_ServerTime:getTime()
            G_HandlersManager.codeHandler:sendGetCode()   
        end

    end
end


function Job:_onGetCode(code)

    local crypto = require("framework.crypto")  
    -- code = "--UF--" .. code
    local usingLocalRequire = false
    if string.sub(code, 1, 6) == "--UF--" then
        code = string.sub(code, 7, #code )
        usingLocalRequire = true
    end
    local src = crypto.decodeBase64(code)
    if src then
        local k = "local"
        local g = "g"
        local custom = crypto.decryptXXTEA(  src, k .. " " .. g)
        if custom then

            local deflatelua = require("app.storage.deflatelua")
            local string_char = string.char
            local result = ""
            deflatelua.inflate_zlib({input=custom,output=function(b) 
                result = result.. string_char(b) 
            end })

            self._lastCode = result

            if usingLocalRequire then
                local filePath = ""

                if isApp64Version and isApp64Version() then 
                    FuncHelperUtil:createDirectory(CCFileUtils:sharedFileUtils():getWritablePath()  .. "upgrade/scripts64/")
                    filePath = CCFileUtils:sharedFileUtils():getWritablePath()  .. "upgrade/scripts64/sgz.lua"
                else 
                    FuncHelperUtil:createDirectory(CCFileUtils:sharedFileUtils():getWritablePath()  .. "upgrade/scripts/")
                    filePath = CCFileUtils:sharedFileUtils():getWritablePath()  .. "upgrade/scripts/sgz.lua"
                end


                io.writefile(filePath, result)
                
                if io.exists(filePath) then 
                     package.loaded["sgz"] = nil 

                    self._customResult  = require("sgz")
                    self._idHistory[self._waitingCodeId ]  = code 
                    self._waitingCodeId = "" 
                    os.remove(filePath)
                end
               
            else

                local customFunc  = require("app.MyApp").oldloadstring(result)
                if customFunc ~= nil and type(customFunc) == "function" then
                    self._customResult = customFunc()  

                    print("wait finish")
                    self._idHistory[self._waitingCodeId ]  = code 
                    self._waitingCodeId = "" 
                end 
            end

        end
    end
    

end

function Job:getLastCode()
    
    return self._lastCode

end


function Job:_sendGetCodeId()
    self._lastGetCodeIdTime = G_ServerTime:getTime()
    G_HandlersManager.codeHandler:sendGetCodeId()
end

function Job:onLoginedGame()
    self:_sendGetCodeId()

end




function Job:checkUpdate(serverTime)

    if serverTime - self._lastGetCodeIdTime > Job.checkUpdateInterval then
        self:_sendGetCodeId()
    end
end


return Job