-- Filename: config_Android_jinli.lua
-- Author: kun liao
-- Date: 2014-06-23
-- Purpose: android 金立 平台配置
module("config", package.seeall)

loginInfoTable = {}
function getFlag( ... )
	return "jinliphone"
end


function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
        local postString = url .. "?userid=" .. sessionid.."&token="..Platform.sdkLoginInfo.token..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId( ... )
	return "0"
end

function getAppKey( ... )
	return "0"
end

function getName( ... )
	return "用户社区"
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
		local postString = url .. "?userid=" .. sessionid.."&token="..Platform.sdkLoginInfo.token..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
function getAppId_debug( ... )
    return "0"
end

function getAppKey_debug( ... )
    return "0"
end

