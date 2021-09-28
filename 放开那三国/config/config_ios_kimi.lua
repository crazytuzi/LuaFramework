-- Filename: config_ios_kimi.lua
-- Author: baoxu
-- Date: 2014-02-21
-- Purpose: 


module("config", package.seeall)

local g_web_domain_name = "http://api.fun.kimi.com.tw/"--"http://api.fun.kimi.com.tw/"
local g_web_domain_name_debug = "http://210.73.215.68/"
local g_web_download_url = "http://f-tw.kimi.com.tw/twnsg/"

function getFlag( ... )
	return "kmphone"
end

loginInfoTable = {}
function getServerListUrl( ... )
 	return g_web_domain_name .. "phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = g_web_domain_name .. "phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    return postString
end 

function getLanguage( ... )
 	return "tw"
end 

function getDomain( ... )
 	return g_web_domain_name
end 

function getDownUrl( ... )
	return g_web_download_url
end

function getAdShowUrl( ... )
 	return g_web_domain_name.. "phone/adshow?pl=kmphone&os=ios&gn=sanguo&version="
end 

function getBbsUrl( ... )
 	return "http://fun.kimi.com.tw/innernews/"
end

function getHashUrl( )
 	return g_web_domain_name .. "phone/getHash/"
end 

function getAppId( ... )
	return "0"
end

function getAppKey( ... )
	return "qf5NaPn1J&Wj8wdSqfMBZO#1JWuj8FdS"
end

function getName( ... )
	return "社區福利"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

function getGroupParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

function getUserInfoParam( gameState )
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
    if(tonumber(gameState) == 1)then
       	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
       	dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
       	--print("gameState = ",gameState)
       	--print("appUid = ",UserModel.getUserUid())
       	--print("appUname = ",UserModel.getUserName())
	end
	--print("gameState = ",gameState)
	return dict
end

function getShareInfoParam( dict )
    local feed = GetLocalizeStringBy("key_1647")
    local caption = "《曹操之野望》下一戰，英雄由你來當！"
    local description = GetLocalizeStringBy("key_1851")
    local link = "https://itunes.apple.com/tw/app/fang-kai-na-san-guo-xing-dong/id865964977?ls=1&mt=8"
    local picture = "http://static.kimi.com.tw/web/nsg/images/fb_nsg_icon.png"

    dict:setObject(CCString:create(feed),"feed")
    dict:setObject(CCString:create(caption),"caption")
    dict:setObject(CCString:create(description),"description")
    dict:setObject(CCString:create(link),"link")
    dict:setObject(CCString:create(picture),"picture")

	return dict
end

function getPayTypeParam( ... )
    return 3
end
function getPayMoneyDesc( ... )
    return GetLocalizeStringBy("key_1031")
end
function getLogoLayer( ... )
    local logoParam = {}
    logoParam.needPlatformLogo  = false
    logoParam.logoName          = nil
    logoParam.bTlogoName        = "images/logo/kimi_logo.png"
    logoParam.scaleFunction     = "setAdaptNode"
    return logoParam
end 
function getBgLayer( ... )
    return nil
end 
function getShareType( ... )
    return "Facebook"
end 
function isNeedAdShow( ... )
    return true
end 
function isNeedUserSenter( ... )
    return true
end 
function isNeedInitPlGroup( ... )
    return false
end 

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

--debug conifg

function getPidUrl_debug( sessionid )
	--local url = "http://124.205.151.82/phone/login"
	local url = g_web_domain_name_debug .. "phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .. Platform.getUrlParam().. "&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUserId",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
    --return "http://124.205.151.82/phone/serverlistnotice/?pl=kmphone&gn=sanguo&os=ios"
    return g_web_domain_name_debug .. "phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getDomain_debug( ... )
 	return g_web_domain_name_debug
end 

function getAppId_debug( ... )
	return "1"
end

function getAppKey_debug( ... )
	return "qf5NaPn1J&Wj8wdSqfMBZO#1JWuj8FdS"
end