-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2014-1-7
-- Purpose: 


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "itoolsphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sessionid=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callIntFuncWithParam("getUserId",nil) .. "&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "50"
end

function getAppKey( ... )
	return "99CC150E84340F75990351A1E03DC36C"
end

function getName( ... )
	return "iTools社区"
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
	--local url = "http://124.205.151.82:10021/phone/login/"
	local url = "http://192.168.1.59:17601/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sessionid=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUserId",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
    --return "http://124.205.151.82:10021/phone/serverlistnotice/?gn=sanguo&pl=itoolsphone"
    return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "50"
end

function getAppKey_debug( ... )
	return "99CC150E84340F75990351A1E03DC36C"
end
