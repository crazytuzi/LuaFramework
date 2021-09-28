--AutoDownloadModule.lua


local CommonDownloadHandler = require("app.scenes.common.CommonDownloadHandler")

local AutoDownloadModule = class("AutoDownloadModule")


AutoDownloadModule.DEBUG_MODE = false
AutoDownloadModule.DEBUG_NETWORK_WIFI = false

AutoDownloadModule.DOWNLOAD_ARRAY_SIZE = 5
AutoDownloadModule.MAX_RETRY_COUNT = 3

AutoDownloadModule.PACK_FILE_NAME = "HDRes.pack"
AutoDownloadModule.LOCAL_FILE_NAME = "HDRes.local"

AutoDownloadModule.DOWNLOAD_PROGRESS_UDPATE = "pack_download_progress"
AutoDownloadModule.DOWNLOAD_STATUS_EVENT 	= "download_status_event"

function AutoDownloadModule:ctor( ... )
	self._isWifiNetwork = false
	self._isForceDownloadModel = false
	self._isForceDownload = false
	self._networkTimer = nil 
	self._completeDownload = false
	self._totalPackTaskCount = 0
	self._curDownloadTaskSize = 0
	self._curDownloadProgress = 0
	self._curRetryCount = 0

	self._fileDownloadUrlPath = G_Setting:get("hd_res_url") or "http://192.168.180.33/pack/res/"
	AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER = CCFileUtils:sharedFileUtils():getWritablePath().."hd/res/"
	AutoDownloadModule.LOCAL_DOWNLOAD_FILE = AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER.."/"..AutoDownloadModule.LOCAL_FILE_NAME

	os.mkdir(AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER)
	__Log("hd folder:%s\nlocal list file:%s \nhd url:%s",
	 AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER, AutoDownloadModule.LOCAL_DOWNLOAD_FILE, self._fileDownloadUrlPath)


	self._willDownloadFileList = {}
	self._downloadingFileList = {}
	self._downloadFailedList = {}

	local hdSearchIndex = 0
	if G_NativeProxy.platform ~= "windows" or (G_NativeProxy.platform == "windows" and  WINDOWS_USE_UPGRADE == 1 ) then
        hdSearchIndex = 1
    end

    if FuncHelperUtil.addSearchPath then
    	__Log("add serarch path[%s], at search index:%d", AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER, hdSearchIndex)
    	FuncHelperUtil:addSearchPath(AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER, hdSearchIndex)
    end

    uf_eventManager:addEventListener("config_event_singal", function ( self, tag )
    	if tag == 1 then 
    		AutoDownloadModule.DEBUG_SET_WIFI_TYPE(true, true)        
    	else
    		AutoDownloadModule.DEBUG_SET_WIFI_TYPE(false, false)        
    	end
    end, self)

	self:_generateDownloadList()
	self:startNetworkCheck()
end

function AutoDownloadModule:_loadDownloadList( configFile, isLocal )
	local fileList = {}

	local parseLine = function ( line )
		if type(line) ~= "string" then 
			return 
		end
		
		local spaceStart, spaceLen = string.find(line, "^%s*#")
		if type(spaceLen) == "number" and spaceLen > 0 then 
			return 
		end

		local fileUrl, md5Value = string.match(line, "([%w_/.-]+)%s*,%s*([%w]+)")

		if type(fileUrl) == "string" and type(md5Value) == "string" then
			if isLocal then
				fileList[fileUrl] = md5Value
			else
				table.insert(fileList, #fileList + 1, {url = fileUrl, md5 = md5Value})
			end	
		else
			__LogError("[PACK] fileUrl=%s, md5Value=%s", tostring(fileUrl), tostring(md5Value))
		end
	end

	local path = CCFileUtils:sharedFileUtils():fullPathForFilename(configFile)
	--local file = io.open(path, "r")
	--if not file then 
	--	return fileList
	--end

	local content = nil
	local index = 1
	local fileData = CCFileUtils:sharedFileUtils():getFileData(path)
	if fileData then 
		iter = string.gfind(fileData, "[^%s]+%s*,%s*[^%s]+")
		repeat
			content = iter()
			parseLine(content)
		until(not content)
	end

    --repeat
    --    content = file:read("*l")
    --    parseLine(content)
    --until(not content)
   -- io.close(file)

    return fileList
end

function AutoDownloadModule:_generateDownloadList( ... )
	--AutoDownloadModule.GeneratePackFileList("D:\\project\\sanguohero\\client\\trunk\\develop\\sanguohero\\res_min\\", 	"D:\\project\\sanguohero\\client\\trunk\\develop\\sanguohero\\res_min\\res\\")
	local packFileList = self:_loadDownloadList(AutoDownloadModule.PACK_FILE_NAME)
	local localFileList = self:_loadDownloadList(AutoDownloadModule.LOCAL_DOWNLOAD_FILE, true)
	if #packFileList < 1 then 
		self._completeDownload = true
		return 
	end

	for index, value in pairs(packFileList) do 
		local localMd5 = localFileList[value.url]
		if type(localMd5) ~= "string" or localMd5 ~= value.md5 then 
			table.insert(self._willDownloadFileList, #self._willDownloadFileList + 1, value)
		end
	end

	self._totalPackTaskCount = #packFileList
	self._completeDownload = (#self._willDownloadFileList < 1)
	self:_updateDownloadProgress()
	__Log("local download list file count:%d, total:%d, local:%d", 
		#self._willDownloadFileList, #packFileList, #packFileList - #self._willDownloadFileList)
end

function AutoDownloadModule.GeneratePackFileList( srcPath, resPath, savePath )
	if type(srcPath) ~= "string" or #srcPath < 10 then 
		return 
	end

	local listFile = srcPath.."/files.txt"
	local file = io.open(listFile, "r")
	savePath = savePath or CCFileUtils:sharedFileUtils():fullPathForFilename(AutoDownloadModule.PACK_FILE_NAME)
	local saveFile = io.open(savePath, "w+")
	if not file or not saveFile then 
		return fileList
	end

	local contentCount = 0
	local parseLine = function ( content)
		if type(content) ~= "string" then 
			return 
		end

		content = string.gsub(content, "%s*(^%s*)%s*", {})
		local destFile = resPath..content
		--print(destFile)
		local md5Value = FuncHelperUtil:MD5File(destFile)
		local writeContent = string.format("%s,%s\n", content, md5Value)
		saveFile:write(writeContent)
		contentCount = contentCount +1
	end

	local content = nil
    repeat
        content = file:read("*l")
        parseLine(content)
    until(not content or contentCount >= 100000)
    __Log("contentCount:%d", contentCount)
    __Log("path=%s", savePath)
    io.close(file)
    io.close(saveFile)
end

function AutoDownloadModule.DEBUG_SET_WIFI_TYPE( debugMode, isWifi )
	AutoDownloadModule.DEBUG_MODE = not (not debugMode)
	AutoDownloadModule.DEBUG_NETWORK_WIFI = not (not isWifi)
	__Log("DEBUG_SET_WIFI_TYPE:debugMode:%d, network wifi:%d", debugMode and 1 or 0, isWifi and 1 or 0)
	if G_AutoDownloadModule then
		G_AutoDownloadModule:_doStartNetworkCheck()
	end
end

function AutoDownloadModule:startNetworkCheck( ... )
	if self._networkTimer or self._completeDownload then 
		return 
	end	

	__Log("-------------startNetworkCheck-------------")
	self._networkTimer = GlobalFunc.addTimer(5, handler(self, self._doStartNetworkCheck))
	G_Downloading.registerGlobalEvent(handler(self, self._onDownloadEvent))
	self:_onNetworkTypeChanged()
end

function AutoDownloadModule:stopNetworkCheck( ... )
	__Log("-------------stopNetworkCheck-------------")
	if self._networkTimer then 
		GlobalFunc.removeTimer(self._networkTimer)
		self._networkTimer = nil
	end
end

function AutoDownloadModule:_doStartNetworkCheck( ... )
	local isWifi = false
	if not AutoDownloadModule.DEBUG_MODE then
		local hasNetwork = G_NativeProxy.hasNetwork()
		if hasNetwork then 
			local networkType = G_NativeProxy.native_call("getCurNetworkType", nil, "int")
			if networkType == 1 then 
				isWifi = true
			end
		end
	else
		isWifi = AutoDownloadModule.DEBUG_NETWORK_WIFI
	end

	if (self._isWifiNetwork ~=  isWifi) then
		self._isWifiNetwork = not self._isWifiNetwork
		self:_onNetworkTypeChanged()
	end
end

function AutoDownloadModule:_onNetworkTypeChanged( ... )
	__Log("onNetworkTypeChanged: current is "..(self._isWifiNetwork and "exactly" or "not").." wifi network!")
    __Log("onNetworkTypeChanged: force mode:%d, force download:%d", self._isForceDownloadModel and 1 or 0, self._isForceDownload and 1 or 0)
	
	if self:isForceModel() then 
		if self:isForceDownloaded() then 
			self:_continueDownload()
		else
			self:pauseDownload()
		end
		return 
	end

	if self._isWifiNetwork then 
		self:autoStartWifiDownload()
	else
		self:pauseDownload()
	end
end

function AutoDownloadModule:_continueDownload( ... )
	self:_pushDownloadTask()

	self:_LogoutCurrentTaskStatus("_continueDownload")

	G_Downloading.startDownload()
end

function AutoDownloadModule:autoStartWifiDownload( ... )
	self:_continueDownload()
	uf_eventManager:dispatchEvent(AutoDownloadModule.DOWNLOAD_STATUS_EVENT, nil, false)
end

function AutoDownloadModule:pauseDownload( ... )
	G_Downloading.pauseDownload()
	uf_eventManager:dispatchEvent(AutoDownloadModule.DOWNLOAD_STATUS_EVENT, nil, false)
end

function AutoDownloadModule:stopDownload( ... )
	self:stopNetworkCheck()

	self._completeDownload = (#self._willDownloadFileList == 0) and (#self._downloadFailedList == 0) and (self._curDownloadTaskSize < 1)
	--self._completeDownload = true

	__Log("stopDownload: _completeDownload:%d", self._completeDownload and 1 or 0)
	uf_eventManager:dispatchEvent(AutoDownloadModule.DOWNLOAD_PROGRESS_UDPATE, nil, false, self:getCurDownloadProgress())
end

function AutoDownloadModule:_pushDownloadTask( ... )
	if self._curDownloadTaskSize >= AutoDownloadModule.DOWNLOAD_ARRAY_SIZE then 
		return 
	end

	if self:isForceModel() and not self:isForceDownloaded() then 
		return 
	elseif not self:isForceModel() and not self:isWifiNetwork() then 
		return 
	end

	local _addDownloadTask = function ( record )
		local wholeUrl = self._fileDownloadUrlPath..record.url 
		local savePath = AutoDownloadModule.LOCAL_DOWNLOAD_FOLDER..record.url
		G_Downloading.addDownloadTask(wholeUrl, savePath, record.md5, false)
		self._downloadingFileList[record.url] = record.md5
		self._curDownloadTaskSize = self._curDownloadTaskSize + 1
		table.remove(self._willDownloadFileList, 1)
	end

	local emptyArr = false
	repeat
		if #self._willDownloadFileList < 1 then 
			emptyArr = true
		end

		local firstRecord = self._willDownloadFileList[1]
		if firstRecord then 
			_addDownloadTask(firstRecord)
		end		
	until(self._curDownloadTaskSize >= AutoDownloadModule.DOWNLOAD_ARRAY_SIZE or emptyArr)
end

function AutoDownloadModule:_onDownloadEvent( eventId, fileUrl, filePath, ret, param1, param2 )
	if eventId == CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_SUCCESS then
		self:_onDownloadSuccess(fileUrl, filePath)
	elseif eventId == CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FAILED then
		self:_onDownloadFailed(fileUrl, filePath)
	elseif eventId == CommonDownloadHandler.DOWNLOAD_EVENT.DOWNLOAD_FINISH then
		self:_onDownloadFinish()
	end
end

function AutoDownloadModule:_onDownloadSuccess( fileUrl, filePath )
	if type(fileUrl) ~= "string" then 
		return 
	end

	local url = string.sub(fileUrl, #self._fileDownloadUrlPath + 1)
	local md5Value = self._downloadingFileList[url]
	self:_saveCompleteTask(url, md5Value)
	self._downloadingFileList[url] = nil
	self._curDownloadTaskSize = self._curDownloadTaskSize - 1

	self:_continueDownload()

	self:_updateDownloadProgress()

	if CCFileUtils:sharedFileUtils().removeFilePathCache then
		CCFileUtils:sharedFileUtils():removeFilePathCache(url)
	end
end

function AutoDownloadModule:_retryFailedFiles( ... )
	if #self._downloadFailedList < 1 or self._curRetryCount >= AutoDownloadModule.MAX_RETRY_COUNT then 
		self:stopDownload()
		return 
	end

	for key, value in pairs(self._downloadFailedList) do 
		table.insert(self._willDownloadFileList, #self._willDownloadFileList + 1, value)
	end

	self._downloadFailedList = {}
	self._curRetryCount = self._curRetryCount + 1
	__Log("_retryFailedFiles: file count=%d, retryCount=%d", #self._willDownloadFileList, self._curRetryCount)
	
	self:_continueDownload()
end

function AutoDownloadModule:_saveCompleteTask( url, md5 )
	local file = io.open(AutoDownloadModule.LOCAL_DOWNLOAD_FILE, "a+")
	if not file then 
		assert(0, "file "..AutoDownloadModule.LOCAL_DOWNLOAD_FILE.." is opened failed")
		return 
	end

	local content = string.format("%s,%s\n", url, md5)
	file:write(content)
	io.close(file)
end

function AutoDownloadModule:_onDownloadFailed( fileUrl, filePath, ret )
	if type(fileUrl) ~= "string" then 
		return 
	end

	local urlValue = string.sub(fileUrl, #self._fileDownloadUrlPath + 1)
	table.insert(self._downloadFailedList, #self._downloadFailedList + 1, {url=urlValue, md5=self._downloadingFileList[urlValue]})
	--self._downloadFailedList[urlValue] = self._downloadingFileList[urlValue]
	self._downloadingFileList[urlValue] = nil
	self._curDownloadTaskSize = self._curDownloadTaskSize - 1

	self:_continueDownload()
end

function AutoDownloadModule:_updateDownloadProgress( ... )
	local completeCount = self._totalPackTaskCount - #self._willDownloadFileList - #self._downloadFailedList - self._curDownloadTaskSize
	local curprogress = 0
	if self._totalPackTaskCount < 1 then 
		curprogress = 100
	else
		curprogress = 100*completeCount/self._totalPackTaskCount
		curprogress = curprogress - curprogress%1
	end

	if self._curDownloadProgress ~= curprogress then
		self._curDownloadProgress = curprogress
		self:_LogoutCurrentTaskStatus("_updateDownloadProgress", true)
		uf_eventManager:dispatchEvent(AutoDownloadModule.DOWNLOAD_PROGRESS_UDPATE, nil, false, curprogress)
	end
end

function AutoDownloadModule:_onDownloadFinish( ... )
	self:_LogoutCurrentTaskStatus("_onDownloadFinish")

	if #self._willDownloadFileList > 0 then
		self:_continueDownload()
	elseif #self._downloadFailedList > 0 then
		self:_retryFailedFiles()
	else
		self:stopDownload()
	end	
end

function AutoDownloadModule:_LogoutCurrentTaskStatus( tag, force )
	if 1 and not force  then 
		return 
	end
	local completeCount = self._totalPackTaskCount - #self._willDownloadFileList - #self._downloadFailedList - self._curDownloadTaskSize
	__Log("[%s]: curDownloadProgress=%d%% (success:%d, failed:%d, downloading:%d, stack:%d, total:%d)",
		 tag or "null-tag", self._curDownloadProgress, completeCount, #self._downloadFailedList, self._curDownloadTaskSize, #self._willDownloadFileList, self._totalPackTaskCount)
end

function AutoDownloadModule:getCurDownloadProgress( ... )
	return self._curDownloadProgress
end

function AutoDownloadModule:isWifiNetwork( ... )
	return self._isWifiNetwork
end

function AutoDownloadModule:setForceModel( download )
	self._isForceDownloadModel = true
	self._isForceDownload = not (not download)
	self._curRetryCount = 0
	self:stopNetworkCheck()
	self:_onNetworkTypeChanged()
end

function AutoDownloadModule:isForceModel( ... )
	return self._isForceDownloadModel
end

function AutoDownloadModule:isForceDownloaded( ... )
	return self._isForceDownload
end

function AutoDownloadModule:isDownloadComplete( ... )
	return self._completeDownload
end

function AutoDownloadModule:isDownloading( ... )
	__Log("isDownloadComplete:%d, isForceModel:%d, isForceDownloaded:%d, isWifi:%d",
		self:isDownloadComplete() and 1 or 0, self:isForceModel() and 1 or 0,self:isForceDownloaded() and 1 or 0,
		self:isWifiNetwork() and 1 or 0)
	if self:isDownloadComplete() then 
		return false
	end

	if self:isForceModel() then 
		return self:isForceDownloaded()
	end

	return self:isWifiNetwork() 
end

return AutoDownloadModule
