-- Filename: config_kimi.lua
-- Author: lei yang
-- Date: 2014-2-20
-- Purpose: android kimi 平台配置
module("config", package.seeall)

local g_web_domain_name = "http://apitest.fun.kimi.com.tw/"--"http://api.fun.kimi.com.tw/"
local g_web_domain_name_debug = "http://210.73.215.68/"
local g_web_download_url = "http://f-tw.kimi.com.tw/twnsg/"

loginInfoTable = {}

function getFlag( ... )
	return "kmphone"
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
 	return "tw"
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
 	return g_web_domain_name.. "phone/adshow?pl=kmphone&os=android&gn=sanguo&version="
end 

function getAppId( ... )
	return "104964"
end

function getAppKey( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end

function getName( ... ) 
	return "社區福利"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
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
	local feed = "放開那三國"
	local caption = "《放開那三國》新派卡牌，讓我先來！"
	local description = "超萌的Q版畫風，幽默詼諧的劇情，怪蜀黎、小正太、軟妹子輪番登場，開啟不同尋常的三國之旅。"
	local link = "http://click.adzcore.com/1.0.cc27e553a0f66cbc3bea7be17800b651c"
	local picture = "http://static.kimi.com.tw/web/nsg/fb_nsg_icon.png"

	dict:setObject(CCString:create(feed),"feed")
	dict:setObject(CCString:create(caption),"caption")
	dict:setObject(CCString:create(description),"description")
	dict:setObject(CCString:create(link),"link")
	dict:setObject(CCString:create(picture),"picture")

	return dict
end

function getPayTypeParam( ... )
	return 4
end
function getPayMoneyDesc( ... )
    return GetLocalizeStringBy("key_1031")
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
 	return g_web_domain_name_debug .. "phone/serverlistnotice/?pl=kmphone&gn=sanguo&os=android"
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
	return "104964"
end

function getAppKey_debug( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end