-- Filename: config_dangle.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: 当乐平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "dlphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
    local mid = Platform.getSdk():callStringFuncWithParam("getUserid",nil)
	local postString = url .. "?token=" .. sessionid .. "&mid=".. Platform.getSdk():callStringFuncWithParam("getUserid",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "784"
end

function getAppKey( ... )
	return "b863EX69"
end

function getName( ... )
	return GetLocalizeStringBy("key_2249")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
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
	local postString = url .. "?token=" .. sessionid .. "&mid=".. Platform.getSdk():callStringFuncWithParam("getUserid",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "784"
end

function getAppKey_debug( ... )
	return "b863EX69"
end
