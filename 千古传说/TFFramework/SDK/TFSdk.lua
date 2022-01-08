--[[
SDK代理类


]]

TFSdk = {}

if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    TFSdk = require("TFFramework.SDK.android.TFSdkAndroid")
elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    TFSdk = require("TFFramework.SDK.ios.TFSdkIos")
else
	TFSdk = require('TFFramework.SDK.win32.TFSdkWin32')
end


--interface规范 不要删除 add by weihua.cui
-- function TFSdk:init(callback)
-- function TFSdk:login(callback)
-- function TFSdk:logout(callback)
-- function TFSdk:setLogoutCallback(callback)
-- function TFSdk:setLeavePlatformCallback(callback)
-- function TFSdk:switchAccount(callback)
-- function TFSdk:enterPlatform(callback)
-- function TFSdk:payForProduct(product_info, callback)
-- function TFSdk:getUserName()
-- function TFSdk:getSdkName()
-- function TFSdk:getPlatformToken()
-- function TFSdk:getCheckServerToken()
-- function TFSdk:getUserID()
-- function TFSdk:getUserName()
-- function TFSdk:getAppID()
-- function TFSdk:getUserIsLogin()
-- function TFSdk:getProductList(callback)
-- function TFSdk:getSdkVersion(callback)
-- function TFSdk:onEventActionID(szEventID)
-- function TFSdk:setDebugMode(debug)  -- android
-- function TFSdk:share(shar_info,callback)
-- function TFSdk:getFriends(get_info,callback)
-- function TFSdk:inviteFriends(invite_info,callback)


--[[

--****支付示范****
--@param:product_info(支付参数，table)
--@param:callback(支付回调，function)   ,下面是畅游平台对应参数示例(所有参数不能为空、空串)
--@ product_info = {
	[TFSdk.TOTAL_PRICES] = "0.02",     //goodsPrice (changyou)
	[TFSdk.ORDER_NO] = "0",    //没有则为0
	[TFSdk.ORDER_TITLE] = "购买血之刃",  //
	[TFSdk.ROLE_ID] = "235",  
	[TFSdk.SERVER_ID] = "1",
	[TFSdk.SERVER_NAME] = "黑暗之夜",
	[TFSdk.ROLE_NAME] = "第一武侠之小黑妞",
	[TFSdk.ROLE_LEVEL] = "25",
	[TFSdk.VIP_LEVEL] = "0",
	[TFSdk.PARTY_NAME] = "青龙帮",
	[TFSdk.PAY_DESCRIPTION] = "血之刃之描述",   //goodsDescribe (changyou)
	[TFSdk.PRODUCT_ID] = "2352", 		//goodsId (changyou)
	[TFSdk.PRODUCT_NAME] = "200元宝",  //goodsName (changyou)
	[TFSdk.PRODUCT_COUNT] = "1", 	 //goodsNumber (changyou)
	[TFSdk.USER_BALANCE] = "0"  
	[TFSdk.GOOD_REGISTID] ="2"   		//畅游所需
      }
]]
-- function TFSdk:payForProduct(product_info, callback)
-- function TFSdk:getUserName()
-- function TFSdk:getSdkName()
-- function TFSdk:getPlatformToken()
-- function TFSdk:getCheckServerToken()
-- function TFSdk:getUserID()
-- function TFSdk:getUserName()
-- function TFSdk:getAppID()
-- function TFSdk:getUserIsLogin()
--[[

--***获取商品列表callback 参数说明*****
--@ param callback(data)
--	data = {
               "result",
               "msg",
               "productList",
	    }
]]
-- function TFSdk:getProductList(callback)
-- function TFSdk:getSdkVersion(callback)
-- function TFSdk:onEventActionID(szEventID)

-- function TFSdk:setDebugMode(debug)  -- android

--[[ 以下为统计接口
//充值
-- function TFSdk:recharge
//充值并购买
-- function TFSdk:rechargeAndBuy
//购买道具
-- function TFSdk:buyProp
//使用道具
-- function TFSdk:useProp
//赠送金币
-- function TFSdk:bonusGold
//赠送道具
-- function TFSdk:bonusProp
//进入关卡
-- function TFSdk:startLevel
//通过关卡
-- function TFSdk:finishLevel
//未通过关卡
-- function TFSdk:failLevel
//设置玩家等级
-- function TFSdk:setUserLevel
//设置玩家属性
-- function TFSdk:setUserInfo
//设置log开关
-- function TFSdk:setLogEnable
--]]

--[[

--****** 支付参数说明**********
--******参数不能为空或空串***
--pay
TFSdk.PAYRESULT_MSG     // 支付回调消息
TFSdk.PAY_CODE  	          //支付回调状态码

TFSdk.TOTAL_PRICES         //商品价格(一般为总价)
TFSdk.ORDER_NO               //订单号
TFSdk.ORDER_TITLE           //订单名
TFSdk.PAY_DESCRIPTION  //描述信息 
TFSdk.PRODUCT_ID  	//商品id
TFSdk.PRODUCT_NAME  	//商品名称
TFSdk.PRODUCT_COUNT  	//商品数量
TFSdk.USER_BALANCE  	//用户余额
--role
TFSdk.ROLE_ID  		//角色id
TFSdk.ROLE_NAME  		//角色名称
TFSdk.SERVER_ID  		//区服id
TFSdk.SERVER_NAME  	//区服名称
TFSdk.ROLE_LEVEL  	//角色等级
TFSdk.VIP_LEVEL  		//vip等级
TFSdk.PARTY_NAME  	//工会名(帮派)
TFSdk.GOOD_REGISTID  	//注册商品id (畅游)
]]

--[[

--****分享示范****
--@param:share_info(分享参数，table)
--@param:callback(分享回调，function) 
--@ share_info = {
	[TFSdk.SHARE_URL] = "https://developers.facebook.com/docs/ios/share/", 
	[TFSdk.SHARE_NAME] = "Share MangoEngine", 
	[TFSdk.SHARE_CAPTION] = "Build great social apps and get more installs.", 
	[TFSdk.SHARE_PICTURE_URL] = "http://i.imgur.com/g3Qc1HN.png",
	[TFSdk.SHARE_DESCRIPTION] = "Allow your users to share stories on Facebook from your app using the iOS SDK.",
	[TFSdk.SHARE_STYLE] = TFSdk.SHARE_STYLE_WEB_DIALOG
    }
]]

--[[

--***获取好友列表callback 参数说明*****

local get_invitefriends_info=
	{
		[TFSdk.FRIENDS_STLYE] = TFSdk.FRIENDS_GET_INVITE  //[TFSdk.FRIENDS_STLYE] = TFSdk.FRIENDS_GET_NORMAL
	}

--@ param callback(data)
--	data = {
               "result",
               "msg",
               "FriendList",
	    }
]]

return TFSdk