-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2013-11-06
-- Purpose: 


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "sinaphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?" .. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid.."&bind=" .. g_dev_udid .. Platform.getUrlParam()
	postString = postString .. "&uid=" .. Platform.sdkLoginInfo.userId .. "&machineid=" .. Platform.sdkLoginInfo.machineid .. "&ip=" .. Platform.sdkLoginInfo.ip
	
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "100000465"
end

function getAppKey( ... )
	return "a80fcdd2cd505f0c26e645de0d08d112"
end

function getName( ... )
	return "新浪社区"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.uid = xmlTable:find("uid")[1]
end

--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid.."&bind=" .. g_dev_udid .. Platform.getUrlParam()
	postString = postString .. "&uid=" .. Platform.sdkLoginInfo.userId .. "&machineid=" .. Platform.sdkLoginInfo.machineid .. "&ip=" .. Platform.sdkLoginInfo.ip
	
 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "100000465"
end

function getAppKey_debug( ... )
	return "a80fcdd2cd505f0c26e645de0d08d112"
end
