-- Filename: config_ios_kldny
-- Author: baoxu
-- Date: 2014-04-17
-- Purpose: 
--[[
hi :
线上后台:              	http://api.ss.siamgame.in.th/admincp/admin/login
线上服务器列表:      		http://api.ss.siamgame.in.th/phone/serverlistnotice?pl=thaiphone&gn=sanguo&os=ios
线上登录:              	http://api.ss.siamgame.in.th/phone/login
 
线下后台:               	http://apitest.ss.siamgame.in.th/admincp/admin/login
线下服务器列表:      		http://apitest.ss.siamgame.in.th/phone/serverlistnotice?pl=thaiphone&gn=sanguo&os=ios
线下登录:             	http://apitest.ss.siamgame.in.th/phone/login
--]]

module("config", package.seeall)

local g_web_domain_name = "http://api.ss.siamgame.in.th/"
local g_web_domain_name_debug = "http://apitest.ss.siamgame.in.th/"
local g_web_download_url = "http://f.siamgame.in.th/ss/"

function getFlag( ... )
	return "thaiphone"
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
 	return "th"
end 

function getDomain( ... )
 	return g_web_domain_name
end 

function getDownUrl( ... )
	return g_web_download_url
end

function getAdShowUrl( ... )
 	return g_web_domain_name.. "phone/adshow?pl=thaiphone&os=ios&gn=sanguo&version="
end 

function getBbsUrl( ... )
 	return "http://api.fknsg.koramgame.com.my/innernews/"
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
	return "เฟสบุ๊คแฟนเพจ"
	--return "FB粉丝页"
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
    local feed = "Super Samkok"
    local caption = "เกมมือถือน่าเล่นที่สุดในประวัติศาสตร์「Super Samkok」!"
    local description = "แบบตัวละครขุนพลสวยงาม,เอฟเฟคสกิลตระการตา,สงครามประวัติศาสตร์หวนคืนสมจริง!\n[Super Samkok]รีบเชิญขุนพลชั้นยอดของท่านออกมา,ให้โลกขนานนามท่านว่าราชา!"
    local link = "http://mobi.siamgame.in.th/ss/lp/dl"
    local picture = "http://static.koramgame.com/web/siamgame/ss/supersamk.jpg"

    dict:setObject(CCString:create(feed),"feed")
    dict:setObject(CCString:create(caption),"caption")
    dict:setObject(CCString:create(description),"description")
    dict:setObject(CCString:create(link),"link")
    dict:setObject(CCString:create(picture),"picture")

	return dict
end

function getPayTypeParam( ... )
    return 10
end
function getPayMoneyDesc( ... )
	return GetLocalizeStringBy("key_1031")
end
function getLogoLayer( ... )
    local logoParam = {}
    logoParam.needPlatformLogo  = false
    logoParam.logoName          = nil
    logoParam.bTlogoName        = "images/logo/thailand_logo.png"
    logoParam.scaleFunction     = "setAdaptNode"
    return logoParam
end 
function getBgLayer( ... )
    return CCSprite:create("images/login/bg4.png")
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