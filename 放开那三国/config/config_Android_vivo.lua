-- Filename: config_Android_pptv.lua
-- Author: lei yang
-- Date: 2014-4-3
-- Purpose: android VIVO 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "vivo"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?access_token=" .. sessionid .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "1041"
end

function getAppKey( ... )
	return "2C0B0BAA6AA2B68894BED7CC1A4177B4"
end

function getName( ... )
	return "vivo社区"
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
	local postString = url .. "?access_token=" .. sessionid .. "&account=".. Platform.getSdk():callStringFuncWithParam("getLoginName",nil).."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return getAppId()
end

function getAppKey_debug( ... )
	return getAppKey()
end

function getOrderUrl( coins )
	return "http://mapifknsg.zuiyouxi.com/phone/exchange?pid=" .. loginInfoTable.uid .. "&group=" .. CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup") .. "&orderAmount=" .. coins .. "&action=getorder".. Platform.getUrlParam() .. "&time=" .. BTUtil:getSvrTimeInterval() 
end

function getOrderUrl_debug( coins )
	return "http://124.205.151.82/phone/exchange?pid=" .. loginInfoTable.uid .. "&group=" .. CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup") .. "&orderAmount=" .. coins .. "&action=getorder".. Platform.getUrlParam() .. "&time=" .. BTUtil:getSvrTimeInterval() 
end
