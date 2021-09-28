local lfs = require("lfs")
local def = import(".def")
local assetUpter = import(".assetUpter")
local msgbox = import(".msgbox")
local scene = class("upt", function ()
	return display.newScene("upt")
end)
local socket = require("socket")
local scheduler = require("framework.scheduler")

table.merge(slot4, {
	endFunc,
	skipFunc,
	newVerConfig,
	tasks,
	curBytes,
	allBytes,
	errCount,
	layer,
	bar,
	text,
	newVer,
	hasNewVersion = false
})

scene.storagePath = device.writablePath
scene.packageManifest = "project.manifest"
scene.ctor = function (self, endFunc, force, skipFunc)
	g_data.login:setLoginState(GameStateType.upt)
	self.checkResourceVersion(self)

	self.force = force
	self.skipFunc = skipFunc or endFunc
	local n = display.newColorLayer(cc.c4b(255, 255, 255, 255)):size(display.width, display.height):addTo(self)

	n.setLocalZOrder(n, 99999999)
	n.setTouchSwallowEnabled(n, true)
	n.setTouchEnabled(n, true)
	n.setCascadeOpacityEnabled(n, true)
	n.addNodeEventListener(n, cc.NODE_TOUCH_EVENT, function ()
		return true
	end)

	local function copyResCallback()
		n:removeAllNodeEventListeners()
		n:removeSelf()

		if device.platform == "android" and self.copyRes then
			print("安卓拷资源出来")
		end

		return 
	end

	local function uptAnimCallback()
		local bg = self.bg

		display.newSprite("public/smoke/0_00000.png"):addTo(bg):pos(bg.getContentSize(bg).width/2 - 325, 335)
		display.newSprite("public/hero/0_00000.png"):addTo(bg):pos(bg.getContentSize(bg).width/2 + 89, 270):scale(0.88)
		display.newSprite("public/patricle/0_00000.png"):addTo(bg):pos(bg.getContentSize(bg).width/2 + 224, 237):setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR)
		display.newSprite("public/fire/0_00000.png"):addTo(bg):pos(bg.getContentSize(bg).width/2 + 15, 70):setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR)

		return 
	end

	local function endFuncCallback()
		scheduler.performWithDelayGlobal(self.skipFunc, 0)

		return 
	end

	local function uptCallback()
		scheduler.performWithDelayGlobal(function ()
			if SKIP_UPT and not self.force then
				print("upt/scene: 由于配置跳过了更新 ")
				n:stopAllActions()
				endFuncCallback()
			else
				n:runAction(cca.seq({
					cca.callFunc(uptAnimCallback),
					cca.callFunc(copyResCallback)
				}))
			end

			return 
		end, 0)

		return 
	end

	local function initAssetUpter()
		self.endFunc = endFunc
		self.assetUpter = assetUpter.new(scene.packageManifest, scene.storagePath)

		self.assetUpter:setListener(self)

		if 0 < DEBUG then
			self.assetUpter:setCachePath(scene.storagePath, "globalUpdate")
			self.assetUpter:updateRemoteUrl()
		end

		return 
	end

	slot9()

	if ALWAYS_PLAY_LOGO then
		print("播放下logo")
		bg1:runAction(cca.seq({
			cca.fadeIn(1),
			cca.delay(1),
			cca.fadeOut(1),
			cca.callFunc(function ()
				return 
			end)
		}))
	else
		slot8()
	end

	if SKIP_UPT and not self.force then
		return 
	end

	self.layer = display.newNode():addTo(self)
	local bg = display.newSprite("public/uptbg.png"):addTo(self.layer):center()
	self.bg = bg

	display.newSprite("public/p1.png", bg.getContentSize(bg).width/2, 64):addTo(bg):setLocalZOrder(1)

	self.bar = display.newSprite("public/progress/0_00000.png", bg.getContentSize(bg).width/2 - 319, 64):addTo(bg)

	self.bar:setLocalZOrder(1)
	self.bar:setAnchorPoint(cc.p(0, 0.5))

	local curVer = display.newTTFLabel({
		y = 630,
		size = 20,
		x = 5,
		text = "当前版本: " .. self.assetUpter:getCurVersion(),
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	curVer.setAnchorPoint(curVer, cc.p(0, 1))

	self.curVer = curVer
	self.newVer = display.newTTFLabel({
		text = "",
		y = 600,
		size = 20,
		x = 5,
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	self.newVer:setAnchorPoint(cc.p(0, 1))

	self.text = display.newTTFLabel({
		text = "",
		y = 120,
		size = 20,
		color = cc.c3b(222, 222, 150),
		x = display.cx
	}):addTo(self.layer)
	self.err = display.newTTFLabel({
		text = "",
		y = 570,
		size = 20,
		x = 5,
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	self.err:setAnchorPoint(cc.p(0, 1))

	return 
end
scene.saveRemoteAddress = function (self, addr)
	self.assetUpter:saveRemoteAddress(addr)

	return 
end
scene.setRemoteAddressWithKey = function (self, serverKey)
	self.assetUpter:setRemoteAddressWithKey(serverKey)

	return 
end
scene.setRemoteAddressWithServerUrl = function (self, serverUrl)
	self.assetUpter:setRemoteAddressWithServerUrl(serverUrl)

	return 
end
scene.playAni = function (self, parent, pattern, frame, delay, blend, isProg)
	if not parent or not pattern then
		return 
	end

	local texs = {}
	local textureCache = cc.Director:getInstance():getTextureCache()

	for i = 1, frame, 1 do
		local index = i

		textureCache.addImageAsync(textureCache, string.format(pattern .. "0_%05d.png", i - 1), function (tex)
			if tex then
				texs[index] = tex
			end

			return 
		end)
	end

	local texIdx = 1
	local sprite = display.newSprite(string.format(slot2 .. "0_%05d.png", 1)):addTo(parent)

	local function uptBlendFunc()
		if blend then
			sprite:setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR)
		end

		return 
	end

	slot11()
	sprite.addNodeEventListener(sprite, cc.NODE_ENTER_FRAME_EVENT, function (dt)
		if sprite.lasttime then
			local nowtime = socket.gettime()

			if (delay or 0.3) <= nowtime - sprite.lasttime then
				sprite.lasttime = nowtime
				texIdx = texIdx + 1
				texIdx = (frame < texIdx and 1) or texIdx

				if texs[texIdx] then
					sprite:setTexture(texs[texIdx])
				end

				uptBlendFunc()
			end
		else
			sprite.lasttime = socket.gettime()
		end

		return 
	end)
	sprite.scheduleUpdate(slot10)

	return sprite
end
scene.onAssetError = function (self, code, msg, curle, curlm)
	if 0 < DEBUG then
		local errorStr = code .. "--" .. (msg or "") .. "--" .. (curle or "") .. "--" .. (curlm or "")

		self.setTitle(self, errorStr)
	end

	local errMsg = ""

	if code == assetUpter.EventCode.ERROR_NO_LOCAL_MANIFEST then
		self.setTitle(self, "获取本地资源信息失败")

		errMsg = "ERROR_NO_LOCAL_MANIFEST"
	elseif code == assetUpter.EventCode.ERROR_DOWNLOAD_MANIFEST or code == assetUpter.EventCode.ERROR_PARSE_MANIFEST then
		local box = nil
		local str = "获取版本信息失败, 请检查网络连接, 是否重试? "

		if 0 < DEBUG then
			str = str .. "\n(当前为调试版本,取消可跳过更新.)"
		end

		slot8 = msgbox.new(str, function (isRetry)
			if isRetry then
				self.assetUpter:reset(isRetry)
				self.assetUpter:checkUpt()
				box:removeSelf()

				errMsg = "MANIFEST_ERROR, retry update now"
			elseif 0 < DEBUG then
				self.skipFunc()
			else
				errMsg = "MANIFEST_ERROR, exit"

				os.exit(0)
			end

			return 
		end)
		box = slot8

		return 
	elseif code == assetUpter.EventCode.ERROR_UPDATING or code == assetUpter.EventCode.UPDATE_FAILED then
		local box = nil
		slot7 = msgbox.new("网络状态不佳或远程服务器繁忙, 是否重试? ", function (isRetry)
			if isRetry then
				self.assetUpter:reset(isRetry)
				self.assetUpter:checkUpt()
				box:removeSelf()

				errMsg = "DOWNLOAD_RES_FAILED, retry update now"
			else
				errMsg = "DOWNLOAD_RES_FAILED, exit"

				os.exit(0)
			end

			return 
		end)
		box = slot7

		return 
	else
		msgbox.new(string.format("网络异常 error :%s. %d,%d", msg or "update faild", curle or -1, curlm or -1), function (b)
			errMsg = "unknown update error"

			os.exit(0)

			return 
		end)
	end

	local logMsg = "ver_new: " .. self.assetUpter.getRemoteVersion(slot7)

	luaReportException("update failed", errMsg, logMsg)

	return 
end
scene.onAssetUpdating = function (self, eventCode, assetId, percent)
	if assetId == assetUpter.AssetsManagerExStatic.VERSION_ID then
		self.setTitle(self, string.format("获取最新版本信息... %d%%", percent - 100))
	elseif assetId == assetUpter.AssetsManagerExStatic.MANIFEST_ID then
		self.setTitle(self, string.format("获取本地版本信息... %d%%", percent - 100))
		self.setProgress(self, percent - 100)
	else
		self.allBytes = self.assetUpter:getDiffFileTotalSize() or 0
		local downloaded = self.assetUpter:getDownloadSize()

		self.setTitle(self, string.format("下载中... %s / %s", self.fileSizeFormat(self, downloaded), self.fileSizeFormat(self, self.allBytes or 0)))
		self.setProgress(self, downloaded/self.allBytes*100)
	end

	return 
end
scene.onUpdatingError = function (self, eventCode, msg)
	local downloaded = self.assetUpter:getDownloadSize()
	local str = string.format("下载异常,重试中...当前已下载: %s / %s", self.fileSizeFormat(self, downloaded), self.fileSizeFormat(self, self.allBytes or 0))

	if 0 < DEBUG then
		str = str .. " -eventCode: " .. eventCode or " " .. " -eventMsg: " .. msg or " "
	end

	self.setTitle(self, str)

	return 
end
scene.onAssetSuccess = function (self, eventCode, errCnt)
	self.setProgress(self, 100)

	if assetUpter.EventCode.UPDATE_FINISHED == eventCode then
		if self.assetUpter.hasNewVersion then
			self.setTitle(self, string.format("更新 %s / %s", self.fileSizeFormat(self, self.allBytes or 0), self.fileSizeFormat(self, self.allBytes or 0)))
			self.downloadEnd(self)

			MIR2_UPT_VERSION = self.assetUpter:getRemoteVersion()

			if self.endFunc then
				self.endFunc()
				print("scene:onAssetSuccess: 更新成功了重启lua")
			else
				self.skipCheck = true

				print("scene:onAssetSuccess: 更新成功了但是没有endfunc")
			end
		else
			print("scene:onAssetSuccess: 更新完成但其实并没有新版本")
		end
	elseif assetUpter.EventCode.ALREADY_UP_TO_DATE == eventCode then
		self.skipFunc()
		print("scene:onAssetSuccess: 已经是最新版本直接进游戏")
	else
		print("scene:onAssetSuccess: 更新未完成")
	end

	return 
end
scene.getLoginSdk = function (self)
	local curLoginSdk = 1
	local pu_ret, pu = pcall(function ()
		return PlatformUtils:getInstance()
	end)

	if pu_ret and pu ~= nil then
		pu_ret, slot5 = pcall(function ()
			return pu:getLoginSdk()
		end)
		curLoginSdk = slot5

		if pu_ret == false then
			curLoginSdk = 1
		end
	end

	return curLoginSdk
end

local function compareVersion(ver1, ver2)
	verArr1 = string.split(ver1, ".")
	verArr2 = string.split(ver2, ".")
	local flag = nil

	if tonumber(verArr2[1]) < tonumber(verArr1[1]) then
		flag = 1
	elseif tonumber(verArr1[1]) < tonumber(verArr2[1]) then
		flag = -1
	elseif tonumber(verArr2[2]) < tonumber(verArr1[2]) then
		flag = 1
	elseif tonumber(verArr1[2]) < tonumber(verArr2[2]) then
		flag = -1
	elseif tonumber(verArr2[3]) < tonumber(verArr1[3]) then
		flag = 1
	elseif tonumber(verArr1[3]) < tonumber(verArr2[3]) then
		flag = -1
	elseif tonumber(verArr2[4]) < tonumber(verArr1[4]) then
		flag = 1
	elseif tonumber(verArr1[4]) < tonumber(verArr2[4]) then
		flag = -1
	else
		flag = 0
	end

	return flag
end

scene.onAssetNewVersion = function (self, newVersionFound)
	local baseVersion = MIR2_VERSION_BASE
	local newVersion = self.assetUpter:getRemoteVersion()
	local flagbase = compareVersion(newVersion, baseVersion)
	local flagcur = compareVersion(MIR2_VERSION, baseVersion)

	if newVersionFound and flagbase < 0 then
		newVersionFound = false

		print("base ver is larger than server ver!")
	end

	self.hasNewVersion = newVersionFound
	local box = nil

	if newVersionFound then
		local str = "有新版本,是否更新?"
		local skip = self.assetUpter:checkNative()

		if skip then
			str = "(*)存在大版本更新，请重新安装最新版本客户端."
		end

		if 0 < DEBUG then
			str = str .. "\n(当前为调试版本,取消可跳过更新.)"
		end

		slot9 = msgbox.new(str, function (isOk)
			if isOk then
				if skip then
					if self:getLoginSdk() == 1 and device.platform == "ios" then
						device.openURL("https://itunes.apple.com/cn/app/id1347643792?mt=8")
						os.exit(0)

						return 
					else
						os.exit(0)

						return 
					end
				end

				self.assetUpter:startUpt()

				self.allBytes = self.assetUpter:getDiffFileTotalSize() or 0

				self:setTitle("更新 0 / " .. self:fileSizeFormat(self.allBytes))
			elseif 0 < DEBUG then
				self.skipFunc()
			else
				os.exit(0)
			end

			box:removeSelf()

			return 
		end)
		box = slot9

		self.newVer:setString("最新版本: " .. self.assetUpter:getRemoteVersion())

		return 
	end

	self.skipFunc()
end
scene.onCleanup = function (self)
	if self.assetUpter then
		self.assetUpter:destroy()
	end

	return 
end
scene.checkUpt = function (self)
	self.setProgress(self, 0)
	self.setTitle(self, "获取版本信息...")
	self.assetUpter:checkUpt()

	return 
end
scene.onEnter = function (self)
	if not io.exists(device.writablePath .. "res/") then
		ycFunction:mkdir(device.writablePath .. "res/")
	end

	if SKIP_UPT and not self.force then
		return 
	end

	self.checkUpt(self)

	return 
end
scene.onExit = function (self)
	return 
end
scene.removeOldRes = function (self)
	print("login", "################## REMOVE OLE RESOURCE ##################")
	self.rmdir(self, scene.storagePath)
	cc.FileUtils:getInstance():purgeCachedEntries()

	MIR2_VERSION = MIR2_VERSION_BASE

	return 
end
scene.checkResourceVersion = function (self)
	local function getManifestVersion(manifestPath)
		local str = io.readfile(cc.FileUtils:getInstance():fullPathForFilename(manifestPath))
		local data = json.decode(str)

		return data and data.version
	end

	MIR2_VERSION_BASE = slot1("res/project.manifest")
	local versionPath = scene.storagePath .. "project.manifest"

	if cc.FileUtils:getInstance():isFileExist(versionPath) then
		MIR2_VERSION = getManifestVersion(versionPath)

		print("login", "Current Version:", MIR2_VERSION, "Base Version:", MIR2_VERSION_BASE, versionPath)
		self.checkRemoveOldRes(self)
	else
		MIR2_VERSION = MIR2_VERSION_BASE
	end

	return 
end
scene.checkRemoveOldRes = function (self)
	local base = string.split(MIR2_VERSION_BASE, ".")
	local cur = string.split(MIR2_VERSION, ".")

	if #base ~= 4 or #cur ~= 4 then
		return 
	end

	for i = 1, 4, 1 do
		local b = tonumber(base[i])
		local c = tonumber(cur[i])

		if b and c then
			if c < b then
				return self.removeOldRes(self)
			elseif b < c then
				return 
			end
		end
	end

	return 
end
scene.setProgress = function (self, progress)
	progress = math.min(math.max(progress, 0), 100)
	progress = progress/100

	self.bar:setTextureRect(cc.rect(0, 0, progress*self.bar:getTexture():getContentSize().width, self.bar:getContentSize().height))

	return 
end
scene.setTitle = function (self, text)
	self.text:setString(text)

	return 
end
scene.downloadEnd = function (self)
	MIR2_VERSION = self.assetUpter:getCurVersion()
	local fileUtils = cc.FileUtils:getInstance()

	print("downloadEnd", MIR2_VERSION, fileUtils.isDirectoryExist(fileUtils, scene.storagePath .. "rs"))

	if fileUtils.isDirectoryExist(fileUtils, scene.storagePath .. "rs") then
		if not fileUtils.isDirectoryExist(fileUtils, scene.storagePath .. "upt") then
			fileUtils.createDirectory(fileUtils, scene.storagePath .. "upt/")
		end

		if not fileUtils.isDirectoryExist(fileUtils, scene.storagePath .. "res") then
			fileUtils.createDirectory(fileUtils, scene.storagePath .. "res/")
		end

		local outpath = scene.storagePath .. "upt/rs.zip"
		local res = ycRes:create(1, "rs", "rs.zip", "")

		res.addFiles2NewPack(res, scene.storagePath .. "rs", outpath, MIR2_VERSION)
		ycRes:release(res)

		local data = ycFunction:getFileData(outpath, false)

		io.writefile(scene.storagePath .. "res/rs.zip", data, "w+b")
		self.setProgress(self, 100)
		fileUtils.removeDirectory(fileUtils, scene.storagePath .. "rs/")
		fileUtils.removeDirectory(fileUtils, scene.storagePath .. "upt/")
	end

	return 
end
scene.rmdir = function (self, path)
	print("rmdir - ", path)

	if io.exists(path) then
		local function _rmdir(path)
			local iter, dir_obj = lfs.dir(path)

			while true do
				local dir = iter(dir_obj)

				if dir == nil then
					break
				end

				xpcall(function ()
					if dir ~= "." and dir ~= ".." and dir ~= "" then
						local curDir = path .. dir
						local mode = lfs.attributes(curDir, "mode")

						print(mode, curDir)

						if mode == "directory" then
							_rmdir(curDir .. "/")
						elseif mode == "file" and curDir ~= "" then
							os.remove(curDir)
						end
					end

					return 
				end, function (err)
					print("err", err)

					return 
				end)
			end

			local succ, des = os.remove(lfs)

			if des then
				print(des)
			end

			return succ
		end

		slot2(path)
	end

	return true
end
scene.fileSizeFormat = function (self, size)
	size = size or 0

	if size < 1048576 then
		return string.format("%.2f", size/1024) .. "KB"
	end

	return string.format("%.2f", size/1024/1024) .. "MB"
end

return scene
