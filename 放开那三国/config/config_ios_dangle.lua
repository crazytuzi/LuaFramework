-- Filename: config_dangle.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: 当乐平台配置
module("config", package.seeall)


-- 更改 服务基础URL
local g_web_domain_name = "http://59.46.80.119:899/fangsan/heishou/"
-- 服务器列表URL
local g_server_list_url = "http://59.46.80.119:89/phone/fs_server_list/"
-- 检查版本URL = g_web_domain_name .. "phone/get3dVersion?"

-- 更改 下载更新包URL
local g_web_download_url = "http://59.46.80.119:89/sanguo/"

-- 更改 账号登录URL
local g_acc_login_url = "http://59.46.80.119:8881/phone/login/"


loginInfoTable = {}

function getFlag( ... )
	return "dlphone"
end

function getDomain( ... )
 	return g_web_domain_name
end 

function getDownUrl( ... )
	return g_web_download_url
end


function getServerListUrl( ... )
	return g_server_list_url .. "?".. Platform.getUrlParam()
end 

--[[
function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
    local mid = Platform.getSdk():callStringFuncWithParam("getUserid",nil)
	local postString = url .. "?token=" .. sessionid .. "&mid=".. Platform.getSdk():callStringFuncWithParam("getMid",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 
--]]

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "1278"
end

function getAppKey( ... )
	return "uXAqfP0g"
end

function getName( ... )
	return GetLocalizeStringBy("key_2249")
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
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
	local postString = url .. "?token=" .. sessionid .. "&mid=".. Platform.getSdk():callStringFuncWithParam("getMid",nil) .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "1278"
end

function getAppKey_debug( ... )
	return "uXAqfP0g"
end



function getOther_pl( ... )
	return "zyxphone"
end

function getPidUrl( sessionid )
	--local url = "http://58.220.3.141:8000/phone/login/"
	local url = g_acc_login_url
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
 	return postString
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


function getLoginUrl( username,password )
	return g_acc_login_url .. "?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid .."&other_pl=" .. getOther_pl()
end


function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://124.205.151.82/phone/login/?action=register" .. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	else
		registerUrl = g_acc_login_url .. "?action=register".. Platform.getUrlParam() .."&other_pl=" .. getOther_pl()
	end
	return registerUrl
end

function getChangePasswordUrl( )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = "http://124.205.151.82/phone/login/?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
	else
		renewpassUrl = g_acc_login_url .. "?".. Platform.getUrlParam().."&action=renewpass" .."&other_pl=" .. getOther_pl()
	end
	return renewpassUrl
end
