-- Filename: config_Android_kupai.lua
-- Date: 2017-3-10
-- Purpose: kupai config
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "kpaiphone"
end

function getName( ... )
	return "酷派社区"
end

function getAppId( ... )
	return "5000007520"
end

function getAppKey( ... )
	return "80311c552910432d97fd40a9b1a45eb5"
end

--应用私钥
function getPrivateKey( ... )
	return "RDJBMTAyNjQ0RUIyRDlCOTI4NzJDRjFGQzFBNTNCOUM5NDg4NTNFN01UVTJOelUzTlRnNE1UUTRNVFUyTURnM01Ea3JNVFUxT1RjeU9UYzFPVEF6T1RNMk9UazVOVGszTXpZd09EWTVPVE14TnpjNE9Ua3pPRGMz"
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getAppKey()),"appKey")
	dict:setObject(CCString:create("1"),"screentOrient") -- 1竖屏，2横屏
	return dict
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId", nil)
    end
	local postString = url .. "?sid=" .. sessionid .. Platform.getUrlParam() .. "&bind=" .. g_dev_udid
 	return postString
end 

function getPidUrl_debug( sessionid )
	local url = "http://mapifknsg.staging.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. Platform.getUrlParam() .. "&bind=" .. g_dev_udid
 	return postString
end 

function setLoginInfo( jsonTable )
	loginInfoTable.uid = jsonTable:find("uid")[1]
 	loginInfoTable.newuser = jsonTable:find("newuser")[1]
 	loginInfoTable.token = jsonTable:find("access_token")[1]
 	loginInfoTable.openid = jsonTable:find("openid")[1]
 	loginInfoTable.expires_in = jsonTable:find("expires_in")[1]
 	loginInfoTable.refresh_token = jsonTable:find("refresh_token")[1]
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(Platform.getPid()),"pid")
	dict:setObject(CCString:create(loginInfoTable.token),"token")
 	dict:setObject(CCString:create(loginInfoTable.openid),"openid")
 	dict:setObject(CCString:create(getPrivateKey()),"privateKey")
 	dict:setObject(CCString:create(loginInfoTable.expires_in),"expires_in")
 	dict:setObject(CCString:create(loginInfoTable.refresh_token),"refresh_token")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	local waresid
	if(coins == 100)then
		waresid = 1
	elseif(coins == 300)then
			waresid = 2
	elseif(coins == 500)then
		waresid = 3
	elseif(coins == 1000)then
		waresid = 4
	elseif(coins == 2000)then
		waresid = 5
	elseif(coins == 5000)then
		waresid = 6
	elseif(coins == 10000)then
		waresid = 7
	elseif(coins == 20000)then
		waresid = 8
	end
	dict:setObject(CCString:create(waresid),"waresid")
	return dict
end

function getUserInfoParam( gameState )
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    if(tonumber(gameState) == 1)then
        dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	    dict:setObject(CCString:create(UserModel.getGoldNumber()),"appUgold")
	    dict:setObject(CCString:create(UserModel.getVipLevel()),"appUvip")
	    dict:setObject(CCString:create(UserModel.getFightForceValue()),"appPower")
	end
	return dict
end