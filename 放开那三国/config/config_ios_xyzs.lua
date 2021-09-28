-- Filename: config_ios_xyzs.lua
-- Author: baoxu
-- Date: 2014-07-24
-- Purpose: XYZS 平台接入数据定义
module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "xyzhushou"
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?token=" .. sessionid ..  "&userid=" .. Platform.sdkLoginInfo.uid..Platform.getUrlParam().. "&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 

function getAppId( ... )
	return "100000300"
end	

function getAppKey( ... )
	return "DvACUeeqGAiKG1v9u8LgGu28wuyPwMO3"
end

function getName( ... )
	return "XY社区"
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
	local postString = url .."?token=" .. sessionid.."&userid=" .. Platform.sdkLoginInfo.uid.. Platform.getUrlParam().."&bind=" .. g_dev_udid
	print("userid = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice?".. Platform.getUrlParam()
end         

function getAppId_debug( ... )
	return "100000300"
end

function getAppKey_debug( ... )
	return "DvACUeeqGAiKG1v9u8LgGu28wuyPwMO3"
end
