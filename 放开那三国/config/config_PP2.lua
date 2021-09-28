-- Filename: config_PP.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: PP平台配置


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "pp2phone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .. Platform.getUrlParam().. "&userId=" .. Platform.getSdk():callIntFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "2617"
end

function getAppKey( ... )
	return "d6a1087ce506d8003bda4c9da5a66537"
end

function getName( ... )
	return GetLocalizeStringBy("key_2421")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://192.168.1.38/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .. Platform.getUrlParam().. "&userId=" .. Platform.getSdk():callIntFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
 	return postString
end 
function getServerListUrl_debug( ... )
 	--return "http://124.205.151.82/phone/serverlistnotice/?gn=sanguo&pl=ppphone&os=ios"
 	return "http://192.168.1.38/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "2617"
end

function getAppKey_debug( ... )
	return "d6a1087ce506d8003bda4c9da5a66537"
end
