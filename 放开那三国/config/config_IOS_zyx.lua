-- Filename: config_91.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "iostest"
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
 	return postString
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
	return Platform.getDomain() .. "phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
end

function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://124.205.151.82/phone/login/?action=register" .. Platform.getUrlParam()
	else
		registerUrl = Platform.getDomain() .. "phone/login/?action=register".. Platform.getUrlParam()
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
		url = "http://zuiyouxi.com/phonebilling?"
	end
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	-- dict:setObject(CCString:create(coins),"coins")
	-- dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	-- dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	-- dict:setObject(CCString:create(loginInfoTable.access_token),"access_token")
	-- dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	-- dict:setObject(CCString:create(loginInfoTable.userid),"userid")
	-- dict:setObject(CCString:create(loginInfoTable.uname),"username")
	-- dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	local groupId = CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")
	local groupName = ServerList.getSelectServerInfo().name

	local payUrl = url .. "&server=" .. groupId .. "&server_name=" .. groupName .. "&qid=" .. Platform.getPid() .. "&name=" .. UserModel.getUserName()
	payUrl = payUrl .. "&project=4" .. "&from_ad=1" .. Platform.getUrlParam() .. "&depositStep=2" .. "&num=" .. 1 .. "&style=w"--coins/10 
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

function getADUrl( pid, mac, idfa )
	-- local mac = Platform.getSdk():callStringFuncWithParam("getMac",nil)
	-- local idfa = Platform.getSdk():callStringFuncWithParam("getIdfa",nil)
	-- print("mac =",mac)
	-- print("idfa =",idfa)
	-- return Platform.getDomain() .. "phone/adstat?pl=appstore&os=ios&gn=sanguo&&pid=".. pid .. "&mac=" .. mac .. "&idfa=" .. idfa.."&devres="..g_winSize.width.."x"..g_winSize.height
	return nil
end
function getADUrl_debug( pid, mac, idfa )
	return nil
end
