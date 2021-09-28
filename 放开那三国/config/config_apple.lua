-- Filename: config_91.lua
-- Author: chao he
-- Date: 2013-09-22
-- Purpose: ios 91 平台配置
module("config", package.seeall)

loginInfoTable = {}

function getFlag( ... )
	return "appstore"
end


function getServerListUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl( sessionid )
	local url = "http://mapifknsg.zuiyouxi.com/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getHashUrl( )
 	return "http://mapifknsg.zuiyouxi.com/phone/getHash/"
end 

function showZxyMenuButton( ... )
	local _dict = CCDictionary:create()
    _dict:setObject(CCString:create("zyx_icon_n.png"),"icon_n")
    _dict:setObject(CCString:create("zyx_icon_h.png"),"icon_h")
    _dict:setObject(CCString:create("zyx_bg_l.png"),"bg_l")
    _dict:setObject(CCString:create("zyx_bg_r.png"),"bg_r")

	Platform.getSdk():callOCFunctionWithName_oneParam_noBack("showZxyMenuButton",_dict)
end

function creatZxyMenuButton( pid )
	local timestamp = BTUtil:getSvrTimeInterval()
	local hash = BTUtil:getMd5SumByString(pid..timestamp.."7B17C49B30E00CE126CB")
	local m_nu = 0
	
	local _domain = "http://bbs.zuiyouxi.com/bbs/phone/loginByGame.php?"

	if Platform.isDebug() then
		_domain = "http://192.168.53.69/hzwbbs2/bbs/phone/loginByGame.php?"
	end

	--论坛
	local bbs_tag = "1"
	local bbs_title = "论坛_放开那三国"
	local bbs_imageName_n = "zyx_bbs_n.png"
	local bbs_imageName_h = "zyx_bbs_h.png"
	local bbs_url = _domain.."pid="..pid.."&timestamp="..timestamp.."&hash="..hash.."&pl=".. getFlag() .."&other_pl=zyxphone"

	creatButton( bbs_tag, bbs_title, bbs_imageName_n, bbs_imageName_h, bbs_url )

    --礼包
    local gift_tag = "2"
	local gift_title = "礼包_放开那三国"
	local gift_imageName_n = "zyx_gift_n.png"
	local gift_imageName_h = "zyx_gift_h.png"
	local gift_url = _domain.."pid="..pid.."&timestamp="..timestamp.."&hash="..hash.."&pl=".. getFlag() .."&other_pl=zyxphone&redirect=giftwares"
    if Platform.isAdShow then
       	-- creatButton( gift_tag, gift_title, gift_imageName_n, gift_imageName_h, gift_url )
       	m_nu = 1
    else
    	creatButton( gift_tag, gift_title, gift_imageName_n, gift_imageName_h, gift_url )
    end

	--客服
	local serve_tag = "3" - m_nu
	local serve_title = "客服_放开那三国"
	local serve_imageName_n = "zyx_serve_n.png"
	local serve_imageName_h = "zyx_serve_h.png"
	local serve_url = _domain.."pid="..pid.."&timestamp="..timestamp.."&hash="..hash.."&pl=".. getFlag() .."&other_pl=zyxphone&redirect=service"

	creatButton( serve_tag, serve_title, serve_imageName_n, serve_imageName_h, serve_url )

	--账户
	local account_tag = "4" - m_nu
	local account_title = "账户_放开那三国"
	local account_imageName_n = "zyx_account_n.png"
	local account_imageName_h = "zyx_account_h.png"
	local account_url = _domain.."pid="..pid.."&timestamp="..timestamp.."&hash="..hash.."&pl=".. getFlag() .."&other_pl=zyxphone&redirect=user"

	creatButton( account_tag, account_title, account_imageName_n, account_imageName_h, account_url )

    --其他...

 	-- return dict
end 

function creatButton( btag, btitle, bimageName_n, bimageName_h, burl )
	
	local _dict = CCDictionary:create()
	local _tag = btag
	local _title = btitle
	local _imageName_n = bimageName_n
	local _imageName_h = bimageName_h
	local _iphoneUrl = burl.."&device=iphone"
	local _ipadUrl = burl.."&device=ipad"

	_dict:setObject(CCString:create(_tag),"tag")
	_dict:setObject(CCString:create(_title),"title")
    _dict:setObject(CCString:create(_iphoneUrl),"url_iphone")
    _dict:setObject(CCString:create(_ipadUrl),"url_ipad")
    _dict:setObject(CCString:create(_imageName_n),"imageName_n")
    _dict:setObject(CCString:create(_imageName_h),"imageName_h")

	Platform.getSdk():callOCFunctionWithName_oneParam_noBack("creatButton",_dict)

end 

function isNeedAdShow( ... )
    return true
end 

function getAdShowUrl( ... )
 	return "http://mapifknsg.zuiyouxi.com/phone/adshow?pl=appstore&os=ios&gn=sanguo&version="
end

function getAppId( ... )
	return "101942"
end

function getAppKey( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getName( ... )
	return "游戏社区"
end

function getLoginUrl( username,password )
	return "http://mapifknsg.zuiyouxi.com/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=" .. "&bind=" .. g_dev_udid
end

function getADUrl( pid, mac, idfa )
	local mac = Platform.getSdk():callStringFuncWithParam("getMac",nil)
	local idfa = Platform.getSdk():callStringFuncWithParam("getIdfa",nil)
	print("mac =",mac)
	print("idfa =",idfa)
	return "http://mapifknsg.zuiyouxi.com/phone/adstat?".. Platform.getUrlParam().."&pid=".. pid .. "&mac=" .. mac .. "&idfa=" .. idfa.."&devres="..g_winSize.width.."x"..g_winSize.height
end

function getRegisterUrl( )
	local registerUrl 
	if  g_debug_mode then
		registerUrl = "http://192.168.1.38/phone/login/?action=register" .. Platform.getUrlParam()
	else
		registerUrl = "http://mapifknsg.zuiyouxi.com/phone/login/?action=register".. Platform.getUrlParam()
	end
	print("getRegisterUrl registerUrl:", registerUrl)
	return registerUrl
end


function getChangePasswordUrl( username,password )
	local renewpassUrl = ""
	if  Platform.isDebug() then
		renewpassUrl = "http://192.168.1.38/phone/login/?".. Platform.getUrlParam().."&action=renewpass"
	else
		renewpassUrl = "http://mapifknsg.zuiyouxi.com/phone/login/?".. Platform.getUrlParam().."&action=renewpass"
	end
	return renewpassUrl
end



kLoginsStateNotLogin="0"
kLoginsStateUDIDLogin="1"
kLoginsStateZYXLogin="2"
function getLoginState( ... )
	if(CCUserDefault:sharedUserDefault():getStringForKey("loginState") == nil or CCUserDefault:sharedUserDefault():getStringForKey("loginState") == "")then
		return kLoginsStateNotLogin
	end
	return CCUserDefault:sharedUserDefault():getStringForKey("loginState")
end

--debug conifg
function getServerListUrl_debug( ... )
 	return "http://192.168.1.38/phone/serverlistnotice/?".. Platform.getUrlParam()
end 

function getPidUrl_debug( sessionid )
	local url = "http://192.168.1.38/phone/login/"
 	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .. "?sid=" .. sessionid .. "&uin=".. Platform.getUin() .. Platform.getUrlParam().."&bind=" .. g_dev_udid
 	return postString
end 

function getAppId_debug( ... )
	return "101942"
end

function getAppKey_debug( ... )
	return "078774ab3dadede0f4b30a59bec3f311b3934d8f1d0b4bf8"
end

function getLoginUrl_debug( username,password )
	return "http://192.168.1.38/phone/login/?".. Platform.getUrlParam().."&action=login&username=" .. username .. "&password=" .. password .. "&ext=".. "&bind=" .. g_dev_udid
end

function getADUrl_debug( pid, mac, idfa )
	local mac = Platform.getSdk():callStringFuncWithParam("getMac",nil)
	local idfa = Platform.getSdk():callStringFuncWithParam("getIdfa",nil)
	print("mac =",mac)
	print("idfa =",idfa)
	return "http://192.168.1.38/phone/adstat?".. Platform.getUrlParam().."&pid=".. pid .. "&mac=" .. mac .. "&idfa=" .. idfa
end
