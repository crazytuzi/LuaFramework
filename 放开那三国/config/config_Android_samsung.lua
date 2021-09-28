-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2013-11-25
-- Purpose: 
module("config", package.seeall)

function getFlag( ... )
	return "samsung"
end

loginInfoTable = {}

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .."&channel=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid

 	return postString
end 

function getAppId( ... )
	return "1084"
end

function getAppKey( ... )
	return "f5fdd0b21c89fe566729e169ea329ec4c5827993"
end

function getName( ... )
	return "个人中心"
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
	local url = "http://124.205.151.82/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .."&channel=" .. Platform.getSdk():callStringFuncWithParam("getUName",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid

 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "1084"
end

function getAppKey_debug( ... )
	return "f5fdd0b21c89fe566729e169ea329ec4c5827993"
end
