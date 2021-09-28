-- Filename: config_ios_english
-- Author: baoxu
-- Date: 2014-10-20
-- Purpose: 
--[[
hi :
线上后台:              	http://api.ss.siamgame.in.th/admincp/admin/login
线上服务器列表:      		http://api.ss.siamgame.in.th/phone/serverlistnotice?pl=thaiphone&gn=sanguo&os=ios
线上登陆:              	http://api.ss.siamgame.in.th/phone/login
 
线下后台:               	http://apitest.ss.siamgame.in.th/admincp/admin/login
线下服务器列表:      		http://apitest.ss.siamgame.in.th/phone/serverlistnotice?pl=thaiphone&gn=sanguo&os=ios
线下登陆:             	http://apitest.ss.siamgame.in.th/phone/login
--]]

module("config", package.seeall)

local g_web_domain_name = "http://obapi.omgkingdom.koramgame.com/"
local g_web_domain_name_debug = "http://api.omgkingdom.koramgame.com/"
local g_web_download_url = "http://f-ap.koramgame.com/fknsg/"

function getFlag( ... )
	return "dnyenphone"
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
 	return "en"
end 

function getDomain( ... )
 	return g_web_domain_name
end 

function getDownUrl( ... )
	return g_web_download_url
end

function getAdShowUrl( ... )
 	return g_web_domain_name.. "phone/adshow?pl=dnyenphone&os=ios&gn=sanguo&version="
end 

function getBbsUrl( ... )
 	return "http://api.omgkingdom.koramgame.com/innernews/"
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
	return "Community"
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
    local feed = "OMG! Kingdoms"
    local caption = "OMG! Kingdoms, a super popular RPG game based on the acclaimed Three Kingdoms!"
    local description = "OMG! Kingdoms, a fantastic and cute RPG strategic game based on the acclaimed Three Kingdoms,\nwith exquisite pictures, humorous plots and amazing battle gameplay."
    local link = "https://itunes.apple.com/app/id927241256"
    local picture = "http://omgkingdom.koramgame.com/icon.png"

    dict:setObject(CCString:create(feed),"feed")
    dict:setObject(CCString:create(caption),"caption")
    dict:setObject(CCString:create(description),"description")
    dict:setObject(CCString:create(link),"link")
    dict:setObject(CCString:create(picture),"picture")

	return dict
end

function getPayTypeParam( ... )
	return 13
end
function getPayMoneyDesc( ... )
	return GetLocalizeStringBy("bx_1000")
end
function getLogoLayer( ... )
    return nil
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

kLoginsStateNotLogin="0"
kLoginsStateUDIDLogin="1"
kLoginsStateZYXLogin="2"

function getLoginState( ... )
    if(CCUserDefault:sharedUserDefault():getStringForKey("loginState") == nil or CCUserDefault:sharedUserDefault():getStringForKey("loginState") == "")then
        return kLoginsStateNotLogin
    end
    return CCUserDefault:sharedUserDefault():getStringForKey("loginState")
end

kLoginsTypeKLLogin="KL"
kLoginsTypeFBLogin="FB"
kLoginsTypeFTLogin="FT"

function getLoginType( ... )
    if(CCUserDefault:sharedUserDefault():getStringForKey("loginType") == nil or CCUserDefault:sharedUserDefault():getStringForKey("loginType") == "")then
        return kLoginsTypeKLLogin
    end
    return CCUserDefault:sharedUserDefault():getStringForKey("loginType")
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