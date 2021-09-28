-- Filename: config_kuaiyong.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "kyphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?tokenKey=" .. sessionid  .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "111"
end

function getAppKey( ... )
	return "fb44df1508f6e78e28a60b6ff1327fa7"
end

function getName( ... )
	return GetLocalizeStringBy("key_1480")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(3456),"game")
	dict:setObject(CCString:create(loginInfoTable.guid),"guid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.guid = xmlTable:find("guid")[1]
	print_table("",loginInfoTable)
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
	local postString = url .. "?tokenKey=" .. sessionid .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "111"
end

function getAppKey_debug( ... )
	return "fb44df1508f6e78e28a60b6ff1327fa7"
end
