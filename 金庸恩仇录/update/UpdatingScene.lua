require("network.NetworkHelper")
require("constant.ZipLoader")
require("game.common")
require("lfs")
require("data.data_url")

local UpdatingScene = class("UpdatingScene", function ()
	return display.newScene("UpdatingScene")
end)

function UpdatingScene:onExit()
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function UpdatingScene:ctor(newVerID, url)
	local bgSprite = display.newSprite("jpg_bg/gamelogo.jpg")
	if display.widthInPixels / display.heightInPixels == 0.75 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
		bgSprite:setScale(0.9)
	elseif display.widthInPixels == 640 and display.heightInPixels == 960 then
		bgSprite:setPosition(display.cx, display.height * 0.55)
	else
		bgSprite:setPosition(display.cx, display.cy)
	end
	self:addChild(bgSprite)
	
	local label = ui.newTTFLabel({
	text = common:getLanguageString("@zhengzaigx"),
	align = ui.TEXT_ALIGN_CENTER,
	x = display.cx,
	y = display.cy,
	size = 26,
	font = "fonts/FZCuYuan-M03S.ttf"
	})
	self:addChild(label)
	
	self.label = ui.newTTFLabel({
	text = "",
	align = ui.TEXT_ALIGN_CENTER,
	x = display.cx,
	y = display.height * 0.35,
	size = 35
	})
	self:addChild(self.label)
	self:update(newVerID, url)
end

function UpdatingScene:getLenStr(len)
	local lenStr = ""
	if len > 1024 and len < 1048576 then
		lenStr = string.format("%dKB", len / 1024)
	elseif len < 1024 then
		lenStr = string.format("%dB", len)
	else
		lenStr = string.format("%.2fM", len / 1024 / 1024)
	end
	return lenStr
end

function UpdatingScene:refresh(curLen, maxLen)
	local curLenStr = self:getLenStr(curLen)
	local maxLenStr = self:getLenStr(maxLen)
	self._rootnode.percentLabel:setString(curLenStr)
	self._rootnode.maxLabel:setString("/" .. maxLenStr)
end


--更新[从网络下载更新资源]
function UpdatingScene:update(newVerID, url)
	local curLen = 0
	local maxLen = 0
	local respData = ""
	
	local function updateZIP()
		local updatePackage = {
		"config",
		"app.",
		"network.",
		"sdk.",
		"update.",
		"utility.",
		"data.",
		"game."
		}
		
		local tmpKey = {}
		for _, v in ipairs(updatePackage) do
			for k, _ in pairs(package.preload) do
				if string.find(k, v) then
					table.insert(tmpKey, k)
				end
			end
		end
		
		for _, v in ipairs(tmpKey) do
			package.preload[v] = nil
			package.loaded[v] = nil
		end
		
		if BIT_64 == 1 then
			ziploader("src/app64.zip")
			ziploader("src/sdk64.zip")
			ziploader("src/update64.zip")
			ziploader("src/utility64.zip")
			ziploader("src/network64.zip")
			ziploader("src/data64.zip")
			ziploader("src/game64.zip")
		else
			ziploader("src/app.zip")
			ziploader("src/sdk.zip")
			ziploader("src/update.zip")
			ziploader("src/utility.zip")
			ziploader("src/network.zip")
			ziploader("src/data.zip")
			ziploader("src/game.zip")
		end
		require("data.data_channelid")
	end
	
	local rootpath = cc.FileUtils:getInstance():getWritablePath() .. "updateres/"
	
	local function mkResDir(fileName)
		local path = ""
		local dirs = string.split(fileName, "/")
		path = table.concat(dirs, "/", 1, #dirs - 1)
		if io.exists(rootpath .. path) ~= true then
			path = ""
			for k, v in ipairs(dirs) do
				if k == #dirs then
					break
				end
				path = path .. v .. "/"
				if io.exists(rootpath .. path) ~= true then
					lfs.mkdir(rootpath .. path)
				end
			end
		end
	end
	
	local function saveNewRes()
		if io.exists(rootpath) ~= true then
			lfs.mkdir(rootpath)
		end
		local temp = rootpath .. "temp.zip"
		if io.exists(temp) then
			os.remove(temp)
		end
		io.writefile(temp, respData, "wb")
		local ret = cc.AssetsManagerEx:decompressZip(temp,"","src/app.zip")
		if (ret) then
			package.preload["app.dirs"] = nil
			package.loaded["app.dirs"] = nil
		end
		os.remove(temp)
		--[[
		if io.exists(rootpath) ~= true then
			lfs.mkdir(rootpath)
		end
		if io.exists(rootpath .. "game/") ~= true then
			lfs.mkdir(rootpath .. "game/")
		end
		local fileInfo = gamecommon.unzipbuff(respData, string.len(respData))
		for _, v in ipairs(fileInfo) do
			if string.find(v.name, "game/app.zip") then
				io.writefile(rootpath .. v.name, v.buff, "wb")
				package.preload["app.dirs"] = nil
				package.loaded["app.dirs"] = nil
				break
			end
		end
		mkResDir()
		for k, v in ipairs(fileInfo) do
			mkGameDir(v.name)
			io.writefile(rootpath .. v.name, v.buff, "wb")
		end
		]]
	end
	
	--请求成功
	local function onSuccess()
		saveNewRes()
		updateZIP()
		saveversion(newVerID)
		local versionUrl = NewServerInfo.VERSION_URL
		if VERSION_CHECK_DEBUG == true then
			versionUrl = NewServerInfo.DEV_VERSION_URL
		end
		NetworkHelper.request(versionUrl, {
		ac = "dwsuf",
		channel = "",
		package = CSDKShell.GetBoundleID(),
		version = getlocalversion(),
		packType = PackType,
		packetTag = PacketTag,
		os = device.platform
		},
		function (data)
		end,
		"GET")
		self:refresh(curLen, maxLen)
		show_tip_label(common:getLanguageString("@gengxincg"))
		self:performWithDelay(function ()
			CCTextureCache:sharedTextureCache():removeAllTextures()
			local scene = require("app.scenes.VersionCheckScene").new()
			display.replaceScene(scene, "fade", 0.5)
		end,
		1)
	end
	
	--更新失败
	local function onFailed()
		show_tip_label(common:getLanguageString("@wangluocw1"))
		self:performWithDelay(function ()
			local scene = require("app.scenes.VersionCheckScene").new()
			display.replaceScene(scene, "fade", 0.5)
		end,
		1)
	end
	self:removeChildByTag(100)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("public/loading.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	node:setTag(100)
	local sz = self._rootnode.loadingBar:getContentSize()
	local loadingBar = display.newSprite("ui_common/common_loading_tiao.png")
	loadingBar:setTextureRect(cc.rect(0, 0, 0, sz.height))
	local _, posY = self._rootnode.loadingBar:getPosition()
	loadingBar:setAnchorPoint(cc.p(0, 0.5))
	loadingBar:setPosition(display.cx - sz.width / 2, posY)
	node:addChild(loadingBar)
	
	--正在更新
	local function onProgress()
		loadingBar:setTextureRect(cc.rect(0, 0, sz.width * (curLen / maxLen), sz.height))
		if self._rootnode.animNode:getPositionX() < sz.width * (curLen / maxLen) then
			self._rootnode.animNode:setPositionX(sz.width * (curLen / maxLen))
		end
		self:refresh(curLen, maxLen)
	end
	
	local function downloadFromServer(downurl)
		NetworkHelper.download(downurl,
		function (data)
			--dump(data)
			if data.name == "progress" then
				curLen = data.dltotal
				maxLen = data.total
				onProgress()
			elseif data.name == "completed" then
				if data.request:getResponseStatusCode() ~= 200 then
					if math.floor(data.request:getResponseStatusCode() / 100) == 3 then
						local tmpUrl
						local headers = string.split(data.request:getResponseHeadersString(), "\r\n")
						for k, v in ipairs(headers) do
							local i, j = string.find(v, "Location: ")
							if i and j then
								tmpUrl = string.sub(v, j + 1)
								break
							end
						end
						if tmpUrl then
							downloadFromServer(tmpUrl)
						end
					else
						onFailed()
					end
				else
					local realLen = data.request:getResponseDataLength()
					curLen = realLen
					maxLen = realLen
					respData = data.request:getResponseData()
					onSuccess()
				end
			elseif data.name == "failed" then
				print("update failed:" .. data.request:getErrorMessage())
				onFailed()
			end
		end,
		"GET")
	end
	downloadFromServer(url)
end

return UpdatingScene