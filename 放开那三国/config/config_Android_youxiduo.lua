-- Filename: config_Android_youxiduo.lua
-- Author: lichenyangsdk
-- Date: 2016-5-13
-- Purpose: 游戏多 平台接入数据定义
module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "youxiduo"
end

function getName( ... )
	return "游戏多"
end

function getAppId( ... )
	return "WTTIw76KOcnJ"
end	

function getCompanyId( ... )
	return "m3zrD2IsDXmb"
end

function getPrivateKey( ... )
	return "MIIBVQIBADANBgkqhkiG9w0BAQEFAASCAT8wggE7AgEAAkEAxQtUWVT8nXQn7zHEGI9q7wRZFb+OhbY0fgmDwWXvxsWqUmxQgyANb/qyST915MLyyxUtVEmCXewZnaq3WqwXmQIDAQABAkBhg27V2sI9ZcuRi05hXTBtYvh3U9pDf91QdoL2xey4sCDVHB/LLXdw6i/fYtPvcmutO3JGjU7CQIwfRv9cDLuBAiEA8tLJVFhrG++AxNwBvU653bMX0ZvK51Ex3bRCghCDZTECIQDPvJidN5osM1bJ4xS6qOnG6hLxMbKmo/Fhfh0pm31e6QIhAOmBRdX0SNvOTvf/0TRodlf5lxgcRtx2ugtHAwXsN06hAiADA7KXPXJQR+JvhYsMdl0GFOl3dIgqIODk0EauDuKP2QIhAIF81g3uVX8MNEjG6P94/6byIXfq/CwjfpZTmE2Ql2d7"
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getCompanyId()),"companyId")
	dict:setObject(CCString:create(getPrivateKey()),"privateKey")
	return dict
end


function getPidUrl( userid )
	local url = Platform.getDomain() .. "phone/login/"
	local sign = BTUtil:getMd5SumByString("userid=" .. userid .. "&babelTime")
	local postString = url .. "?userid=" .. userid .. "&sign=" .. sign .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
	print("loginUrl = ",postString)
 	return postString
end 

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create("金币"),"productName")
	dict:setObject(CCString:create("放开那三国金币充值"),"productDesc")
	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

--debug conifg

function getPidUrl_debug( userid )
	local url = "http://192.168.1.38/phone/login/"
	local sign = BTUtil:getMd5SumByString("userid=" .. userid .. "&babelTime")
	local postString = url .. "?userid=" .. userid .. "&sign=" .. sign .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
	print("loginUrl = ",postString)
 	return postString
end 
function getServerListUrl_debug( ... )
	local serverlistUrl = "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
 	return serverlistUrl
end 