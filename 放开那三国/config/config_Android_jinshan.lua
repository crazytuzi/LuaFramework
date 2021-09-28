-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2013-11-06
-- Purpose: 


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "jswlphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?" .. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid.."&bind=" .. g_dev_udid .. Platform.getUrlParam().."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil)
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
    print("username = ",Platform.getSdk():callStringFuncWithParam("getUName",nil))
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "200052"
end

function getAppKey( ... )
	return "g906535pv2a15a"
end

function getName( ... )
	return GetLocalizeStringBy("key_2204")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

function getUserInfoParam( gameState )
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
    if(tonumber(gameState) == 1)then
       	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
       	dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
       	--print("gameState = ",gameState)
       	--print("appUid = ",UserModel.getUserUid())
       	--print("appUname = ",UserModel.getUserName())
	end
	--print("gameState = ",gameState)
	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82:17601/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .."&bind=" .. g_dev_udid .. Platform.getUrlParam().."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil)
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
    print("username = ",Platform.getSdk():callStringFuncWithParam("getUName",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "200052"
end

function getAppKey_debug( ... )
	return "g906535pv2a15a"
end
