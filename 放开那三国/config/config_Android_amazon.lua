-- Filename: config_Android_amazon.lua
-- Author: kun liao
-- Date: 2014-05-27
-- Purpose: android 亚马逊 平台配置
module("config", package.seeall)

loginInfoTable = {}
function getFlag( ... )
	return "amazon"
end
function getOther_pl( ... )
	return "zyxphone"
end
kLoginsStateNotLogin="0"
kLoginsStateUDIDLogin="1"
kLoginsStateZYXLogin="2"
function getLoginState( ... )
	if(CCUserDefault:sharedUserDefault():getStringForKey("loginState") == nil or CCUserDefault:sharedUserDefault():getStringForKey("loginState") == "")then
		return kLoginsStateNotLogin
	end
	return CCUserDefault:sharedUserDefault():getStringForKey("loginState")
end


function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?userid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 
function getLoginUrl( username,password )
	return Platform.getDomain() .. "phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
end

function getLoginUrl_debug( username,password )
	return "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=".. "&bind=" .. g_dev_udid  .."&other_pl=" .. getOther_pl()
end

function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://124.205.151.82/phone/login/?action=register" .. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	else
		registerUrl = Platform.getDomain() .. "phone/login/?action=register".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	end
	return registerUrl
end

function getChangePasswordUrl( )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
	else
		renewpassUrl = Platform.getDomain() .. "phone/login/?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
	end
	return renewpassUrl
end

function getAppId( ... )
	return "0"
end

function getAppKey( ... )
	return "0"
end

function getName( ... )
	return "亚马逊"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
    dict:setObject(CCString:create(coins),"coins")
    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
    dict:setObject(CCString:create(Platform.getPid()),"pid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
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
    local postString = url .. "?userid=" .. sessionid..Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end

function getAppId_debug( ... )
    return "0"
end

function getAppKey_debug( ... )
    return "0"
end

