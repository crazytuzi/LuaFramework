--[[
	@author     nan.zhang
	@date       Oct.23.2017
	@usage      阅文sdk IngameUI版本的具体实现, 与QYuewenSDK_IngameUI.cpp交互
]]

--[[
	QYuewenSDK_IngameUI_onRefreshValidateCode()
	QYuewenSDK_IngameUI_onValidateCode(validateCode)
	QYuewenSDK_IngameUI_onLogin(phoneNumber, password)
]]

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import ("..controllers.QNavigationController")

local _dialog = nil

function QYuewenSDK_IngameUI_login()
	-- QYuewenSDK_IngameUI_onLogin("13817027780", "phosphorus")
	if _dialog == nil then
		_dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG,
	            uiClass = "QUIDialogGameLoginYuewen" ,
	            options = {
	            	module = {
		            	onGetValidate = function(phoneNumber, password)
		            		QYuewenSDK_IngameUI_onLogin(phoneNumber, password)
		            	end,
		            	onLogin = function(validateCode)
		            		QYuewenSDK_IngameUI_onValidateCode(validateCode)
		            	end,
		            	onRefreshValide = function()
		            		QYuewenSDK_IngameUI_onRefreshValidateCode()
		            	end,
		            	onClose = function()
		            		_dialog = nil
		            	end,
	            	}
	            }})
	end
end

function QYuewenSDK_IngameUI_loginFinish()
	if _dialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		_dialog = nil
	end
end

function QYuewenSDK_IngameUI_displayValidateCode(validateCodeFilePath)
	if _dialog then
		_dialog:displayValidateCode(validateCodeFilePath)
	end
end

function QYuewenSDK_IngameUI_message(title, content)
	CCMessageBox(title or "", content or "")
end