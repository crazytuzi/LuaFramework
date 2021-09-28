-- Filename: config_Android_kuaiyong.lua
-- Author: kun liao
-- Date: 2015-10-9
-- Purpose: android 快用 平台配置
module("config", package.seeall)
loginInfoTable = {}
function getFlag( ... )
	return "kyadphone"
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
        local postString = url .. "?token=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getInitParam(  )
    local dict = CCDictionary:create()
    return dict
end
function getName( ... )
	return "用户社区"
end

function getPayParam( coins )
    
	local dict = CCDictionary:create()
    dict:setObject(CCString:create(coins),"coins")
    dict:setObject(CCString:create("金币"),"proName")
    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
    dict:setObject(CCString:create(UserModel.getVipLevel()),"appVipLevel")
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
    dict:setObject(CCString:create(loginInfoTable.guid),"guid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    return dict
end

function getInitParam(  )
    local dict = CCDictionary:create()
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
        dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
        dict:setObject(CCString:create(UserModel.getVipLevel()),"appVipLevel")
    end
    return dict
end
--debug conifg
function getServerListUrl_debug( ... )
    return "http://192.168.1.38/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://192.168.1.38/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
		local postString = url .. "?token=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
    loginInfoTable.guid = xmlTable:find("guid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end