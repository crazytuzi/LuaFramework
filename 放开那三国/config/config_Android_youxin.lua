-- Filename: config_Android_youxin.lua
-- Author: kun liao
-- Date: 2014-04-12
-- Purpose: android 有信 平台配置
module("config", package.seeall)

loginInfoTable = {}


function getFlag( ... )
	return "youxinphone"
end



function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?openid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "10061"
end

function getAppKey( ... )
	return "1F60EC18335C09F7CD8D6CFC18A39020"
end

function getName( ... )
	return "有信"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
    dict:setObject(CCString:create(coins),"coins")
    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
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
	local postString = url .. "?openid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
function getAppId_debug( ... )
	return "10061"
end

function getAppKey_debug( ... )
	return "1F60EC18335C09F7CD8D6CFC18A39020"
end

