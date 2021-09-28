-- Filename: config_Android_cw.lua
-- Author: lei yang
-- Date: 2014-3-18
-- Purpose: android PPTV 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "cwphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end

	local postString = url .. "?token=" .. sessionid 
		.. "&openId=" .. Platform.sdkLoginInfo.openId 
		.. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "10084"
end

function getAppKey( ... )
	return "ZckC40VGoM6T1tUm"
end

function getName( ... )
	return "畅玩社区"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
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
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end

	local postString = url .. "?token=" .. sessionid 
		.. "&openId=" .. Platform.sdkLoginInfo.openId 
		.. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "10084"
end

function getAppKey_debug( ... )
	return "ZckC40VGoM6T1tUm"
end

function getInitParam(  )
	local dict = CCDictionary:create()
    dict:setObject(CCString:create("10084"),"appId")
    dict:setObject(CCString:create("ZckC40VGoM6T1tUm"),"signkey")
    dict:setObject(CCString:create("19857"),"packetid")
    --dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end