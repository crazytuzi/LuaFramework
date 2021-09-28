-- Filename: Platform.lua
-- Author: baoxu
-- Date: 2014-03-13
-- Purpose: PPS 平台接入数据定义
module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "ppsphone"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?sign=" .. sessionid ..  "&uid=" .. Platform.sdkLoginInfo.uid.."&time="..Platform.sdkLoginInfo.time..Platform.getUrlParam().. "&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function getAppId( ... )
	return "482"
end	

function getAppKey( ... )
	return "74974bf301ff7e270d0e1e6860735f38"
end

function getName( ... )
	return "PPS社区"
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
	local url = "http://124.205.151.82/phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?sign=" .. sessionid.."&uid=" .. Platform.sdkLoginInfo.uid.."&time=" ..Platform.sdkLoginInfo.time.. Platform.getUrlParam().."&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "482"
end

function getAppKey_debug( ... )
	return "74974bf301ff7e270d0e1e6860735f38"
end
