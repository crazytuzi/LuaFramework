-- Filename: config_Android_taiguo.lua
-- Author: kun liao
-- Date: 2014-7-31

module("config", package.seeall)
local g_web_domain_name = "http://api.ss.siamgame.in.th/"--"http://api.fun.kimi.com.tw/"
--local g_web_domain_name = "http://103.29.189.121/"
local g_web_domain_name_debug = "http://103.29.189.121/"
--local g_web_domain_name_debug = "http://apitest.ss.siamgame.in.th/"
local g_web_download_url = "http://f.siamgame.in.th/ss/"

loginInfoTable = {}

function getFlag( ... )
	return "thailine"
end
function getServerListUrl( ... )
 	return g_web_domain_name.."phone/serverlistnotice/?".. Platform.getUrlParam()
end  

function getPidUrl( sessionid )
	local url = g_web_domain_name.."phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .. "&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
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

function getHashUrl( )
 	return g_web_domain_name.."phone/getHash/"
end 

function getAdShowUrl( ... )
 	return g_web_domain_name.. "phone/adshow?pl=kmgpphone&os=android&gn=sanguo&version="
end 

function getAppId( ... )
	return "1"
end

function getAppKey( ... )
	return "1"
end

function getName( ... ) 
	return "เฟสบุ๊คแฟนเพจ"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
    local checkUrl = nil
    if Platform.isDebug() then
        checkUrl = "http://103.29.189.121/phone/linecoin"
    else
        checkUrl = "";
    end
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(UserModel.getGoldNumber()),"appUgold")
    dict:setObject(CCString:create(checkUrl),"ckeckUrl")
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
    return 11
end
function getPayMoneyDesc( ... )
    return GetLocalizeStringBy("key_1031")
end
function getLogoLayer( ... )
    local logoParam = {}
    logoParam.needPlatformLogo  = true
    logoParam.logoName          = "images/logo/bt_line_logo.png"
    logoParam.bTlogoName        = "images/logo/line_logo.png"
    logoParam.scaleFunction     = "setAllScreenNode"
    return logoParam
end 
function getBgLayer( ... )
    return CCSprite:create("images/login/bg4.png")
end 
function getShareType( ... )
    return "Facebook"
end
function isNeedAdShow( ... )
    return false
end 
function isNeedUserSenter( ... )
    return true
end 
function isNeedInitPlGroup( ... )
    return true
end

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
--debug conifg
function getServerListUrl_debug( ... )
 	return g_web_domain_name_debug .. "phone/serverlistnotice/?pl="..getFlag().."&gn=sanguo&os=android"
end 

function getPidUrl_debug( sessionid )
	local url = g_web_domain_name_debug.."phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .."&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getDomain_debug( ... )
 	return g_web_domain_name_debug
end 

function getAppId_debug( ... )
	return "1"
end

function getAppKey_debug( ... )
	return "1"
end
