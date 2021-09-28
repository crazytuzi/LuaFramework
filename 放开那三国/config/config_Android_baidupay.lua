-- Filename: config_Android_baidupay.lua
-- Author: kun liao
-- Date: 2014-05-07
-- Purpose: android 百度支付 平台配置
module("config", package.seeall)

loginInfoTable = {}


function getFlag( ... )
	return "baiduqianbao"
end



function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?userid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "2496467"
end

function getAppKey( ... )
	return "GrLoOttCblRGIRnRRztNyu8o"
end

function getName( ... )
	return "个人中心"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
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
	local postString = url .. "?userid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
function getAppId_debug( ... )
    return "2496467"
end

function getAppKey_debug( ... )
    return "GrLoOttCblRGIRnRRztNyu8o"
end

