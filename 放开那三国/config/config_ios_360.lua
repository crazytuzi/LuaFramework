-- Filename: config_ios_360.lua
-- Author: baoxu
-- Date: 2014-10-28
-- Purpose: 360 平台接入数据定义
module("config", package.seeall)

local loginInfoTable = {}

function getFlag( ... )
	return "360iosphone"
end

function getPidUrl( sessionid )
	local url = Platform.getDomain() .. "phone/login/"
	if(sessionid == nil)then
        sessionid = Platform.getSdk():callStringFuncWithParam("getSessionId",nil)
    end
	local postString = url .."?session=" .. sessionid ..  "&user_id=" .. Platform.sdkLoginInfo.uid..Platform.getUrlParam().. "&bind=" .. g_dev_udid
	print("user_id = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 

function getAppId( ... )
	return "1001000101"
end	

function getAppKey( ... )
	return "37cbcafd9031669b314cf23f1b4ef846"
end

function getName( ... )
	return "360社区"
end

function getInitParam( ... )
	local dict = CCDictionary:create()
	dict:setObject(CCString:create("1001000101"),"channelId")
	dict:setObject(CCString:create("37cbcafd9031669b314cf23f1b4ef846"),"gameKey")
	dict:setObject(CCString:create("2df8ee5e81e14cba005ab8718820d4b3"),"cuKey")
	dict:setObject(CCString:create("1"),"isVer")
	dict:setObject(CCString:create("0"),"isShowATView")
	dict:setObject(CCString:create("iiappleBabelSgPay"),"alipayScheme")

	dict:setObject(CCString:create("0"),"openRecharge")
	dict:setObject(CCString:create("0"),"UIInterfaceOrientationPortrait")
	dict:setObject(CCString:create("0"),"UIInterfaceOrientationPortraitUpsideDown")
	dict:setObject(CCString:create("1"),"UIInterfaceOrientationLandscapeLeft")
	dict:setObject(CCString:create("1"),"UIInterfaceOrientationLandscapeRight")

	return dict
end

function getPayParam( coins, payType, amount )
	-- 支付类型枚举(payType)
	kPay_GoldCoins  =  "00"
	kPay_MonthCard  =  "01"
	local dict = CCDictionary:create()
	dict:setObject(CCString:create(coins),"coins")
	dict:setObject(CCString:create(BTUtil:getSvrTimeInterval()),"serverTime")
	dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"groupId")
	dict:setObject(CCString:create(loginInfoTable.uid),"uid")
	dict:setObject(CCString:create(UserModel.getUserUid()),"appUid")
	if( payType ~= nil and payType == kPay_MonthCard )then
	--月卡购买
		local m_amount = 1
	    if( amount ~= nil )then
      		m_amount = amount
    	end
		dict:setObject(CCString:create(m_amount.."月卡"),"title")
  	elseif ( payType ~= nil and payType == kPay_GoldCoins ) then
  	--金币充值
		dict:setObject(CCString:create(coins.."金币"),"title")
  	else
  	--金币充值
  		dict:setObject(CCString:create(coins.."金币"),"title")
  	end
	
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
	local postString = url .."?session=" .. sessionid.."&user_id=" .. Platform.sdkLoginInfo.uid.. Platform.getUrlParam().."&bind=" .. g_dev_udid
	print("user_id = ",Platform.getSdk():callStringFuncWithParam("getUid",nil))
 	return postString
end 
function getServerListUrl_debug( ... )
 	return "http://124.205.151.82/phone/serverlistnotice?".. Platform.getUrlParam()
end         

function getAppId_debug( ... )
	return "1001000101"
end

function getAppKey_debug( ... )
	return "37cbcafd9031669b314cf23f1b4ef846"
end
