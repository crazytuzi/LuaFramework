-- Filename: config_ios_kldny
-- Author: baoxu
-- Date: 2014-04-17
-- Purpose: 


module("config", package.seeall)

local g_web_domain_name = "http://api.fknsg.koramgame.com.my/"
local g_web_domain_name_debug = "http://api.fknsg.koramgame.com.my/"
local g_web_download_url = "http://f-ap.koramgame.com/fknsg/"

function getFlag( ... )
	return "dnyphone"
end

loginInfoTable = {}
function getServerListUrl( ... )
 	return "http://api.fknsg.koramgame.com.my/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://api.fknsg.koramgame.com.my/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .. Platform.getUrlParam().."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    return postString
end

function getDomain( ... )
 	return g_web_domain_name
end 

function getDownUrl( ... )
	return g_web_download_url
end

function getAdShowUrl( ... )
 	return "http://api.fknsg.koramgame.com.my/phone/adshow?"..Platform.getUrlParam().."&version="
end 

function getBbsUrl( ... )
 	return "http://api.fknsg.koramgame.com.my/innernews/"
end

function getHashUrl( )
 	return "http://api.fknsg.koramgame.com.my/phone/getHash/"
end 

function getAppId( ... )
	return "0"
end

function getAppKey( ... )
	return "qf5NaPn1J&Wj8wdSqfMBZO#1JWuj8FdS"
end

function getName( ... )
	return "玩家社区"
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
    local feed = "魔神三国志"
    local caption = "《魔神三国志》超人气S级三国卡牌大乱斗！"
    local description = "最精美搞笑呆萌的三国卡牌手游「魔神三国志」绚丽来袭！画面精美，剧情幽默，卡牌收集不费力，回合对战有新意。\n快来「魔神三国志」，炫爆你的眼球！"
    local link = "https://itunes.apple.com/my/app/mo-shen-san-guo-zhi/id893024560?l=zh&ls=1&mt=8"
    local picture = "http://mssgz.koramgame.com.my/icon.png"

    dict:setObject(CCString:create(feed),"feed")
    dict:setObject(CCString:create(caption),"caption")
    dict:setObject(CCString:create(description),"description")
    dict:setObject(CCString:create(link),"link")
    dict:setObject(CCString:create(picture),"picture")
    
	return dict
end

function getPayTypeParam( ... )
    return 6
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

--debug conifg

function getPidUrl_debug( sessionid )
	--local url = "http://124.205.151.82/phone/login"
	local url = "http://api.fknsg.koramgame.com.my/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?klsso=" .. sessionid .. Platform.getUrlParam().."&uid=" .. Platform.getSdk():callStringFuncWithParam("getUserId",nil) .. "&userName=" .. Platform.getSdk():callStringFuncWithParam("getUserName",nil) .. "&bind=" .. g_dev_udid
    print("userid = ",Platform.getSdk():callStringFuncWithParam("getUserId",nil))
 	return postString
end 

function getServerListUrl_debug( ... )
    --return "http://124.205.151.82/phone/serverlistnotice/?pl=kmphone&gn=sanguo&os=ios"
    return "http://api.fknsg.koramgame.com.my/phone/serverlistnotice?"..Platform.getUrlParam()
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