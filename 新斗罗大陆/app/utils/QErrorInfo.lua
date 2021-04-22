--
-- Author: wkwang
-- Date: 2014-07-24 17:33:46
--
local QErrorInfo = class("QErrorInfo")

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QUIDialogStoreDetail = import("..ui.dialogs.QUIDialogStoreDetail")
local QQuickWay = import("..utils.QQuickWay")

QErrorInfo.ERRORS={}
QErrorInfo.ERRORS["C_ERROR_UPDATE_INDEX_NOT_FOUND"] = {desc = "下载的文件有误", errorCode = 10001, isAlert = true}
QErrorInfo.ERRORS["C_ERROR_UPDATE_DOWNLOAD"] = {desc = "下载的文件有误", errorCode = 10001, isAlert = true}

function QErrorInfo:handleLocalError(code)
	local errorInfo = QErrorInfo.ERRORS[code]
	if errorInfo ~= nil then
		local errorStr = errorInfo.desc.."错误码("..errorInfo.errorCode..")"
		if errorInfo.isAlert then
			app:alert({content=errorStr, title="系统提示"}, false, true)
		else
			app.tip:floatTip(errorStr)
		end
	else
		app:alert({content=tostring(code), title="系统提示"}, false, true)
	end
end

function QErrorInfo:handle(code)
	--体力不足
	if code == "ENERGY_NOT_ENOUGH" then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.ENERGY)
	elseif code == "SHOP_GOOD_INVALIDATE" then
    	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogStoreDetail.ITEM_SELL_FAIL}) 
    elseif code == "TOKEN_NOT_ENOUGH" then
    	app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
    elseif code == "MONEY_DROP_WAY" then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
   	elseif code == "MARITIME_ESCORT_LIST_NO_CONSORTIA" then
   		--xurui: WOW-18782, 屏蔽此错误码的报错提示
    elseif code == "USER_STATUS_FORBID" or code == "USER_STATUS_OFFLINE" or code == "USER_STATUS_OTHER_LOGIN" then
    	local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(code)
    	local errorStr = errorCode.desc or code
    	app:alert({content=errorStr, title="系统提示", 
	        callback=function(state)
	            if state == ALERT_TYPE.CONFIRM then
	            	app:logout()
	            end
	        end}, false, true)
    elseif code == "CTUSER_INVALID" and app:isDeliveryIntegrated() == true then
        app:alert({content="您的帐号已在别处登录，请重新登录", title="系统提示", 
	        callback=function(state)
	            if state == ALERT_TYPE.CONFIRM then
	            	app:logout()
	            end
	        end}, false, true)
    elseif (code == "PLATFORM_LOGIN_ERROR_YOUZU" 
    	or code == "PLATFORM_LOGIN_ERROR_WHITE_LIST_LIMIT" 
    	or code == "LOGIN_ERROR_WHITE_LIST_LIMIT" 
    	or code == "REGISTER_ERROR_WHITE_LIST_LIMIT") and app:isDeliveryIntegrated() == true then
    	local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(code)
    	local errorStr = "魂师们，战鼓已响起，现需加群（QQ群：439346154）联系管理员激活本次游戏的帐号！" .. "\n您的账号：" .. FinalSDK.getAccoundID()
    	app:alert({content=errorStr,title="系统提示"}, false, true)

	elseif code ~= nil then
		local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(code)
		local errorStr = ""
		local isAlert = true
		if errorCode == nil then
			errorStr = "服务错误："..code
		else
			errorStr = errorCode.desc or code
			isAlert = errorCode.type == 1
		end

		if DEBUG <= 0 and errorStr == code then
			-- nothing to do
		else
			if isAlert == true then
				app:alert({content=errorStr,title="系统提示"}, false, true)
			else
				app.tip:floatTip(errorStr)
			end
		end
	end
end

return QErrorInfo