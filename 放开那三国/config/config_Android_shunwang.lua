-- Filename: config_Android_lvan.lua
-- Author: jin lu lu
-- Date: 2015-3-2
-- Purpose: android 顺网 平台配置
module("config", package.seeall)
loginInfoTable = {}
function getFlag( ... )
	return "shunwang"
end


function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?ticket=" .. Platform.sdkLoginInfo.sid .. "&memberId=" .. Platform.sdkLoginInfo.uid .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId( ... )
	return "6015"
end

function getAppKey( ... )
	return "2411D975BD2646E3A599C355F6ADB8A9"
end

function getReasKey( ... )
	return "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAJ+MLV12UJOqFbfwqa9qZRwQ/qwbnFzC+hFyC2kochanY4UtYFvnXciEgl8il0a/AjAzCyKH0jYFmE9ZNo8XRFNrLQZ4UO6JalDJOq+MguIYKcwQn4229H8dwC6uhiuFf4S0gd7dcftIHLQtUZ7tdWfehjz9dRP8Vd4d3ZC7/3cPAgMBAAECgYAxhPuLl65YtqC5D5xLErXBKVEyL/uvGuEsyv3ZrLEEcP3FlxjiTYRhOSeRyZW0YpKWTTF2jTtkgwYMEr+JWApfbpzFz4+xT/Z6qPikOLkHMUHAIw6lSUA9UxRxeKPunZ+KvHxhTWA6h/zfDGhXmT7wt1nP13IVmy2dVUNoLiYr6QJBAO7kLZrLwqnENQDm9f0jdg+gAsr2ONqIWE4wyjWxUz803/Wz+YsQTuv4zIwku0hXYpEMmNdal1ZRNKP+pKqYjeUCQQCq+VCF9QUDohk41j7sU1QXoP0gX6O4+a4TKMoJB7MDxpFQJt1iK2f30RrZRrblfCKMKA9izcpsT7CZ101owMHjAkEA4tReSSE4kSHwgg7Le7T0IRn6DOWGTlowHu5M0naxaM636QEe7WBqz7zJ3Df0bFgtCzU+2xz1ncw1g5ICoMmB0QJAV81hROnngU4llcKw3byNWvUaCR4UflH6y2wPFUQW8sFurrLGzjtsUR/Zoetm0cNGGqQYAq2cXrMuBlNDNaCH8QJBAOO31z7Tvk3VjU+t1zEYl1+zUWssgcyoWHB3cup4n8G8aOPus5TIRZUNW3iQK77PelQqvZaogGBRAYXHRWGweFU="
end

function getName( ... )
	return "顺网"
end
function getInitParam(  )
	local dict = CCDictionary:create()
	local loginurl = nil
	dict:setObject(CCString:create("fknsg"),"game")
    dict:setObject(CCString:create(getAppId()),"appId")
    dict:setObject(CCString:create(getAppKey()),"appKey")
    dict:setObject(CCString:create(getReasKey()),"reasKey")
    --isDebug方法在初始化中不起作用，测试时再打开
 --    if not Platform.isDebug() then
 --    	loginurl = "http://124.205.151.82/phone/login/?pl=shunwang&gn=sanguo&os=android"
	-- else
		loginurl = Platform.getDomain() .. "phone/login/?pl=shunwang&gn=sanguo&os=android" 
	-- end
	dict:setObject(CCString:create(loginurl),"loginUrl")
	return dict
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	local groupid = CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")
	local callback = nil
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(Platform.getPid()),"pid")
	dict:setObject(CCString:create(""),"region")
	dict:setObject(CCString:create(getAppId()),"gameid")
	dict:setObject(CCString:create(UserModel.getUserName()),"username")
	dict:setObject(CCString:create(getReasKey()),"rsakey")
	if Platform.isDebug() then
		callback = "http://124.205.151.82/phone/exchange?pl=shunwang&gn=sanguo&os=android"
	else
		callback = "http://mapifknsg.zuiyouxi.com/phone/exchange?pl=shunwang&gn=sanguo&os=android"
	end
	dict:setObject(CCString:create(callback),"gamecallback")
	return dict
end

function getUserInfoParam(gameState)
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(Platform.sdkLoginInfo.newuser),"newuser")
    if(tonumber(gameState) == 1)then
	    -- 下面的appUid和appUname暂时获取不到，先不用
	    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getUserUtid()),"appUtid")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	end

	return dict
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
	loginInfoTable.guid = xmlTable:find("guid")[1]
	loginInfoTable.accesstoken = xmlTable:find("accessToken")[1]
	loginInfoTable.refreshtoken = xmlTable:find("refreshToken")[1]
end
function getGroupParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	return dict
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?ticket=" .. Platform.sdkLoginInfo.sid .. "&memberId=" .. Platform.sdkLoginInfo.uid .. Platform.getUrlParam() .."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return getAppId()
end

function getAppKey_debug( ... )
	return getAppKey()
end

 