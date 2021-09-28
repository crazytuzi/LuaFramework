-- Filename: config_baofeng.lua
-- Author: lichenyangsdk
-- Date: 2014-09-25
-- Purpose: 
module("config", package.seeall)

function getFlag( ... )
	return "baofeng"
end

loginInfoTable = {}

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getUid",nil)
    end
	local postString = url .. "?userid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. Platform.getUrlParam()
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 

function getAppId( ... )
	return "8"
end

function getAppKey( ... )
	return "06098176"
end

function getGameId( ... )
	return "7"
end

function getServerId( ... )
	return "25"
end

function getChannelId( ... )
	return "213"
end

function getName( ... )
	return "暴风社区"
end

function getPayNotifyUrl( ... )
	if Platform.isDebug() then
		return "http://124.205.151.82/phone/exchange"
	else
		return "http://mapifknsg.zuiyouxi.com/phone/exchange"
	end
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getAppId()),"appId")
    dict:setObject(CCString:create(getAppKey()),"appKey")
    dict:setObject(CCString:create(getGameId()),"gameId")
    dict:setObject(CCString:create(getServerId()),"serverId")
    dict:setObject(CCString:create(getChannelId()),"channelId")
	return dict
end

function getPayParam( coins )
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
 	dict:setObject(CCString:create(getPayNotifyUrl()),"payUrl")
 	dict:setObject(CCString:create("sanguo"),"pl")
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
	local url = "http://119.255.38.86/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getUid",nil)
    end
	local postString = url .. "?userid=" .. Platform.getSdk():callStringFuncWithParam("getUid",nil) .. Platform.getUrlParam()
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
    return "http://119.255.38.86/phone/serverlistnotice?".. Platform.getUrlParam()
end 

