-- Filename: config_91.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
module("config", package.seeall)

loginInfoTable = {}
function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?pl=appstore&gn=sanguo&os=ios"
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .."&gn=sanguo&pl=appstore&os=ios&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "101942"
end

function getAppKey( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getName( ... )
	return "游戏社区"
end

function getLoginUrl( username,password )
	return "http://mapifknsg.zuiyouxi.com/phone/login/?gn=sanguo&pl=appstore&os=ios&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid
end

function getADUrl( pid, mac, idfa )
	local mac = Platform.getSdk():callStringFuncWithParam("getMac",nil)
	local idfa = Platform.getSdk():callStringFuncWithParam("getIdfa",nil)
	print("mac =",mac)
	print("idfa =",idfa)
	return "http://mapifknsg.zuiyouxi.com/phone/adstat?pl=appstore&os=ios&gn=sanguo&&pid=".. pid .. "&mac=" .. mac .. "&idfa=" .. idfa.."&devres="..g_winSize.width.."x"..g_winSize.height
end


function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end


function getChangePasswordUrl( username,password )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = "http://124.205.151.82/phone/login/?gn=sanguo&pl=appstore&os=ios&action=renewpass"
	else
		renewpassUrl = "http://mapifknsg.zuiyouxi.com/phone/login/?gn=sanguo&pl=appstore&os=ios&action=renewpass"
	end
	return renewpassUrl
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

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?pl=appstore&gn=sanguo&os=ios"
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .."&gn=sanguo&pl=appstore&os=ios&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getLoginUrl_debug( username,password )
	return "http://124.205.151.82/phone/login/?gn=sanguo&pl=appstore&os=ios&action=login&username=" .. username .. "&password=" .. password .. "&ext=".. "&bind=" .. g_dev_udid
end

function getADUrl_debug( pid, mac, idfa )
	local mac = Platform.getSdk():callStringFuncWithParam("getMac",nil)
	local idfa = Platform.getSdk():callStringFuncWithParam("getIdfa",nil)
	print("mac =",mac)
	print("idfa =",idfa)
	return "http://124.205.151.82/phone/adstat?pl=appstore&os=ios&gn=sanguo&pid=".. pid .. "&mac=" .. mac .. "&idfa=" .. idfa
end
