-- Filename: config_xiaomi.lua
-- Author: chao he
-- Date: 2013-11-7
-- Purpose: android 安智 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "azphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "13838831276441otoagwjUdW01iwQ9"
end

function getAppKey( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end

function getName( ... )
	return "安智社区"
end

function getInitParam( ... )
	local dict = CCDictionary:create()
    dict:setObject(CCString:create(getAppId()),"appId")
    dict:setObject(CCString:create(getAppKey()),"appKey")

	dict:setObject(CCString:create("0"),"openRecharge")
	dict:setObject(CCString:create("0"),"UIInterfaceOrientationPortrait")
	dict:setObject(CCString:create("0"),"UIInterfaceOrientationPortraitUpsideDown")
	dict:setObject(CCString:create("1"),"UIInterfaceOrientationLandscapeLeft")
	dict:setObject(CCString:create("1"),"UIInterfaceOrientationLandscapeRight")

	return dict
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
	local postString = url .. "?sid=" .. sessionid .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "13838831276441otoagwjUdW01iwQ9"
end

function getAppKey_debug( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end