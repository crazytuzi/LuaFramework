-- Filename: config_duoku.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: 多酷平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "dkphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uid=".. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "1711"
end

function getAppKey( ... )
	return "f72a6ba29774758db5eb64a2ff321d1c"
end

function getName( ... )
	return GetLocalizeStringBy("key_1176")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]

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
	local postString = url .. "?sid=" .. sessionid .. "&uid=".. Platform.getSdk():callStringFuncWithParam("getUid",nil).. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "1711"
end

function getAppKey_debug( ... )
	return "f72a6ba29774758db5eb64a2ff321d1c"
end
