-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2013-10-28
-- Purpose: 


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "tbtphone"
end

function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callIntFuncWithParam("getUserId",nil) .. "&bind=" .. g_dev_udid
    local curVer = string.sub(g_publish_version,1,1)..string.sub(g_publish_version,3,3)..string.sub(g_publish_version,5,5) or 424
 	if(tonumber(curVer) > 423)then
 		postString = postString .. "&action=newsdk"
 	end
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "131029"
end

function getAppKey( ... )
	return "qf5NaPn1J&Wj8wdSqfMBZO#1JWuj8FdS"
end

function getName( ... )
	return GetLocalizeStringBy("key_1841")
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
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUserId",nil))
    print("g_publish_version:",g_publish_version)
    local curVer = string.sub(g_publish_version,1,1)..string.sub(g_publish_version,3,3)..string.sub(g_publish_version,5,5) or 424
    print("curVer:",curVer)
 	if(tonumber(curVer) > 423)then
 		postString = postString .. "&action=newsdk"
 	end
 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://124.205.151.82/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "131148"
end

function getAppKey_debug( ... )
	return "EcSq4MBZm@zgVtiPEcp&3LZxmzIgVi7P"
end
