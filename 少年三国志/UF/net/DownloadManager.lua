--DownloadManager.lua

local DownloadManager = class ("DownloadManager")


function DownloadManager:ctor() 
	self._downloadTask = {}
	self._defaultInstance = FileDownloadUtil:getInstance()
	self:registerDownloadHandler(self._defaultInstance)
end

function DownloadManager:registerDownloadHandler( instance )
	if instance.registerDownloadHandler ~= nil then
		instance:registerDownloadHandler(function ( event, ... )
			args = {...}
			if event == "download_success" then
				self:onFileDownloadSuccess(args[1], args[2], args[3])
			elseif event == "download_failed" then
				self:onFileDownloadFailed(args[1], args[2], args[3])
			elseif event == "download_finish" then
				self:onFileDownloadFinish(args[1])
			elseif event == "download_inerrupt" then
				self:onFileDownloadInterrupt(args[1])
			end
		end)
	end
end

function DownloadManager:onFileDownloadSuccess( ret, fileUrl, savePath )
	self:dispatchDownload(ret, fileUrl, savePath)
end

function DownloadManager:onFileDownloadFailed( ret, fileUrl, savePath )
	self:dispatchDownload(ret, fileUrl, savePath)
end

function DownloadManager:onFileDownloadFinish( instance )
	
end

function DownloadManager:onFileDownloadInterrupt( instance )
	
end

function DownloadManager:addDownloadTask( url, saveFolder, md5, unzip, func, target )
	if type(url) ~= "string" or type(saveFolder) ~= "string" then
		return 
	end

	if self._defaultInstance ~= nil and self:addCallbackPair(url, func, target) == 1 then 
		self._defaultInstance:addDownloadTask(url, saveFolder, md5, unzip)
	end
end

function DownloadManager:addCallbackPair( url, func, target )
	if type(url) ~= "string" then 
		return -1
	end

	if type(func) ~= "function" then 
		return 1
	end

	if self._downloadTask[url] == nil then
		self._downloadTask[url] = {{func, target}}
		return 1
	else
		table.insert(self._downloadTask[url], table.getn(self._downloadTask[url]) + 1, {func, target})
		return 0
	end
end

function DownloadManager:dispatchDownload( ret, url, path )
	if self._downloadTask[url] == nil then 
		return 
	end

	for k, v in ipairs(self._downloadTask[url]) do
		if type(v) == "table" then
			if v[1] ~= nil and v[2] ~= nil then 
				v[1](v[2], ret, url, path)
			elseif v[1] ~= nil then 
				v[1](ret, url, path)
			end
		end
	end
	self._downloadTask[url] = nil
end

return DownloadManager