
local g_svnConfigFile = "svnConfigFile.lua"

ResourceUpdate = {
	serverIp,
    serverPort,
    versionNum,
    svnVersion,

    serverVersion,
    clientVersion,
    updateVersion,

    updateResourceList,
    currentUpdateCount,
    totalUpdateCount,

    svnConfigFilePath,

    updateFileCallBack,
    updateFinishCallBack
}

function ResourceUpdate:init()
    if  CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        self.svnConfigFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. g_svnConfigFile
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        self.svnConfigFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. '../Library/' .. g_svnConfigFile
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        local sdPath = TFDeviceInfo.getSDPath()
        if sdPath and #sdPath >1 then
             local  sPackName = TFDeviceInfo.getPackageName()
            sdPath = sdPath .."playmore/" .. sPackName .. "/"
            self.svnConfigFilePath = sdPath .. g_svnConfigFile
        else
            self.svnConfigFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. g_svnConfigFile
        end 
    end

    -- load version info
    if TFFileUtil:existFile(self.svnConfigFilePath) then
        local versionInfo   = require(g_svnConfigFile)
        self.serverIp       = versionInfo.serverIp
        self.serverPort     = versionInfo.serverPort
        self.updateVersion  = tonumber(versionInfo.inputVersion)
        self.clientVersion  = tonumber(versionInfo.svnVersion)
        self.needShow       = versionInfo.needShow
    else
        self.serverIp       = "10.10.3.94"
        self.serverPort     = "8092"
        self.updateVersion  = 0
        self.clientVersion  = 0
        self.needShow       = true
    end

    self.serverUrl= string.format('http://%s:%s/', self.serverIp, self.serverPort)
    self.resouceListUrl = self.serverUrl .. "diff?begin=%s&end=%s"
    self.updateResourceList = {}
end

function ResourceUpdate:checkNeedUpdate(callback, newVersion)
    local function checkCallback(clientVersion)
        local tarVersion = self.updateVersion == 0 and self.serverVersionNum or self.updateVersion
        callback(tarVersion, clientVersion)
    end
    self:requestUpdateResourceList(checkCallback, newVersion)
end

function ResourceUpdate:writeVersionInfoToFile()
    if not self.svnConfigFilePath then
        return false   
    end
    local tarVersion = self.updateVersion == 0 and self.serverVersionNum or self.updateVersion
    self.clientVersion = tarVersion
    TFFileUtil:write(self.svnConfigFilePath, string.format([[
    local t =
    {
        serverIp = "%s",
        serverPort = "%s",
        inputVersion = "%s",
        svnVersion = "%s",
        needShow = %s,
    }
    return t]], self.serverIp, self.serverPort, self.updateVersion, self.clientVersion, self.needShow == nil and 'true' or self.needShow))
    return true
end

function ResourceUpdate:requestUpdateResourceList(_callback, newVersion)
    if newVersion then 
        self.updateVersion = newVersion
    end
    local HttpLoader= TFClientNetHttp:GetInstance()
    HttpLoader:setMaxConnectSec(5)
    HttpLoader:addMERecvListener(function(nType, nRet, pData)
        if nRet == -1 then 
            if self.updateFailCallback then 
                self.updateFailCallback()
            end
            return 
        end

        pData = pData:gsub("<br>", "")
        local lines = pData:split('\n')
        lines[1] = lines[1]:trim()
        local serverVersionNum = lines[1]
        --  version number error
        if tonumber(serverVersionNum) and tonumber(serverVersionNum) < 0 then
            self.serverVersionNum = tonumber(serverVersionNum)
            HttpLoader:httpRequest(TFHTTP_TYPE_GET,string.format(self.resouceListUrl, self.clientVersion, self.updateVersion))
            return
        end

        lines[1] = nil
        self.serverVersionNum = tonumber(serverVersionNum)
        for k,v in pairs(lines) do
            local line = lines[k]:trim()
            if line and #line>0 and line[1] ~= 'D' then
                line = line['4']
                table.insert(self.updateResourceList, line)
            end
        end

        if _callback then
            local clientVersion = self.clientVersion
            _callback(clientVersion)
        end
    end)
    HttpLoader:httpRequest(TFHTTP_TYPE_GET, string.format(self.resouceListUrl, self.clientVersion, self.updateVersion))
end 

function ResourceUpdate:updateFile(_url)
    if self.updateFileCallBack then
        self.updateFileCallBack(_url, self.currentUpdateCount/(#self.updateResourceList))
    end

    local function HttpUpdateComplete(fileName, updateResult, nResultCode, szErr)
        if nResultCode == TF_SVN_UPDATE_NOSPACE then
            CCMessageBox(szErr," SDCard is full")
            return
        end

        -- download failed
        if not updateResult then
            self.updateFailedCount = self.updateFailedCount or 0
            self.updateFailedCount = self.updateFailedCount + 1

            if self.updateFailedCount <= 3 then
                -- update the file again
                self:updateFile(_url)
                return
            end
        end

        -- update next file
        self.currentUpdateCount = self.currentUpdateCount + 1

        if self.currentUpdateCount <= #self.updateResourceList then
            local url = self.updateResourceList[self.currentUpdateCount]
            self:updateFile(url) 
        else
            if self.updateFinishCallBack then
                self.updateFinishCallBack()
            end
        end
    end

    TFHttpResource:sharedHttpResource():updateResource(_url, HttpUpdateComplete)
end

function ResourceUpdate:run(newVersion)

    self:requestUpdateResourceList(function()
        -- prepare update files
        TFHttpResource:sharedHttpResource():setPreUpdateUrl(self.serverUrl)
        TFHttpResource:sharedHttpResource():setPreSaveUrl("TFDebug")

        local function saveUrlCallback(szfileName, updateResult)
            local nIndex = string.find(szfileName , "/")
            local szUrl  = string.sub(szfileName , nIndex + 1)
            TFHttpResource:sharedHttpResource():setSaveUrl(szUrl)
        end
        TFHttpResource:sharedHttpResource():setSaveCallback(saveUrlCallback)

        -- update the first file
        self.currentUpdateCount = 1
        
        if #self.updateResourceList < 1 then
            if self.updateFinishCallBack then
                self.updateFinishCallBack()
            end
            return
        end
        local fileUrl = self.updateResourceList[1]
        self:updateFile(fileUrl)
    end, newVersion)
end

function ResourceUpdate:clearAllResouces()
    self.updateVersion = 0
    self.clientVersion = 0

    self.updateResourceList = {}
    self.updateFailedCount  = 0

    local updatePath = CCFileUtils:sharedFileUtils():getWritablePath()
    if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        local sdPath = TFDeviceInfo.getSDPath()
        if type(sdPath) == 'string' and #sdPath >1 then
            local  sPackName = TFDeviceInfo.getPackageName()
            sdPath = sdPath .."playmore/" .. sPackName .. "/TFDebug"
            CCFileUtils:sharedFileUtils():removeDirAndFiles(sdPath)
        end
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        CCFileUtils:sharedFileUtils():removeDirAndFiles(updatePath .. '../Library/' .. "TFDebug")
    else
        CCFileUtils:sharedFileUtils():removeDirAndFiles(updatePath .. "TFDebug")
    end
end

return ResourceUpdate