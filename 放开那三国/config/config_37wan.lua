-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2013-11-25
-- Purpose: 


module("config", package.seeall)

function getFlag( ... )
	return "37wanphone"
end

loginInfoTable = {}
function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?"  .. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil) .. Platform.getUrlParam()
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
    print("username = ",Platform.getSdk():callStringFuncWithParam("getUName",nil))
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "1000023"
end

function getAppKey( ... )
	return "*HuhxjZ,AY2pwTJ_XSz+aKElr95&1idb"
end

function getName( ... )
	return "37wan社区"
end

function getPayParam( coins )
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
 	--游戏角色名
 	dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
 	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
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
	print("setLoginInfo")
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82:17601/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?token=" .. sessionid .."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil)  .. Platform.getUrlParam()
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
    print("username = ",Platform.getSdk():callStringFuncWithParam("getUName",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "1000023"
end

function getAppKey_debug( ... )
	return "*HuhxjZ,AY2pwTJ_XSz+aKElr95&1idb"
end
