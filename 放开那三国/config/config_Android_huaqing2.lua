-- Filename: config_Android_huaqing.lua
-- Author: kun liao
-- Date: 2014-06-13
-- Purpose: android 华清 平台配置
module("config", package.seeall)

loginInfoTable = {}
function getFlag( ... )
	return "huaqing2"
end


function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
	local action = Platform.sdkLoginInfo.action
	local mid = Platform.sdkLoginInfo.mid
	if(action == "phoneQQAc")then
		local openid = Platform.sdkLoginInfo.openid
		local openkey = Platform.sdkLoginInfo.token
		local userip = Platform.sdkLoginInfo.ip
		local postString = url .. "?openid=" .. openid.."&openkey="..openkey.."&userip="..userip.."&action="..action..Platform.getUrlParam().."&bind=" .. mid
		return postString
 	elseif (action == "weixinAc")then
 		local openid = Platform.sdkLoginInfo.openid
 		local accessToken = Platform.sdkLoginInfo.accessToken
		local postString = url .. "?accessToken=" .. accessToken.."&action="..action.."&openid="..openid..Platform.getUrlParam().."&bind=" .. mid
		return postString
 	end
end 

function getQQAppId( ... )
	return "1101488869"
end

function getQQAppKey( ... )
	return "7G7agaqwhMTlchfU"
end
function getWxAppId( ... )
	return "wx2f7b2b96cafc9c0e"
end

function getWxAppKey( ... )
	return "86436165f0e8c309c39bde7bf252d5a7"
end

-- function setPram( ... )
-- 	local dict = CCDictionary:create()
--     dict:setObject(CCString:create(config.getQQAppId()),"qqAppId")
--     dict:setObject(CCString:create(config.getQQAppKey()),"qqAppKey")
--     dict:setObject(CCString:create(config.getWxAppId()),"wxAppId")
--     dict:setObject(CCString:create(config.getWxAppKey()),"wxAppKey")
--     protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
-- end
function getName( ... )
	return "退出登录"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
    dict:setObject(CCString:create(coins),"coins")
    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
    dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
 	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    return dict
end

--debug conifg
function getServerListUrl_debug( ... )
    return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
	local action = Platform.sdkLoginInfo.action
	if(action == "phoneQQAc")then
		local openid = Platform.sdkLoginInfo.openid
		local openkey = Platform.sdkLoginInfo.token
		local userip = Platform.sdkLoginInfo.ip
		local postString = url .. "?openid=" .. openid.."&openkey="..openkey.."&userip="..userip.."&action="..action..Platform.getUrlParam().."&bind=" .. g_dev_udid
		return postString
 	elseif (action == "weixinAc")then
 		local openid = Platform.sdkLoginInfo.openid
 		local accessToken = Platform.sdkLoginInfo.accessToken
		local postString = url .. "?accessToken=" .. accessToken.."&action="..action.."&openid="..openid..Platform.getUrlParam().."&bind=" .. g_dev_udid
		return postString
 	end
end
function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
	loginInfoTable.newuser = xmlTable:find("newuser")[1]
end
function getAppId_debug( ... )
    return "1101488869"
end

function getAppKey_debug( ... )
    return "7G7agaqwhMTlchfU"
end

function getUserInfoParam(gameState)
	require "script/model/user/UserModel"
    require "script/ui/login/ServerList"
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
    dict:setObject(CCString:create(ServerList.getSelectServerInfo().name),"groupName")
    dict:setObject(CCString:create(loginInfoTable.newuser),"newuser")
    if(tonumber(gameState) == 1)then
	    -- 下面的appUid和appUname暂时获取不到，先不用
	    dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	    dict:setObject(CCString:create(UserModel.getUserName()),"appUname")
	    dict:setObject(CCString:create(UserModel.getUserUtid()),"appUtid")
	    dict:setObject(CCString:create(UserModel.getHeroLevel()),"appUlevel")
	end

	return dict
end

