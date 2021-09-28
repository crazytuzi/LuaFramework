-- Filename: config_Android_doudou.lua
-- Author: kun liao
-- Date: 2015-1-15
-- Purpose: android doudou 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "doudou"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	local ticket = Platform.sdkLoginInfo.ticket
	local userid = Platform.sdkLoginInfo.userid
	local postString = url .. "?userid=" .. userid 
		.. "&ticket=" .. ticket
		.. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "880000063"
end

function getAppKey( ... )
	return "d0f91c709d4621fde5a457399fad56ef"
end

function getName( ... )
	return "逗逗社区"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	return dict
end

function getUserInfoParam(gameState)
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    if(tonumber(gameState) == 1)then
	    -- 下面的appUid和appUname暂时获取不到，先不用
	    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getUserUtid()),"appUtid")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	end

	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

function getGroupParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	local ticket = Platform.sdkLoginInfo.ticket
	local userid = Platform.sdkLoginInfo.userid
	local postString = url .. "?userid=" .. userid 
		.. "&ticket=" .. ticket
		.. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "880000063"
end

function getAppKey_debug( ... )
	return "d0f91c709d4621fde5a457399fad56ef"
end

-- function getInitParam(  )
-- 	local dict = CCDictionary:create()
--     dict:setObject(CCString:create("10084"),"appId")
--     dict:setObject(CCString:create("ZckC40VGoM6T1tUm"),"signkey")
--     dict:setObject(CCString:create("19857"),"packetid")
--     --dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
-- 	return dict
-- end