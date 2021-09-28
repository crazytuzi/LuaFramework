local assetUpter = class("uptScene")

table.merge(assetUpter, {
	assetMgr,
	eventAssetManagerlistener,
	listener,
	hasNewVersion
})

assetUpter.maxRetryTimes = 30
assetUpter.ctor = function (self, versionManifest, storagePath)
	self._versionManifest = versionManifest
	self._storagePath = storagePath

	self.reset(self)

	return 
end
assetUpter.destroy = function (self)
	if self.assetMgr then
		self.assetMgr:release()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.eventAssetManagerlistener)

		self.assetMgr = nil
	end

	return 
end
assetUpter.reset = function (self, isRetry)
	self.destroy(self)

	self.errAssetCnt = 0
	local assetMgr = cc.AssetsManagerEx:create(self._versionManifest, self._storagePath)

	assetMgr.retain(assetMgr)

	self.assetMgr = assetMgr
	self.eventAssetManagerlistener = cc.EventListenerAssetsManagerEx:create(self.assetMgr, handler(self, self.onUpdateEvent))

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventAssetManagerlistener, 1)

	versionaUrl = self.assetMgr:getLocalManifest():getVersionFileUrl()
	projectUrl = self.assetMgr:getLocalManifest():getManifestFileUrl()
	packageUrl = self.assetMgr:getLocalManifest():getPackageUrl()

	print("assetUpter:reset versionaUrl---------------" .. versionaUrl)
	print("assetUpter:reset projectUrl---------------" .. projectUrl)
	print("assetUpter:reset packageUrl---------------" .. packageUrl)

	if UPT_AFTER_SEL_SERVER and isRetry and g_data.login.localLastSer.serverUptKey and g_data.login.localLastSer.serverUptKey ~= "" then
		self.setRemoteAddressWithKey(self, g_data.login.localLastSer.serverUptKey)
	end

	self.downloading = false
	self.downloadingFilesSize = {}
	self.downloadFileCnt = 0

	return 
end
assetUpter.checkUpt = function (self)
	self.assetMgr:checkUpdate()

	return 
end
assetUpter.startUpt = function (self)
	self.downloading = true

	self.assetMgr:update()

	return 
end
assetUpter.retryUptFaildAssets = function (self)
	self.assetMgr:downloadFailedAssets()

	return 
end
assetUpter.getCurVersion = function (self)
	return self.assetMgr:getLocalManifest():getVersion()
end
assetUpter.getRemoteVersion = function (self)
	local manifest = self.assetMgr:getRemoteManifest()

	if manifest then
		return manifest.getVersion(manifest)
	else
		return ""
	end

	return 
end
assetUpter.checkNative = function (self)
	local cur = string.split(self.getCurVersion(self), ".")
	local newVersion = self.getRemoteVersion(self)

	if newVersion == "" then
		print("没有更新服务器版本号")

		return false
	else
		local new = string.split(newVersion, ".")

		if tonumber(cur[2]) < tonumber(new[2]) then
			print("检测到大版本")

			return true
		end
	end

	return 
end
assetUpter.getDownloadingFilenames = function (self)
	return self.assetMgr:getDownloadingFilenames()
end
assetUpter.getDiffFileTotalSize = function (self)
	local manifest = self.assetMgr:getRemoteManifest()
	local downloading = self.assetMgr:getDownloadingFilenames()

	for k, v in ipairs(downloading) do
		if not self.downloadingFilesSize[v] then
			local sz = manifest.getAssetSize(manifest, v)
			self.downloadingFilesSize[v] = sz
		end

		self.downloadFileCnt = self.downloadFileCnt + 1
	end

	local totalSize = 0

	for k, v in pairs(self.downloadingFilesSize) do
		totalSize = totalSize + v
	end

	return totalSize
end
assetUpter.getDownloadSize = function (self)
	return self.assetMgr:getDownloadSize()
end
assetUpter.EventCode = {
	UPDATE_PROGRESSION = 5,
	ERROR_NO_LOCAL_MANIFEST = 0,
	ERROR_PARSE_MANIFEST = 2,
	UPDATE_FAILED = 9,
	UPDATE_FINISHED = 8,
	ERROR_DECOMPRESS = 10,
	ERROR_DOWNLOAD_MANIFEST = 1,
	ERROR_UPDATING = 7,
	ALREADY_UP_TO_DATE = 4,
	ASSET_UPDATED = 6,
	NEW_VERSION_FOUND = 3
}
assetUpter.AssetsManagerExStatic = {
	VERSION_ID = "@version",
	MANIFEST_ID = "@manifest"
}
assetUpter.onUpdateEvent = function (self, event)
	local eventCode = event

	if type(event) == "table" or type(event) == "userdata" then
		eventCode = event.getEventCode(event)
	else
		print(event)
	end

	local ok = false

	for k, v in pairs(assetUpter.EventCode) do
		if v == eventCode then
			print(k)

			break
		end
	end

	if eventCode == assetUpter.EventCode.ERROR_NO_LOCAL_MANIFEST then
		print("No local manifest file found. state: faild")
		self.listener:onAssetError(eventCode, event.getMessage(event))
	elseif eventCode == assetUpter.EventCode.ERROR_DOWNLOAD_MANIFEST or eventCode == assetUpter.EventCode.ERROR_PARSE_MANIFEST then
		print("Fail to download manifest file. state: faild, errorCode:" .. eventCode)
		self.listener:onAssetError(eventCode, event.getMessage(event), event.getCURLECode(event), event.getCURLMCode(event))
	elseif eventCode == assetUpter.EventCode.ERROR_DECOMPRESS then
		self.listener:onAssetError(eventCode, event.getMessage(event))
	elseif eventCode == assetUpter.EventCode.UPDATE_PROGRESSION or eventCode == assetUpter.EventCode.ASSET_UPDATED then
		local assetId = event.getAssetId(event)
		local percent = event.getPercent(event)
		local percentByFile = event.getPercentByFile(event)

		if assetId == assetUpter.AssetsManagerExStatic.VERSION_ID then
			print("Version file: %d%%", percent)
		elseif assetId == assetUpter.AssetsManagerExStatic.MANIFEST_ID then
			print(string.format("Manifest file: %d%%", percent))
		end

		self.listener:onAssetUpdating(eventCode, assetId, percent)
	elseif eventCode == assetUpter.EventCode.ALREADY_UP_TO_DATE or eventCode == assetUpter.EventCode.UPDATE_FINISHED then
		print("Update finished.", event.getAssetId(event), eventCode)
		self.listener:onAssetSuccess(eventCode, self.errAssetCnt)
	elseif eventCode == assetUpter.EventCode.ERROR_UPDATING or eventCode == assetUpter.EventCode.UPDATE_FAILED then
		print("Asset ", event.getAssetId(event), ", ", event.getMessage(event), event.getCURLECode(event), event.getCURLMCode(event))

		self.errAssetCnt = self.errAssetCnt + 1
		local retryTimes = self.downloadFileCnt

		if retryTimes <= 0 then
			retryTimes = assetUpter.maxRetryTimes
		end

		if self.errAssetCnt < retryTimes then
			self.retryUptFaildAssets(self)
			self.listener:onUpdatingError(eventCode, event.getMessage(event))
		else
			self.listener:onAssetError(eventCode, event.getMessage(event))
		end
	elseif eventCode == assetUpter.EventCode.NEW_VERSION_FOUND then
		if not self.downloading then
			self.listener:onAssetNewVersion(true)
		end

		self.hasNewVersion = true
	else
		print("unknow event:", eventCode)
	end

	return 
end

if 0 < DEBUG then
	assetUpter.salt = "yMnNhbHRkJTNha2Zq"
	assetUpter.setCachePath = function (self, storagePath, key)
		ycFunction:mkdir(storagePath)

		self.cachePath = storagePath .. crypto.encodeBase64("uptAssetUpter" .. key)

		return 
	end
	assetUpter.saveRemoteAddress = function (self, addr)
		local cache = crypto.encodeBase64(addr)
		local cache = crypto.encodeBase64(assetUpter.salt .. cache)
		local cache = crypto.encodeBase64(cache)

		io.writefile(self.cachePath, cache)

		return 
	end
	assetUpter.getFileServerAddr = function (self)
		local data = io.readfile(self.cachePath)

		if data then
			local cache = crypto.decodeBase64(data)
			local cache = crypto.decodeBase64(cache)
			local addr = string.sub(cache, string.len(assetUpter.salt) + 1)
			addr = crypto.decodeBase64(addr)

			return addr
		end

		return 
	end
	assetUpter.updateRemoteUrl = function (self)
		local addr = self.getFileServerAddr(self)

		if addr then
			self.setRemoteAddress(self, addr)
		end

		return 
	end
end

assetUpter.setRemoteAddress = function (self, addr)
	print("setRemoteAddress", addr)
	self.assetMgr:getLocalManifest():setRemoteAddress(addr)

	return 
end
assetUpter.setRemoteAddressWithKey = function (self, serverKey)
	print("setRemoteAddressWithKey", serverKey)

	local addr = self.assetMgr:getLocalManifest():getVersionFileUrl()
	addr = string.gsub(addr, "version.manifest", serverKey .. "/")

	print("setRemoteAddressWithKey", addr)
	self.assetMgr:getLocalManifest():setRemoteAddress(addr)

	if 0 < DEBUG then
		addr = self.assetMgr:getLocalManifest():getVersionFileUrl()

		print("getVersionFileUrl", addr)

		addr = self.assetMgr:getLocalManifest():getManifestFileUrl()

		print("getManifestFileUrl", addr)

		addr = self.assetMgr:getLocalManifest():getPackageUrl()

		print("getPackageUrl", addr)
	end

	return 
end
assetUpter.setRemoteAddressWithServerUrl = function (self, url)
	print("assetUpter:setRemoteAddressWithServerUrl url=", url)

	local versionServerUrl = self.assetMgr:getLocalManifest():getVersionFileUrl()

	print("assetUpter:setRemoteAddressWithServerUrl versionServerUrl=", versionServerUrl)

	local serverUrl = string.gsub(versionServerUrl, "version.manifest", "")

	print("assetUpter:setRemoteAddressWithServerUrl serverUrl=", serverUrl)

	local function genNewUptUrlWithServerUrl(oldUrl)
		local splitUrl = oldUrl
		local splitStr = "://"
		local s_start, s_end = string.find(splitUrl, splitStr)
		splitUrl = string.sub(splitUrl, s_end + 1)
		splitStr = "/"
		s_start, s_end = string.find(splitUrl, splitStr)
		local newUrl = nil
		local endUrl = ""

		if s_start ~= nil then
			endUrl = string.sub(splitUrl, s_start)
			newUrl = url .. endUrl
		end

		return newUrl
	end

	local newUrl = slot4(serverUrl)

	if newUrl == nil then
		print("assetUpter:setRemoteAddressWithServerUrl set url failed，serverUrl invalid! serverUrl = ", serverUrl)

		return 
	end

	print("assetUpter:setRemoteAddressWithServerUrl newUrl=", newUrl)
	self.assetMgr:getLocalManifest():setRemoteAddress(newUrl)

	if 0 < DEBUG then
		addr = self.assetMgr:getLocalManifest():getVersionFileUrl()

		print("getVersionFileUrl", addr)

		addr = self.assetMgr:getLocalManifest():getManifestFileUrl()

		print("getManifestFileUrl", addr)

		addr = self.assetMgr:getLocalManifest():getPackageUrl()

		print("getPackageUrl", addr)
	end

	return 
end
assetUpter.setListener = function (self, l)
	self.listener = l

	return 
end

return assetUpter
