-- Filename: config_PP.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: PP平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "haima"
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?uid=" .. sessionid .. Platform.getUrlParam().. "&bind=" .. g_dev_udid
 	return postString
end 

function getAppId( ... )
	return "300031439"
end

function getAppKey( ... )
	return "MIICXQIBAAKBgQC8xk1sfdy9LT4vJx4Z+bY1BVBSzcotESE75E1ewgDNHnFno39VlQtZOR7/zLvU0RzWGCo5fzQRUarG7ocef9f4lgAyBs6we0Gob50ztcRMh07xDXxPqGiQusqi3hlcanbZlIHSvtvk123/07j0uUz4lvBRWExv2pjib4S07NuKoQIDAQABAoGBAKQy5POCgve2G8nN/7veXeO+jICJ6drLdJnw2m+a1jGU0lWwfDjH3MguDE26GoNhpPCAsnGyuGp8G8zPe45G62Yao+FGARTYcRHfUwK82sisrYUsT9Vl+vQqbvjd/nvAz7537cNpGNGePCg9gyqVchF1UtxluwaYxSS9y3I9K2HBAkEA6Ha3ahdQQUJerlEbS0CYkmXUD6weQ+N76rhv1mYE8vVJcEpxIR4TgLqbztbU37tZGN59NIBk2Q/qmUWParbM+QJBAM/jMn1p4fpV5Zy4TT8xi5Yk5oAcO6jXgWLMq7+TgLa8HQCgHEvZnyvb9EsIZRY5PmvbndfORNubSvwnKAU93OkCQQCU0gux26MBZGAA8OOsVXpXnuEX93SYubXHGrReaYmZkPam8MFkFkEeFFlTHa3CXco4ZZd6WQg2/j2OSj36b3ThAkA1fmEfpH9hy3iqO0KlYDprCFPH43v2ln3UzpXjVjFo1D8iShD986Hhx1e1dxOMBG7rkjersIhHek5xVCIYNzMBAkAdizKKes/o42zok96wKNVHEl8PV7sal1Ke+7ZEG7p4LqQL38OIdKojPM8xK1BFNp5ehcGHZVEzPLFor8yDMZPA"
end

function getName( ... )
	return "海马社区"
end

function getPayParam( coins )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getAppKey()),"privateKey")
	if(Platform.isDebug())then
		dict:setObject(CCString:create("http://124.205.151.82/phone/exchange?pl=haima&gn=sanguo&os=ios"),"notifyurl")
	else
		dict:setObject(CCString:create("http://mapifknsg.zuiyouxi.com/phone/exchange?pl=haima&gn=sanguo&os=ios"),"notifyurl")

	end
	dict:setObject(CCString:create(coins .. "金币"),"waresName")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(loginInfoTable.uid),"pid")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	print("getPayParam",loginInfoTable.uid)
	return dict 
end

function setLoginInfo( xmlTable )
	print("setLoginInfo")
	loginInfoTable.uid = xmlTable:find("uid")[1]
	print_table("",loginInfoTable)
end
 
--debug conifg

function getPidUrl_debug( sessionid )
	local url = "http://124.205.151.82/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?uid=" .. sessionid .. Platform.getUrlParam().. "&bind=" .. g_dev_udid
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getAppId_debug( ... )
	return "300031439"
end

function getAppKey_debug( ... )
	return "MIICXQIBAAKBgQC8xk1sfdy9LT4vJx4Z+bY1BVBSzcotESE75E1ewgDNHnFno39VlQtZOR7/zLvU0RzWGCo5fzQRUarG7ocef9f4lgAyBs6we0Gob50ztcRMh07xDXxPqGiQusqi3hlcanbZlIHSvtvk123/07j0uUz4lvBRWExv2pjib4S07NuKoQIDAQABAoGBAKQy5POCgve2G8nN/7veXeO+jICJ6drLdJnw2m+a1jGU0lWwfDjH3MguDE26GoNhpPCAsnGyuGp8G8zPe45G62Yao+FGARTYcRHfUwK82sisrYUsT9Vl+vQqbvjd/nvAz7537cNpGNGePCg9gyqVchF1UtxluwaYxSS9y3I9K2HBAkEA6Ha3ahdQQUJerlEbS0CYkmXUD6weQ+N76rhv1mYE8vVJcEpxIR4TgLqbztbU37tZGN59NIBk2Q/qmUWParbM+QJBAM/jMn1p4fpV5Zy4TT8xi5Yk5oAcO6jXgWLMq7+TgLa8HQCgHEvZnyvb9EsIZRY5PmvbndfORNubSvwnKAU93OkCQQCU0gux26MBZGAA8OOsVXpXnuEX93SYubXHGrReaYmZkPam8MFkFkEeFFlTHa3CXco4ZZd6WQg2/j2OSj36b3ThAkA1fmEfpH9hy3iqO0KlYDprCFPH43v2ln3UzpXjVjFo1D8iShD986Hhx1e1dxOMBG7rkjersIhHek5xVCIYNzMBAkAdizKKes/o42zok96wKNVHEl8PV7sal1Ke+7ZEG7p4LqQL38OIdKojPM8xK1BFNp5ehcGHZVEzPLFor8yDMZPA"
end

function  getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(getAppId()),"appId")
	dict:setObject(CCString:create(getAppKey()),"appKey")
	return dict
end
