-- Filename: config_duoku.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: 多酷平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "dkphone"
end


function getName( ... )
	return GetLocalizeStringBy("key_1176")
end

function getAppId( ... )
	return "5179367"
end

function getAppKey( ... )
	return "8T34vpISp25GBSbbUTYPVWsM"
end

function getAppId_dk( ... )
	return "1711"
end

function getAppKey_dk( ... )
	return "f72a6ba29774758db5eb64a2ff321d1c"
end

--调试模式 
--1：RELEASE 2：DEBUG
function setDomain( ... )
	return "1"
end

--true为竖屏
function isOritationPort( ... )
	return "true"
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getAppId_dk()),"appId_dk")
	dict:setObject(CCString:create(getAppKey_dk()),"appKey_dk")
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getAppKey()),"appKey")
	dict:setObject(CCString:create(setDomain()),"setDomain")
	dict:setObject(CCString:create(isOritationPort()),"isOritationPort")
	return dict
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&action=newsdk" .. Platform.getUrlParam() .. "&bind=" .. g_dev_udid
 	return postString
end 

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create("金币"),"productName")
	return dict
end

function setLoginInfo( xmlTable )
	loginInfoTable.uid = xmlTable:find("uid")[1]
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
	local postString = url .. "?sid=" .. sessionid .. "&action=newsdk" .. Platform.getUrlParam() .. "&bind=" .. g_dev_udid
 	return postString
end 
