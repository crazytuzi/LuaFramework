--CommonDownloadHandler.lua


local CommonDownloadHandler = {}

CommonDownloadHandler.DOWNLOAD_EVENT = {
    DOWNLOAD_START = 1,
    DOWNLOAD_PROGRESS = 2,
    DOWNLOAD_SUCCESS = 3,
    DOWNLOAD_FAILED = 4,
    DOWNLOAD_INTERRUPT = 5,
    DOWNLOAD_FINISH = 6,
    DOWNLOAD_UNZIP = 7,
}


function CommonDownloadHandler.init( ... )
    if not CommonDownloadHandler.initSuccess then 
        FileDownloadUtil:showDownloadLog(false)
        CommonDownloadHandler.initSuccess = true
        CommonDownloadHandler._dispatcherHandlers = {}
        CommonDownloadHandler._globalEventHandlers = {}
	    FileDownloadUtil:getInstance():registerDownloadHandler(function ( ... )
            CommonDownloadHandler._onDownloadEventHandler(...)
        end)
    end
end

function CommonDownloadHandler._onDownloadEventHandler( eventName, ret, fileUrl, filePath, param1, param2 )
	if type(eventName) ~= "string" then 
        return 
    end

    if eventName == "start" then
    	CommonDownloadHandler._onDownloadStart(fileUrl, filePath )
    elseif eventName == "progress" then 
    	CommonDownloadHandler._onDownloadProgress(fileUrl, filePath, ret, param1, param2)
    elseif eventName == "success" then 
        CommonDownloadHandler._onDownloadSuccess(fileUrl, filePath)
    elseif eventName == "failed" then 
    	CommonDownloadHandler._onDownloadFailed(fileUrl, filePath, ret )
    elseif eventName == "finish" then 
        CommonDownloadHandler._onDownloadFinish()
    elseif eventName == "inerrupt" then 
        CommonDownloadHandler._onDownloadInerrupt(fileUrl, filePath)
    elseif eventName == "unzip" then 
        CommonDownloadHandler._onDownloadUnzip(fileUrl, filePath, ret)
    end
end

function CommonDownloadHandler._onDownloadStart(fileUrl, filePath )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_START, fileUrl, filePath)
end

function CommonDownloadHandler._onDownloadProgress(fileUrl, filePath, ret, param1, param2 )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_PROGRESS, fileUrl, filePath, ret, param1, param2)
end

function CommonDownloadHandler._onDownloadSuccess(fileUrl, filePath )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_SUCCESS, fileUrl, filePath)
    CommonDownloadHandler.unregisterDownloadEvent(fileUrl)
end

function CommonDownloadHandler._onDownloadFailed(fileUrl, filePath, ret )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FAILED, fileUrl, filePath, ret)
end

function CommonDownloadHandler._onDownloadFinish( )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FINISH)
end

function CommonDownloadHandler._onDownloadInerrupt(fileUrl, filePath )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_INTERRUPT, fileUrl, filePath)
end

function CommonDownloadHandler._onDownloadUnzip(fileUrl, filePath, ret )
    CommonDownloadHandler._dispatcherDownloadEvent(CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_UNZIP, fileUrl, filePath, ret)
end

function CommonDownloadHandler._dispatcherDownloadEvent( eventId, fileUrl, ... )
    if (eventId ~= CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FINISH and (type(fileUrl) ~= "string" or #fileUrl < 1)) then
        return 
    end

    if eventId ~= CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FINISH then 
        local eventElement = CommonDownloadHandler._dispatcherHandlers[fileUrl]
        if type(eventElement) == "function" then 
            eventElement(eventId, fileUrl, ...)
            if eventId == CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_SUCCESS then 
                CommonDownloadHandler._dispatcherHandlers[fileUrl] = nil
            end
        end        
    end

    for key, value in pairs(CommonDownloadHandler._globalEventHandlers) do 
        if type(key) == "function" then 
            key(eventId, fileUrl, ...)
        end
    end
end

--[[ 
handler (downloadEvent, fileUrl, filePath, ret, param1, param2)
]]
function CommonDownloadHandler.registerDownloadEvent( url, handler )
    if type(url) ~= "string" or #url < 1 or type(handler) ~= "function" then
        return 
    end

    CommonDownloadHandler.init()
    CommonDownloadHandler._dispatcherHandlers[url] = handler
end

function CommonDownloadHandler.unregisterDownloadEvent( url )
    if type(url) ~= "string" or #url < 1 then
        return 
    end

    CommonDownloadHandler.init()
    CommonDownloadHandler._dispatcherHandlers[url] = nil
end

function CommonDownloadHandler.registerGlobalEvent( handler )
    if type(handler) ~= "function" then
        return 
    end

    CommonDownloadHandler.init()
    CommonDownloadHandler._globalEventHandlers[handler] = 1
end

function CommonDownloadHandler.unregisterGlobalEvent( handler )
    if type(handler) ~= "function" then
        return 
    end

    CommonDownloadHandler.init()
    CommonDownloadHandler._globalEventHandlers[handler] = nil
end

function CommonDownloadHandler.addDownloadTask( url, path, md5, unzip, handler  )
    if type(url) == "string" and type(path) == "string" then
        FileDownloadUtil:getInstance():addDownloadTask(url, path, md5, unzip and true or false)
    end

    if type(handler) == "function" then 
        CommonDownloadHandler.registerDownloadEvent(url, handler)
    end
end

function CommonDownloadHandler.startDownload( ... )
    CommonDownloadHandler.init()
    if FileDownloadUtil:getInstance():getTaskCount() < 1 then 
        return 
    end
    FileDownloadUtil:getInstance():resumeDownload()
end

function CommonDownloadHandler.pauseDownload( ... )
    FileDownloadUtil:getInstance():pauseDownload()
end

function CommonDownloadHandler.isDownloading( ... )
    return not FileDownloadUtil:getInstance():isDownloadPause()
end

return CommonDownloadHandler
