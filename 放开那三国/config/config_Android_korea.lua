-- Filename: config_91.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
platformName="zyxphone"
module("config", package.seeall)

local g_web_domain_name = "http://fknsgmapikh.zuiyouxi.com/"
local g_web_domain_name_debug = "http://khtest.zuiyouxi.com/"
local g_web_download_url = "http://cdn.khstatic.zuiyouxi.com/sanguo/"

loginInfoTable = {}

function getFlag( ... )
	printR("pl2=====",platformName)
	return platformName
end

function getKoreaOtherPl( ... )
	local otherPl = Platform.getSdk():callStringFuncWithParam("getKoreaOtherPl",nil)
	return otherPl
end

function getName( ... )
	return "커뮤니티"
end

function getLocalizedStrings( ... )
    return "script/localized/LocalizedStrings_kr"
end

function getDomain( ... )
 	return g_web_domain_name
end

function getDomain_debug( ... )
 	return g_web_domain_name_debug
end 

function getDownUrl( ... )
	return g_web_download_url
end

function getHashUrl( )
 	return g_web_domain_name .. "phone/getHash/"
end

function getGsFont( ... )
    local gsFontTable = {}
    gsFontTable.fontName    = "fonts/korea_talk.ttf"
    gsFontTable.fontPangWa  = "fonts/korea_effect.ttf"
    return gsFontTable
end 

function getHWGameName( ... )
	return "sanguo"
end

function getZYXUrlParam( ... )
  return "pl=zyxphone&gn=" .. getHWGameName() .. "&os=android"
end

function getFacebookUrlParam( token )
  return "pl=facebook&gn=" .. getHWGameName() .. "&os=android" .. "&token=" .. token
end

function getGoogleUrlParam( token )
  return "pl=google&gn=" .. getHWGameName() .. "&os=android" .. "&token=" .. token
end

function getTwitterUrlParam( token )
  return "pl=twitter&gn=" .. getHWGameName() .. "&os=android" .. "&token=" .. token
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	return dict
end

function getServerListUrl( ... )
 	return g_web_domain_name .. "phone/serverlistnotice/?" .. getZYXUrlParam()
end 

function getServerListUrl_debug( ... )
 	return g_web_domain_name_debug .. "phone/serverlistnotice/?" .. getZYXUrlParam()
end 

function getLayout( ... )
    return "enLayout"
end

function getPidUrl( token )
	local url = g_web_domain_name .. "phone/login?"
	if getLoginType() == kLoginsTypeFBLogin then
		url = url .. getFacebookUrlParam(token)
	elseif getLoginType() == kLoginsTypeGoogleLogin then
		url = url .. getGoogleUrlParam(token)
	elseif getLoginType() == kLoginsTypeTwitterLogin then
		url = url .. getTwitterUrlParam(token)
	end	
	return url
end 

function getPidUrl_debug( token )
	local url = g_web_domain_name_debug .. "phone/login?"
	if getLoginType() == kLoginsTypeFBLogin then
		url = url .. getFacebookUrlParam(token)
	elseif getLoginType() == kLoginsTypeGoogleLogin then
		url = url .. getGoogleUrlParam(token)
	elseif getLoginType() == kLoginsTypeTwitterLogin then
		url = url .. getTwitterUrlParam(token)
	end	
	return url
end 

function getLoginUrl( username,password )
	return g_web_domain_name .. "phone/login/?" .. getZYXUrlParam() .. "&action=login&username=" .. username .. "&password=" .. password .. "&bind=" .. g_dev_udid
end

function getLoginUrl_debug( username,password )
	return g_web_domain_name_debug .. "phone/login/?" .. getZYXUrlParam() .. "&action=login&username=" .. username .. "&password=" .. password .. "&bind=" .. g_dev_udid
end

function getRegisterUrl( )
	local registerUrl 
	if  Platform.isDebug() then
		registerUrl = g_web_domain_name_debug .. "phone/login/?action=register&" .. getZYXUrlParam()
	else
		registerUrl = g_web_domain_name .. "phone/login/?action=register&" .. getZYXUrlParam()
	end
	return registerUrl
end

function getChangePasswordUrl( )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = g_web_domain_name_debug .. "phone/login/?" .. getZYXUrlParam() .. "&action=renewpass"
	else
		renewpassUrl = g_web_domain_name .. "phone/login/?" .. getZYXUrlParam() .. "&action=renewpass"
	end
	return renewpassUrl
end

function getPayParam( coins )
	local payUrl
	if  Platform.isDebug() then
		payUrl = g_web_domain_name_debug .. "phone/exchange"
	else
		payUrl = g_web_domain_name .. "phone/exchange"
	end
	local gn = getHWGameName()
	local os = Platform.getOS()
	local pl = getLoginType()
	local pid = Platform.getPid()
	local group = CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")
	if pl == kLoginsTypeZYXLogin then
		pl = getFlag()
	end

	local korea_otherpl = getKoreaOtherPl()
	local choseProductCode = getChoseProductCode(korea_otherpl,coins)

	local dict = CCDictionary:create()
	dict:setObject(CCString:create(payUrl),"payUrl")
	dict:setObject(CCString:create(pid),"pid")
	dict:setObject(CCString:create(group),"group")
	dict:setObject(CCString:create(gn),"gn")
	dict:setObject(CCString:create(os),"os")
	dict:setObject(CCString:create(pl),"pl")
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(korea_otherpl),"korea_otherpl")
	dict:setObject(CCString:create(choseProductCode),"choseProductCode")
	return dict
end

local naverPayTable = {
    coin_100 = "1000015541",
    coin_300 = "1000015542",
    coin_500 = "1000015543",
    coin_1000 = "1000015544",
    coin_2000 = "1000015545",
    coin_3000 = "1000015750",
}

function getChoseProductCode( korea_otherpl, coins )
	local choseProductCode
	local index = "coin_" .. coins
	if korea_otherpl == "naver" then
		choseProductCode = naverPayTable[index]
	elseif korea_otherpl == "google" then
	elseif korea_otherpl == "tstore" then
	end
	return choseProductCode
end

function getPayTypeParam( ... )
	return 20
end

function getPayMoneyDesc( ... )
	return GetLocalizeStringBy("key_1782")
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

kLoginsTypeZYXLogin="zyx"
kLoginsTypeFBLogin="facebook"
kLoginsTypeGoogleLogin="google"
kLoginsTypeTwitterLogin="twitter"
function getLoginType( ... )
	if(CCUserDefault:sharedUserDefault():getStringForKey("loginType") == nil or CCUserDefault:sharedUserDefault():getStringForKey("loginType") == "")then
		return kLoginsTypeZYXLogin
	end
	return CCUserDefault:sharedUserDefault():getStringForKey("loginType")
end

function login( ... )
	require "script/ui/login/kr/KRLoginLayer"
	local loginState = getLoginState()
	if(loginState == kLoginsStateNotLogin)then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_1393"), nil)
        KRLoginLayer.createLoginLayer()
    elseif(loginState == kLoginsStateUDIDLogin)then
    elseif(loginState == kLoginsStateZYXLogin)then       
        local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
	    local password = CCUserDefault:sharedUserDefault():getStringForKey("password")
	    local loginType = getLoginType()
        if(loginType == kLoginsTypeZYXLogin)then
	        KRLoginLayer.loginWithUserNameInfo(username, password, false);
        else
        	loginWithSession(username, password, loginType)
        end
    end
end

function loginWithSession( username, password, loginType )
	if password == nil or password == "" then
       require "script/ui/tip/AlertTip"
       AlertTip.showAlert(GetLocalizeStringBy("key_3005"), nil, false, nil)
       return
    end
	CCUserDefault:sharedUserDefault():setStringForKey("username",username)
	CCUserDefault:sharedUserDefault():setStringForKey("password",password)
	CCUserDefault:sharedUserDefault():setStringForKey("loginState",Platform.getConfig().kLoginsStateZYXLogin)
	CCUserDefault:sharedUserDefault():setStringForKey("loginType",loginType)
	CCUserDefault:sharedUserDefault():flush()
	  
	LoginScene.changeUserName(username)
	Platform.getPidBySessionId(password)
end

function logout( ... )
	CCUserDefault:sharedUserDefault():setStringForKey("username","")
	CCUserDefault:sharedUserDefault():setStringForKey("password","")
	CCUserDefault:sharedUserDefault():setStringForKey("loginState",kLoginsStateNotLogin)
	CCUserDefault:sharedUserDefault():setStringForKey("loginType",kLoginsTypeZYXLogin)
	CCUserDefault:sharedUserDefault():flush()
	Platform.setPid(nil)
	local scene = CCDirector:sharedDirector():getRunningScene()
 	local node = CCNode:create()
    scene:addChild(node)
    node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(function ( ... )
         LoginScene.enter()
    end)))
end

function gotoUserCenter( ... )
	require "script/ui/login/kr/KRLoginLayer"
	local loginState = getLoginState()
	if(loginState == kLoginsStateNotLogin)then
        KRLoginLayer.createLoginLayer()
    elseif(loginState == kLoginsStateUDIDLogin)then
    	KRLoginLayer.createLoginLayer()
    elseif(loginState == kLoginsStateZYXLogin)then       
        local loginType = getLoginType()
        if(loginType == kLoginsTypeZYXLogin)then
	        KRLoginLayer.createLoginLayer()
        else
        	local nowLoginType = getLoginType()
        	KRLoginLayer.gotoHWLogin(loginType, nowLoginType)
        end
    end
end

function loginFailedTip( errornu )
	require "script/ui/tip/AlertTip"
	if(errornu == "1" or errornu == "1020") then
		logout()
    	AlertTip.showAlert(GetLocalizeStringBy("lcysdk_1006"), nil)
    else
        AlertTip.showAlert(GetLocalizeStringBy("key_1414"), nil)
	end
end

