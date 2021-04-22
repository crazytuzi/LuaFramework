--[[	
	QBackdoor.lua
	创建时间：2016-03-02 16:20:44
	作者：qinyuanji
	描述：程序后门处理函数
]]

local QBackdoor = class("QBackdoor")
local QLogFile = import("..utils.QLogFile")

local BACKDOOR = "BACKDOOR_PUSH"
local APP_LOGOUT = "APP_LOGOUT"
local APP_RESTART = "APP_RESTART"

function QBackdoor:ctor()
    app:getClient():pushReqRegister(BACKDOOR, 
    	handler(self, self.backdoorHandler))
    app:getClient():pushReqRegister(APP_LOGOUT, 
    	handler(self, self.appLogout))
    app:getClient():pushReqRegister(APP_RESTART, 
    	handler(self, self.appRestart))
end

function QBackdoor:close( ... )
	app:getClient():pushReqUnregister(BACKDOOR)
	app:getClient():pushReqUnregister(APP_LOGOUT)
	app:getClient():pushReqUnregister(APP_RESTART)
end

--[[
Sample: 
-- app:logout() 游戏注销
-- app:alert({content=\"弹出对话框\", title=\"系统提示\"}) 弹出对话框
-- local QUIViewController = import(\"..ui.QUIViewController\") \
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = \"QUIDialogMail\"}) 打开特定对话框
-- app:getClient():getRechargetHistory() 向服务器发送请求
]]
function QBackdoor:backdoorHandler(data)
	assert(data.sendBackDoorMessageResponse, "Back door push request has no script to execute")

	local f, err = loadstring(data.sendBackDoorMessageResponse.str)
	if not err then
		pcall(f)
		QLogFile:debug(function ( ... )
			return string.format("Execute backdoor script successfully. Script: %s", data.sendBackDoorMessageResponse.str)
		end)
	else
		QLogFile:error(function ( ... )
			return string.format("Failed to execute backdoor script. Error %s, Script: %s", err, data.sendBackDoorMessageResponse.str)
		end)
	end
end

function QBackdoor:appLogout()
	app:logout()
end

function QBackdoor:appRestart()
	app:relaunchGame(true)
end

return {new = QBackdoor.new}