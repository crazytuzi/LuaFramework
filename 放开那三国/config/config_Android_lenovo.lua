-- Filename: config_Android_levovo.lua
-- Author: lei yang
-- Date: 2014-3-27
-- Purpose: android 联想 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "lenphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?lpsust=" .. sessionid .. "&realm=" .. Platform.sdkLoginInfo.realm .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "20032300000001200323"
end

function getAppKey( ... )
	return "QTk2ODE0REM5OUU4MEE1RThFRjQyMzRGRTQyQkNBQUIzRUU4RTREM01UY3dPRGs1TVRBM056WXpNalkxTVRNME16RXJNak0zTURnd016YzROVGs1TkRJMk56SXlPREl3TnpnM09EQTFPREF5TWprNU5USTJPRGt4"
end

function getName( ... )
	return "联想社区"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	local waresid
	if(coins == 100)then
		waresid = 1
	elseif(coins == 300)then
		waresid = 2
	elseif(coins == 500)then
		waresid = 3
	elseif(coins == 1000)then
		waresid = 4
	elseif(coins == 2000)then
		waresid = 5
	elseif(coins == 5000)then
		waresid = 6
	elseif(coins == 10000)then
		waresid = 7
	elseif(coins == 20000)then
		waresid = 8
	end
	dict:setObject(CCString:create(waresid),"waresid")

	return dict
end

function getUserInfoParam(gameState)
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    if(tonumber(gameState) == 1)then
	    -- 下面的appUid和appUname暂时获取不到，先不用
	    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getUserUtid()),"appUtid")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	end

	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

function getGroupParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?lpsust=" .. sessionid .. "&realm=" .. Platform.sdkLoginInfo.realm .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "20032300000001200323"
end

function getAppKey_debug( ... )
	return "QTk2ODE0REM5OUU4MEE1RThFRjQyMzRGRTQyQkNBQUIzRUU4RTREM01UY3dPRGs1TVRBM056WXpNalkxTVRNME16RXJNak0zTURnd016YzROVGs1TkRJMk56SXlPREl3TnpnM09EQTFPREF5TWprNU5USTJPRGt4"
end
