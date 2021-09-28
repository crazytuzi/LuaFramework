-- Filename: config_wp8_zyx.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
platformName="gwphone"--"aiyingyong"
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	local other_pl = Platform.getSdk():callStringFuncWithParam("getOtherPl",nil)
	print("other_pl=",other_pl)
	return other_pl
end

function getOther_pl( ... )
	return "zyxphone"
end
function getServerListUrl( ... )
 	return Platform.getDomain() .. "phone/serverlistnotice/?".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
end 

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
    local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
    if(uuid ~= nil)then
 	   postString = postString  .. "&uuid=" .. uuid
    end
    pring("postString=",postString)
 	return postString
end 

function getHashUrl( )
	local hashUrl = Platform.getDomain() .. "phone/getHash/"
	local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
    hashUrl = hashUrl  .. "&uuid=" .. uuid
 	return hashUrl
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

	local loginUrl = Platform.getDomain() .. "phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
	local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
	if(uuid ~= nil)then
 	   loginUrl = loginUrl  .. "&uuid=" .. uuid
    end
	
	return loginUrl
end

function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://124.205.151.82/phone/login/?action=register" .. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	else
		registerUrl = Platform.getDomain() .. "phone/login/?action=register".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	end
	local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
	if(uuid ~= nil)then
 	   registerUrl = registerUrl  .. "&uuid=" .. uuid
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

function getPayParam( coins )

	local url
	if  Platform.isDebug() then
		url = "http://124.205.151.82:17301/appbilling?"
	else
		url = "http://zuiyouxi.com/appbilling?"
	end
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	local groupId = CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")
	local groupName = ServerList.getSelectServerInfo().name

	local payUrl = url .. "&server=" .. groupId .. "&server_name=" .. groupName .. "&qid=" .. Platform.getPid() .. "&name=" .. string.urlEncode(UserModel.getUserName())
	payUrl = payUrl .. "&project=4" .. "&from_ad=1" .. Platform.getUrlParam() .. "&depositStep=2" .. "&num=" .. coins/10 .. "&style=w" 
	dict:setObject(CCString:create(payUrl),"payUrl")
	return dict
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
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()  .."&other_pl=" .. getOther_pl()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid  .."&other_pl=" .. getOther_pl()
 	local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
 	if(uuid ~= nil)then
 	   postString = postString  .. "&uuid=" .. uuid
    end
    
    pring("postString=",postString)
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getLoginUrl_debug( username,password )
	local loginUrl = "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=".. "&bind=" .. g_dev_udid  .."&other_pl=" .. getOther_pl()
	local uuid = Platform.getSdk():callStringFuncWithParam("getUuid",nil)
	if(uuid ~= nil)then
 	   loginUrl = loginUrl  .. "&uuid=" .. uuid
    end
	return loginUrl
end
