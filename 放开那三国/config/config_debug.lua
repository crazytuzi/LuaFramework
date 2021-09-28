-- Filename: Platform.lua
-- Author: lichenyang
-- Date: 2013-10-31
-- Purpose: 


module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "chphone_test"
	-- return "ppphone"
end


function getServerListUrl( ... )
 	return "http://192.168.1.38/phone/serverlistnotice/?".. Platform.getUrlParam()

end 

function getPidUrl( sessionid )
	local url = "http://192.168.1.59:10021/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. Platform.getUrlParam().. "&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "1433"
end	

function getAppKey( ... )
	return "4a0107e99c0a8d81fddcec3d49491ba6"
end

function getName( ... )
	return "Android_uc"
end


function getPayParam( coins )
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins * 0.1),"coins")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end


--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://192.168.1.59:17601/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. Platform.getUrlParam().. "&bind=" .. g_dev_udid
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://192.168.1.38/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "1605"
end

function getAppKey_debug( ... )
	return "63116dcfc726ce64d073a9240dce92a6"
end
