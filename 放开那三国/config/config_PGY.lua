-- Filename: config_PP.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: PP平台配置


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "pgyphone"
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
	return "2455"
end

function getAppKey( ... )
	return "4ff83cc9bc80836dbafe9fd5930f989e"
end

function getName( ... )
	return GetLocalizeStringBy("key_2196")
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
	local url = "http://192.168.1.59:17601/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .. Platform.getUrlParam().. "&userId=" .. Platform.getSdk():callIntFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "2455"
end

function getAppKey_debug( ... )
	return "4ff83cc9bc80836dbafe9fd5930f989e"
end
