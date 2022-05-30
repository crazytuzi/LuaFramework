require("config")
require("framework.init")
require("cocos.init")
--require("data.data_debug")
--require("data.data_channelid")
--require("constant.version")
--require("app.init")
require("app.config")
--require("constant.url")
--require("utility.Func")

common = require("game.common")
local MyApp = class("MyApp", cc.mvc.AppBase)
local GameDevice = require("sdk.GameDevice")
local data_msg_push_msg_push = require("data.data_msg_push_msg_push")
GameState = require(cc.PACKAGE_NAME .. ".cc.utils.GameState")

function MyApp:ctor()
	MyApp.super.ctor(self)
	if device.platform ~= "ios" then
		local eventListen = function (param)
			local returnValue = {}
			if param.errorCode then
				dump("读取存储文件失败error:" .. param.errorCode)
			elseif param.name == "save" then
				dump("save:")
				returnValue = param.values
			elseif param.name == "load" then
				dump("load:")
				returnValue = param.values
			end
			return returnValue
		end
		GameState.init(eventListen, "chatData.txt")
	end
	self:addEventListener(self.APP_ENTER_FOREGROUND_EVENT, handler(self, MyApp.onGameEnterForeground))
	self:addEventListener(self.APP_ENTER_BACKGROUND_EVENT, handler(self, MyApp.onGameEnterBackground))
end

function MyApp:run()
	print("------------------->MyApp:run()--------------------")
	--for _, v in ipairs(SearchPath) do
	--	cc.FileUtils:getInstance():addSearchPath(v)
	--end
	self:enterScene("LogoScene")
end

function MyApp:onGameEnterForeground(event)
	print("------------------->MyApp:onEnterForeground()--------------------")
	PostNotice("APP_ENTER_FOREGROUND_EVENT_IN_GAME")
	if device.platform ~= "ios" then
		GameDevice.CancelAllNotifications()
	end
	appState = APP_STATE.STATE_FOREGROUND
end

function MyApp:onGameEnterBackground(event)
	print("------------------->MyApp:onEnterBackground()--------------------")
	if device.platform ~= "ios" then
		self:RestNotification()
	end
	appState = APP_STATE.STATE_BACKGROUND
end

function MyApp:RestNotification()
	GameDevice.CancelAllNotifications()
	for k, v in pairs(data_msg_push_msg_push) do
		local time_table = os.date("*t")
		time_table.hour = v.time - 1
		time_table.min = 60 - v.shift
		local dur = os.time(time_table) - os.time()
		if dur > 0 then
			--dump(dur)
			GameDevice.AddNotification({
			dt = dur,
			cont = v.text,
			bt_txt = common:getLanguageString("@OK")
			})
		else
			dur = os.time(time_table) + 86400 - os.time()
			GameDevice.AddNotification({
			dt = dur,
			cont = v.text,
			bt_txt = common:getLanguageString("@OK")
			})
		end
	end
end

return MyApp