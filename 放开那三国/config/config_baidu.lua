-- Filename: config_baidu.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: baidu 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "bdphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "104964"
end

function getAppKey( ... )
	return "07b68523759147d46ff30ba8f4aef42779a89b1b727a3528"
end

function getName( ... )
	return GetLocalizeStringBy("key_1482")
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
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end
