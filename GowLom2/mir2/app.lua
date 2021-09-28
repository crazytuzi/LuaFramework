local current = ...
local mir2 = class("mir2", cc.mvc.AppBase)
mir2.ctor = function (self)
	mir2.super.ctor(self)

	return 
end
mir2.run = function (self)
	sound.init()
	game.init()

	return 
end
mir2.onEnterBackground = function (self)
	if reConnectLogic then
		reConnectLogic:forceReConnect()
		print("mir2:onEnterBackground()")
	end

	return 
end
mir2.onEnterForeground = function (self)
	return 
end
mir2.call = function (self, str)
	print("mir2:call:" .. str)

	local dic = json.decode(str)

	if dic then
		local scene = display.getRunningScene()

		if scene and scene.phone_listenner then
			scene.phone_listenner(scene, dic.state, dic.number)
		end
	end

	return 
end
mir2.memoryWarning = function (self)
	luaBuglyLog(2, "mirys_buglylog", "mir2:memoryWarning")
	res.purgeCachedData()
	p2("error", "memoryWarning!!!!!!!!!!!!")

	return 
end

function app_phone_call(...)
	app:call(...)

	return 
end

function hotfix_app_phone_call_crash()
	app_phone_call = nil

	setmetatable(_G, {
		__index = function (t, name)
			if name == "app_phone_call" then
				luaReportException("hotfix_app_phone_call_crash", "__index app_phone_call", logMsg)
				os.exit(0)
			else
				return rawget(t, name)
			end

			return 
		end
	})

	return 
end

function app_memory_warning(...)
	app:memoryWarning(...)

	return 
end

function app_android_exit(...)
	an.newMsgbox("ÊÇ·ñÍË³öÓÎÏ·?", function (idx)
		if idx == 1 then
			os.exit(1)
		end

		return 
	end, {
		center = true,
		hasCancel = true
	})

	return 
end

function app_relogin_game(...)
	print("app_relogin_game")
	g_data.login:setSDKLogin(false)
	g_data.login:setEnterGameState(true)

	if main_scene then
		main_scene:clearGameData()
	end

	local common = import("mir2.scenes.main.common.common", current)

	common.gotoLogin()

	return 
end

return mir2
