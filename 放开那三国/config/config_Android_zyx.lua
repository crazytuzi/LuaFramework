-- Filename: config_91.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
platformName="ayphone"


module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	printR("pl2=====",platformName)
	return platformName
end

function getOther_pl( ... )
	return "zyxphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
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
	return "http://mapifknsg.zuiyouxi.com/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
end

function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://124.205.151.82/phone/login/?action=register" .. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	else
		registerUrl = "http://mapifknsg.zuiyouxi.com/phone/login/?action=register".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	end
	return registerUrl
end



function getChangePasswordUrl( )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
	else
		renewpassUrl = "http://mapifknsg.zuiyouxi.com/phone/login/?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
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

	local payUrl = url .. "&server=" .. groupId .. "&server_name=" .. groupName .. "&qid=" .. Platform.getPid() .. "&name=" .. UserModel.getUserName()
	payUrl = payUrl .. "&project=4" .. "&from_ad=1" .. Platform.getUrlParam() .. "&depositStep=2" .. "&num=" .. coins/10 .. "&style=w" --coins/10
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
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getLoginUrl_debug( username,password )
	return "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=".. "&bind=" .. g_dev_udid  .."&other_pl=" .. getOther_pl()
end
