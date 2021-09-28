-- Filename: config_360.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: 奇虎360平台配置
module("config", package.seeall)





local loginInfoTable = {}

function getFlag( ... )
	return "360phone"
end
function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?" .. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?code=" .. sessionid .."&bind=" .. g_dev_udid .. Platform.getUrlParam()
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "104964"
end

function getAppKey( ... )
	return "07b68523759147d46ff30ba8f4aef42779a89b1b727a3528"
end

function getName( ... )
	return GetLocalizeStringBy("key_1327")
end

function getPayParam( coins )
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	print_t("",loginInfoTable)
	dict:setObject(CCString:create(loginInfoTable.access_token),"access_token")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(loginInfoTable.userid),"userid")
	dict:setObject(CCString:create(loginInfoTable.uname),"username")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	return dict
end

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.access_token = xmlTable:find("access_token")[1]
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.userid = xmlTable:find("userid")[1]
	loginInfoTable.uname = xmlTable:find("uname")[1]
	print_table("",loginInfoTable)
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?code=" .. sessionid .."&bind=" .. g_dev_udid .. Platform.getUrlParam()
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end
