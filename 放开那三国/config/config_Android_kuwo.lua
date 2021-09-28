-- Filename: config_Android_kuwo.lua
-- Author: baoxu
-- Date: 2014-3-24
-- Purpose: kuwo 平台接入数据定义
module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "kwphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?sign=" .. sessionid ..  "&userid=" .. Platform.sdkLoginInfo.uid.."&timestamp="..Platform.sdkLoginInfo.time..Platform.getUrlParam().. "&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "21"
end	

function getAppKey( ... )
	return "mg_21_login"
end

function getName( ... )
	return "酷我社区"
end


function getPayParam( coins )
	require "script/model/user/UserModel"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
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

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end

--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://192.168.1.38/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?sign=" .. sessionid.."&userid=" .. Platform.sdkLoginInfo.uid.."&timestamp=" ..Platform.sdkLoginInfo.time.. Platform.getUrlParam().."&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://192.168.1.38/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "21"
end

function getAppKey_debug( ... )
	return "mg_21_login"
end
