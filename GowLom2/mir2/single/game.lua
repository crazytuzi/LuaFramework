import(".Protocols")

local current = ...
local game = {
	deviceInfo,
	loopBegin,
	sourceSize,
	deviceFix
}

function print_r(root)
	local cache = {
		[root] = "."
	}

	local function _dump(t, space, name)
		local temp = {}

		for k, v in pairs(t) do
			local key = tostring(k)

			if cache[v] then
				table.insert(temp, "+" .. key .. " {" .. cache[v] .. "}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key

				table.insert(temp, "+" .. key .. _dump(v, space .. ((next(t, k) and "|") or " ") .. string.rep(" ", #key), new_key))
			else
				table.insert(temp, "+" .. key .. " [" .. tostring(v) .. "]")
			end
		end

		return table.concat(temp, "\n" .. space)
	end

	print(slot2(root, "", ""))

	return 
end

game.init = function ()
	if device.platform == "ios" or device.platform == "android" then
		local fixSize = platformSdk:getUIFixSize()

		if fixSize then
			game.deviceFix = fixSize.x

			print("game.deviceFix = ", game.deviceFix)
		end
	end

	if NEED_LOAD_PROTOCOL then
		unRegisterLuaProtocols()
		RegisterLuaProtocols()
	else
		buildDefaultClientMessage()
	end

	game.sourceSize = display.size

	luaBuglyLog(2, "mirys_log", "res ver: " .. (MIR2_VERSION or 0) .. "  base ver: " .. (MIR2_VERSION_BASE or 0))

	local function filterMix(jsondata)
		local isMix = false
		local fileName = ""
		local mixName = ""
		local mixFiles = {}
		local suffixPat = ".mix"

		for k, v in pairs(jsondata.assets) do
			suffix = string.sub(k, string.len(k) - 3)

			if suffixPat == suffix then
				fileName = string.gsub(k, "res/data/", "")
				mixName = string.gsub(fileName, "%.mix", "")

				table.insert(mixFiles, mixName)
			end
		end

		return mixFiles
	end

	if MirMiniResDownMgr and MirMiniResDownMgr.getInstance(slot1).addAtlas then
		local str = io.readfile(cc.FileUtils:getInstance():fullPathForFilename("res/project.manifest"))
		local data = json.decode(str)
		local files = filterMix(data)

		print("=========MirMiniResDownMgr:getInstance().addAtlas===========")

		for k, v in ipairs(files) do
			MirMiniResDownMgr:getInstance():addAtlas(v)
			print("addAtlas:", v)
		end

		print("============================================================")
	end

	if MIR2_VERSION_BASE == "1.1.59.29024" or MIR2_VERSION_BASE == "1.1.58.28474" then
		hotfix_app_phone_call_crash()
	end

	if display.width < 960 then
		CONFIG_SCREEN_WIDTH = 960
		CONFIG_SCREEN_HEIGHT = 640
		local sharedDirector = cc.Director:getInstance()
		local glview = sharedDirector.getOpenGLView(sharedDirector)
		local size = glview.getFrameSize(glview)
		display.sizeInPixels = {
			width = size.width,
			height = size.height
		}
		local w = display.sizeInPixels.width
		local h = display.sizeInPixels.height
		local scaleX = w/CONFIG_SCREEN_WIDTH
		local scaleY = h/CONFIG_SCREEN_HEIGHT
		local scale = scaleX
		CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
		CONFIG_SCREEN_HEIGHT = h/scale

		glview.setDesignResolutionSize(glview, CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)

		local winSize = sharedDirector.getWinSize(sharedDirector)
		display.screenScale = 2
		display.contentScaleFactor = scale
		display.size = {
			width = winSize.width,
			height = winSize.height
		}
		display.width = display.size.width
		display.height = display.size.height
		display.cx = display.width/2
		display.cy = display.height/2
		display.c_left = -display.width/2
		display.c_right = display.width/2
		display.c_top = display.height/2
		display.c_bottom = -display.height/2
		display.left = 0
		display.right = display.width
		display.top = display.height
		display.bottom = 0
		display.widthInPixels = display.sizeInPixels.width
		display.heightInPixels = display.sizeInPixels.height

		printInfo(string.format("# CONFIG_SCREEN_AUTOSCALE      = %s", CONFIG_SCREEN_AUTOSCALE))
		printInfo(string.format("# CONFIG_SCREEN_WIDTH          = %0.2f", CONFIG_SCREEN_WIDTH))
		printInfo(string.format("# CONFIG_SCREEN_HEIGHT         = %0.2f", CONFIG_SCREEN_HEIGHT))
		printInfo(string.format("# display.widthInPixels        = %0.2f", display.widthInPixels))
		printInfo(string.format("# display.heightInPixels       = %0.2f", display.heightInPixels))
		printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
		printInfo(string.format("# display.width                = %0.2f", display.width))
		printInfo(string.format("# display.height               = %0.2f", display.height))
		printInfo(string.format("# display.cx                   = %0.2f", display.cx))
		printInfo(string.format("# display.cy                   = %0.2f", display.cy))
		printInfo(string.format("# display.left                 = %0.2f", display.left))
		printInfo(string.format("# display.right                = %0.2f", display.right))
		printInfo(string.format("# display.top                  = %0.2f", display.top))
		printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
		printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
		printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
		printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
		printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
		printInfo("#")
	end

	if device.platform == "mac" then
		luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
	end

	if device.platform == "android" then
		local ok = luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "startFilterConnectivityAction", {}, "()V")

		if not ok then
			p2("warnning", "startFilterConnectivityAction faild")
		end

		local ok = luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "startFilterBatteryAction", {}, "()V")

		if not ok then
			p2("warnning", "startFilterBatteryAction faild")
		end
	end

	_G.MAIN_LOOP_BEGIN = function ()
		game.loopBegin = socket.gettime()

		return 
	end

	if device.platform == "windows" then
		scheduler.scheduleUpdateGlobal(function ()
			_G.MAIN_LOOP_BEGIN()

			return 
		end)
	end

	cc.FileUtils.getInstance(slot1):purgeCachedEntries()
	math.randomseed(os.time())

	if 0 < DEBUG then
		cc.Director:getInstance():enableDebugdraw()
	end

	cc.Director:getInstance():setAnimationInterval(0.03333333333333333)

	if RES_DOWNLOAD_URL then
		MirAtlasDownMgr:getInstance():setResDownloadUrl(RES_DOWNLOAD_URL)
	end

	local atlasWritablePath = table.concat({
		MirPath:getWritablePath(),
		"mir_mini_client_dl",
		MirLaunch:getGamePath(),
		""
	}, device.directorySeparator)

	MirAtlasMgr:getInstance():setWritablePath(atlasWritablePath)
	print("MirAtlasMgr:setWritablePath:", atlasWritablePath)

	display.DEFAULT_TTF_FONT = def.font
	display.DEFAULT_TTF_FONT_SIZE = 16

	an.msgbox.init({
		title = "提示",
		btnAlignStyle = "center",
		inputListBgScale = 1,
		btny = 13,
		btnLabelSize = 18,
		contentLabelSize = 18,
		bg = res.gettex2("pic/common/msgbox.png"),
		confirm = res.gettex2("pic/common/btn20.png"),
		confirm2 = res.gettex2("pic/common/btn21.png"),
		confirmText = res.gettex2("pic/common/confirm.png"),
		cancel = res.gettex2("pic/common/btn20.png"),
		cancel2 = res.gettex2("pic/common/btn21.png"),
		cancelText = res.gettex2("pic/common/cancel.png"),
		close = res.gettex2("pic/common/close10.png"),
		close2 = res.gettex2("pic/common/close11.png"),
		titlepos = cc.p(210, 270),
		inputListBg = res.gettex2("pic/console/guessbg.png"),
		sound = sound.root .. "104" .. sound.suffix,
		content = {
			w = 370,
			h = 150,
			x = 25,
			y = 74
		},
		btnColor = def.colors.Cf0c896,
		btnSColor = def.colors.btn20s
	})
	an.voiceBubble.init({
		bg = {
			附近 = res.gettex2("pic/scale/msg1.png"),
			喊话 = res.gettex2("pic/scale/msg2.png"),
			组队 = res.gettex2("pic/scale/msg3.png"),
			行会 = res.gettex2("pic/scale/msg4.png"),
			私聊self = res.gettex2("pic/scale/msg5.png"),
			私聊 = res.gettex2("pic/scale/msg6.png"),
			default = res.gettex2("pic/scale/msg7.png")
		},
		hornAni = res.getani2("pic/voice/play%d.png", 1, 3, 0.2),
		loadingAni = res.getani2("pic/effect/loading/%d.png", 1, 12, 0.06),
		errTex = res.gettex2("pic/voice/err.png"),
		unreadTex = res.gettex2("pic/voice/unread.png")
	})
	cache.checkAll()

	if MirLaunch.onRestartLaunch then
		MirLaunch:onRestartLaunch(function ()
			res.purgeCachedData()
			m2spr.removeAllSchedule()
			an.label.removeAllSchedule()
			sound.stopMusic()
			sound.stopAllSounds()

			return 
		end)
	end

	local launchLogin = MirLaunch.login
	local zoneInfo = launchLogin.getSelectedZoneInfo(slot2)
	local zoneID = zoneInfo.id
	local auth = require("auth")

	def.setip(zoneInfo.ip, zoneID, "")

	g_data.player.smallExit = true

	g_data.login:loadCheckSvrCfg()
	g_data.login:setLocalLastServer(zoneInfo)

	g_data.login.zoneId = auth.zoneId
	g_data.login.sdk39UserId = auth.pUserId
	g_data.login.sdk39UserName = auth.pUserName

	g_data.login:setSelectServer(auth.ggip, auth.ggport, auth.sessionId)

	g_data.login.uptUrl = launchLogin.getUptUrl(launchLogin)
	g_data.login.serverTime = launchLogin.getServerTime(launchLogin)

	g_data.login:setWhiteList(launchLogin.getWhiteList(launchLogin))
	g_data.login:setSDKLogin(not MirSDKAgent:isInternalUserLogin())

	g_data.serConfig = auth.serConfig

	g_data.select:receiveRoles(auth.characterInfo)
	def.role.init()

	if zoneInfo.isCheckServer == 1 then
		game.gotoscene("select")
	else
		local scene = require("upt.scene").new(function ()
			MirLaunch:restartLaunch()

			return 
		end, false, function ()
			game.gotoscene("select")

			return 
		end)

		if g_data.login.uptUrl and g_data.login.uptUrl ~= "" then
			scene.setRemoteAddressWithServerUrl(slot6, g_data.login.uptUrl)
		end

		if g_data.login.localLastSer.serverUptKey and g_data.login.localLastSer.serverUptKey ~= "" then
			scene.setRemoteAddressWithKey(scene, g_data.login.localLastSer.serverUptKey)
		end

		display.replaceScene(scene)
	end

	return 
end
game.gotoscene = function (name, params, ...)
	local scene = import("..scenes." .. name .. ".scene", current).new(params)

	if game.currentScene ~= scene then
		cc.Director:getInstance():getEventDispatcher():dispatchNodeEvent("LuaNode_removeSelf", game.currentScene)
		display.replaceScene(scene, ...)

		game.currentScene = scene
	end

	return 
end
game.exitGame = function ()
	MirSDKAgent:exitGame(function ()
		an.newMsgbox("是否退出游戏?", function (idx)
			if idx == 1 then
				os.exit(1)
			end

			return 
		end, {
			center = true,
			hasCancel = true
		})

		return 
	end)

	return 
end

return game
