-- Filename: config_Android_kaopu.lua
-- Author: lichenyangsdk
-- Date: 2015-09-22
-- Purpose: 靠谱助手平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "kaopu"
end

function getName( ... )
	return "靠谱社区"
end

function getAppId( ... )
	return "10116002"
end

function getAppKey( ... )
	return "10116"
end

function getAppName( ... )
	return "放开那三国"
end
--用来配置充值回调。（如果充值回调在本地可以在此方法配置）
function getPayNotifyUrl( ... )
	if Platform.isDebug() then
		return ""
	else
		return ""
	end
end

function getServerListUrl( ... )
 	return Platform.getDomain() .. "phone/serverlistnotice/?".. Platform.getUrlParam()
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
    local postString = url .. "?openid=" .. sessionid .."&r=" .. Platform.sdkLoginInfo.ur .. "&token=" .. Platform.sdkLoginInfo.token .. "&imei=" .. Platform.sdkLoginInfo.uimei .. "&kp_channel=" .. Platform.sdkLoginInfo.uchannel .. "&kp_sign=" .. Platform.sdkLoginInfo.usign .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
 	return postString
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
    local postString = url .. "?openid=" .. sessionid .."&r=" .. Platform.sdkLoginInfo.ur .. "&token=" .. Platform.sdkLoginInfo.token .. "&imei=" .. Platform.sdkLoginInfo.uimei .. "&kp_channel=" .. Platform.sdkLoginInfo.uchannel .. "&kp_sign=" .. Platform.sdkLoginInfo.usign .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
 	return postString
end 

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getPayNotifyUrl()),"payurl")
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getAppKey()),"appKey")
	dict:setObject(CCString:create(getAppName()),"appName")
	dict:setObject(CCString:create("2"),"screentOrient") -- 1竖屏，2横屏
	return dict
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	dict:setObject(CCString:create("金币"),"currency")
	dict:setObject(CCString:create("放开那三国金币"),"productname")
	return dict
end

function getUserInfoParam(gameState)
   	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    if(tonumber(gameState) == 1)then
	    -- 下面的appUid和appUname暂时获取不到，先不用
	    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getUserUtid()),"appUtid")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	    dict:setObject(CCString:create(UserModel.getGoldNumber()),"appUgold")
	    dict:setObject(CCString:create(UserModel.getVipLevel()),"appUvip")
	    dict:setObject(CCString:create(UserModel.getCreateTime()),"appCreateTime")
	end
	return dict
end
