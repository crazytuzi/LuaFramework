-- Filename: config_Android_taiguo.lua
-- Author: kun liao
-- Date: 2014-7-31

module("config", package.seeall)
-- local g_web_domain_name = "http://42.62.23.82/"--"http://api.fun.kimi.com.tw/"
local g_web_domain_name = "http://api.omgtamquoc.mobilegamevn.com/"
local g_web_domain_name_debug = "http://42.62.23.82/"
local g_web_download_url = "http://static.mobilegamevn.com/omgtamquoc/sanguo/"

loginInfoTable = {}

function getFlag( ... )
	return "vmgly"
end
function getServerListUrl( ... )
 	return g_web_domain_name.."phone/serverlistnotice/?".. Platform.getUrlParam()
end  

function getPidUrl( sessionid )
	local url = g_web_domain_name.."phone/login/"
	local postString = url .. "?klsso=" .. sessionid .. "&time=".. BTUtil:getSvrTimeInterval() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getLanguage( ... )
    return "vn"
end 

function getLocalizedStrings( ... )
    return "script/localized/LocalizedStrings_vn"
end 

function getGsFont( ... )
    local gsFontTable = {}
    gsFontTable.fontName    = "fonts/tahoma.ttf"
    gsFontTable.fontPangWa  = "fonts/uvn.ttf"
    -- gsFontTable.fontPangWa  = "fonts/UVNNguyenDu_1.TTF"
    return gsFontTable
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
	return "104964"
end

function getAppKey( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end

function getName( ... ) 
	return "Đổi tài khoản"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    if(tonumber(coins) == 0)then
        dict:setObject(CCString:create("kunlun"),"channel")
    else
        dict:setObject(CCString:create(""),"channel")
    end
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
    local feed = "OMG ! Tam Quốc !"
    local caption = "Game SRPG Tam Quốc Dí Dỏm !"
    local description = "Tuyệt tác GMO thẻ tướng Tam Quốc với phong cách manga cực cute ! \nNội dung độc đáo, thẻ tướng phong phú, kỹ năng đặc sắc, hãy trải nghiệm một Tam Quốc hoàn toàn khác biệt, đỉnh cao 2015 !"
    local link = "https://play.google.com/store/apps/details?id=com.vn.ggplay.omgsgcbt"
    local picture = "http://omgkingdom.koramgame.com/icon.png"

    dict:setObject(CCString:create(feed),"feed")
    dict:setObject(CCString:create(caption),"caption")
    dict:setObject(CCString:create(description),"description")
    dict:setObject(CCString:create(link),"link")
    dict:setObject(CCString:create(picture),"picture")

	return dict
end

function getPayTypeParam( ... )
    return 16
end
-- function getPayChannel( ... )
--     return "kunlun"
-- end
function getPayMoneyDesc( ... )
    return GetLocalizeStringBy("bx_1001")
end
function getLogoLayer( ... )
    local logoParam = {}
    logoParam.needPlatformLogo  = true
    logoParam.logoName          = "images/logo/vietnam_logo.png"
    logoParam.bTlogoName        = "images/login/bt_logo.png"
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
    return false
end 
function isNeedUserSenter( ... )
    return true
end 
function isNeedInitPlGroup( ... )
    return true
end
function getLayout( ... )
    return "enLayout"
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
	return "104964"
end

function getAppKey_debug( ... )
	return "r0bC40WXQ8uVSJjRjWLMY9rB"
end
