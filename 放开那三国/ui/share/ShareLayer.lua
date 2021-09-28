-- Filename: ShareLayer.lua
-- Author: zhang zihang
-- Date: 2013-11-01
-- Purpose: 该文件用于:分享

module ("ShareLayer", package.seeall)


require "script/audio/AudioUtil"

local _bgLayer 				-- 灰色的layer

local zLayerIndex 		= nil
local touchPriority 	= nil

local shareText			= nil
local shareImage 		= nil


local successCallback 	= nil

local function closeCb()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des:	分享到微信朋友圈
]] 
local function sharedToFriends()
	if(BTUtil:getPlatform() == kBT_PLATFORM_ANDROID) then
		protocol = PluginManager:getInstance():loadPlugin()
		local WXAppInstalled = protocol:callBoolFuncWithParam("isWXAppInstalled",nil)
		if(WXAppInstalled) then
			local WXAppSupportAPI = protocol:callBoolFuncWithParam("isWXAppSupportAPI",nil)
			if(WXAppSupportAPI) then
				registerDidSendMessage()
				if(shareText == nil and shareImage == nil) then
					shareWeixinAtMenu()
				else
					local dict = CCDictionary:create()
					dict:setObject(CCString:create(shareText or " "),"weixinContent")
					dict:setObject(CCString:create(shareImage or " "),"weixinIcon")
					dict:setObject(CCString:create("Icon.png"),"weixinIcon")
					protocol:callOCFunctionWithName_oneParam_noBack("sendMessage",dict)
				end
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_10199"))
			end
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_10200"))
		end
	else
		TxWeixin:shareTxWeixin():registerDidSendMessage(shareCallback)
		if(shareText == nil and shareImage == nil) then
			shareWeixinAtMenu()
		else
			TxWeixin:shareTxWeixin():sendMessage(shareText, shareImage,"Icon.png")
		end
	end
end

--[[
	@des: 	分享到新浪微博
]]
local function sharedToWeibo()

	Weibo:shareWeibo():registerDidSendMessage(shareCallback)
	if(shareText == nil and shareImage == nil) then
		shareWeiboAtMenu()
	else
		Weibo:shareWeibo():sendMessage(shareText, shareImage)
	end
end

function shareCallback( errorCode )
	-- body
	print("weiboCallback errorCode", errorCode)
	closeCb()

	if(tonumber(errorCode) == 0) then
		shareRequest()
	end
end

--[[
   @des:	显示分享面板
   @param:	p_zIndex		显示在runningScene上的z值,
   			p_touchPriority 屏蔽层的权限
   @ret:	ccsprite
]]
function show(p_weiboText, p_shareImage,p_zIndex, p_touchPriority, callback)
	
	--关闭越狱渠道分享
	if(Platform.getOS() =="ios" and not Platform.isAppStore()) then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_3001"))
		return
	end
	if(BTUtil:getPlatform() == kBT_PLATFORM_ANDROID) then
		if( type(Platform.getConfig().getShareType) == "function" )then
			print("海外安卓分享")
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2247"))
			return
		end
	end
	
	zLayerIndex 		= p_zIndex or 1000 
	touchPriority 		= p_touchPriority or -1000
	successCallback		= callback

	shareText = p_weiboText
	shareImage = p_shareImage
	require "script/utils/BaseUI"
	_bgLayer = BaseUI.createMaskLayer(touchPriority)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer, zLayerIndex,2013)

    require "script/ui/main/MainScene"
    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,454)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local shareBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    shareBg:setContentSize(mySize)
    shareBg:setScale(myScale)
    shareBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    shareBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(shareBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(shareBg:getContentSize().width*0.5, shareBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	shareBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1923"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x00),type_shadow)
	labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(touchPriority-10)
    shareBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(shareBg:getContentSize().width*0.5,25))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x00),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    --分享奖励提示
    local explainLabel1 = CCRenderLabel:create(GetLocalizeStringBy("key_2502"), g_sFontPangWa,25,2,ccc3(0xff,0xff,0xff),type_shadow)
	explainLabel1:setPosition(ccp(shareBg:getContentSize().width/2, shareBg:getContentSize().height-80))
	explainLabel1:setColor(ccc3(0x78,0x25,0x00))
	explainLabel1:setAnchorPoint(ccp(0.5,0.5))
	shareBg:addChild(explainLabel1)

	--分享提示第二行字符纵坐标
	local explainLabel2Height = shareBg:getContentSize().height-80-explainLabel1:getContentSize().height

	local explainLabel21 = CCRenderLabel:create(GetLocalizeStringBy("key_1788"), g_sFontPangWa,25,2,ccc3(0xff,0xff,0xff),type_shadow)
	explainLabel21:setColor(ccc3(0x78,0x25,0x00))

	local silverSprite22 = CCSprite:create("images/common/coin.png")

	local silverNum23	 = CCRenderLabel:create(GetLocalizeStringBy("key_1074"), g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_shadow)
	silverNum23:setColor(ccc3(0xff,0xf6,0x00))

	local explainLabel24 = CCRenderLabel:create(GetLocalizeStringBy("key_2019"), g_sFontPangWa,25,2,ccc3(0xff,0xff,0xff),type_shadow)
	explainLabel24:setColor(ccc3(0x78,0x25,0x00))

	--体力
	local bodyForceLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1913"), g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_shadow)
	bodyForceLabel:setColor(ccc3(0xff,0xf6,0x00))


	local aleteNode = BaseUI.createHorizontalNode({explainLabel21, silverSprite22, silverNum23, bodyForceLabel})
	aleteNode:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode:setPosition(ccp(shareBg:getContentSize().width/2, explainLabel2Height))
	shareBg:addChild(aleteNode)

	               
	-- explainLabel2:setPosition(ccp(shareBg:getContentSize().width/2, explainLabel2Height))
	-- explainLabel21:setColor(ccc3(0x78,0x25,0x00))
	-- explainLabel2:setAnchorPoint(ccp(0.5,0.5))
	-- -- shareBg:addChild(explainLabel2)

	-- local silverSprite = CCSprite:create("images/common/coin.png")
	-- silverSprite:setPosition(ccp(shareBg:getContentSize().width/ok2-20,explainLabel2Height))
	-- silverSprite:setAnchorPoint(ccp(0.5,0.5))
	-- -- shareBg:addChild(silverSprite)

	-- local silverNum = CCRenderLabel:create("1000", g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_shadow)
	-- silverNum:setPosition(ccp(shareBg:getContentSize().width/2+50, explainLabel2Height))
	-- silverNum:setColor(ccc3(0xff,0xf6,0x00))
	-- silverNum:setAnchorPoint(ccp(0.5,0.5))
	-- shareBg:addChild(silverNum)

	-- 黑色的背景
    local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,190))
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,mySize.height/2))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0.5))
    shareBg:addChild(itemInfoSpite)
    if(type(Platform.getConfig().getShareType) == "function" 
    	and Platform.getConfig().getShareType() == "Facebook")then
  
    	local facebookBtn = CCMenuItemImage:create("images/share/facebook/facebook1.png", "images/share/facebook/facebook2.png")
	    -- facebookBtn:setPosition(ccp(mySize.width/3,mySize.height/2))
	    facebookBtn:setPosition(ccp(mySize.width*1/2,mySize.height/2))
	    facebookBtn:setAnchorPoint(ccp(0.5,0.5))
	    menu:addChild(facebookBtn)
	    facebookBtn:registerScriptTapHandler(shareFacebookAtMenu)
	    -- facebookBtn:setVisible(false)
    else
    	local friendsBtn = CCMenuItemImage:create("images/share/friends/friends2.png", "images/share/friends/friends1.png")
	    -- friendsBtn:setPosition(ccp(mySize.width*2/3,mySize.height/2))
	    friendsBtn:setPosition(ccp(mySize.width*1/2,mySize.height/2))
	    friendsBtn:setAnchorPoint(ccp(0.5,0.5))
	    menu:addChild(friendsBtn)
	    friendsBtn:registerScriptTapHandler(sharedToFriends)
	    -- friendsBtn:setVisible(false)

	    local weiboBtn = CCMenuItemImage:create("images/share/weibo/weibo2.png", "images/share/weibo/weibo1.png")
	    weiboBtn:setPosition(ccp(mySize.width/3,mySize.height/2))
	    weiboBtn:setAnchorPoint(ccp(0.5,0.5))
	    menu:addChild(weiboBtn)
	    weiboBtn:registerScriptTapHandler(sharedToWeibo)
	    weiboBtn:setVisible(false)
    end

    local explainLabel3 = CCRenderLabel:create(GetLocalizeStringBy("key_2285"), g_sFontPangWa,25,2,ccc3(0xff,0xff,0xff),type_shadow)
    explainLabel3:setColor(ccc3(0x78,0x25,0x00))
    local explainLabel31 = CCRenderLabel:create(GetLocalizeStringBy("key_2876"), g_sFontPangWa,25,2,ccc3(0xff,0xff,0xff),type_shadow)
    explainLabel31:setColor(ccc3(0x78,0x25,0x00))
    local goldSprite = CCSprite:create("images/common/gold.png")
    local goldNum = CCRenderLabel:create("100", g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_shadow)
    goldNum:setColor(ccc3(0xff,0xf6,0x00))

	local aleteNode2 = BaseUI.createHorizontalNode({explainLabel3, goldSprite, goldNum, explainLabel31})
	aleteNode2:setAnchorPoint(ccp(0.5, 0.5))
	aleteNode2:setPosition(ccp(shareBg:getContentSize().width/2, 110))
	shareBg:addChild(aleteNode2)
	--[[explainLabel3:setPosition(ccp(shareBg:getContentSize().width/2, 110))
	explainLabel3:setColor(ccc3(0x78,0x25,0x00))
	explainLabel3:setAnchorPoint(ccp(0.5,0.5))
	shareBg:addChild(explainLabel3)

	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setPosition(ccp(shareBg:getContentSize().width/2+65, 110))
	goldSprite:setAnchorPoint(ccp(0.5,0.5))
	shareBg:addChild(goldSprite)

	local goldNum = CCRenderLabel:create("100", g_sFontPangWa,25,2,ccc3(0x00,0x00,0x00),type_shadow)
	goldNum:setPosition(ccp(shareBg:getContentSize().width/2+120, 110))
	goldNum:setColor(ccc3(0xff,0xf6,0x00))
	goldNum:setAnchorPoint(ccp(0.5,0.5))
	shareBg:addChild(goldNum)]]
end

function requestCallbackFunc( cbFlag, dictData, bRet )
	if(bRet == true and table.count(dictData.ret) > 0) then
		local str = GetLocalizeStringBy("key_1568")
		local goldStr = ""
		local silverStr = ""
		local executionStr = ""
		if(dictData.ret.gold ~= nil) then
			goldStr = dictData.ret.gold .. GetLocalizeStringBy("key_1062")
			UserModel.addGoldNumber(tonumber(dictData.ret.gold))
		end
		if(dictData.ret.silver ~= nil) then
			silverStr = dictData.ret.silver .. GetLocalizeStringBy("key_1308")
			UserModel.addSilverNumber(tonumber(dictData.ret.silver))
		end
		if(dictData.ret.execution ~= nil) then
			executionStr = dictData.ret.execution .. GetLocalizeStringBy("key_3238")
			UserModel.addEnergyValue(tonumber(dictData.ret.execution))
		end
		str = str.. goldStr .. silverStr .. executionStr
		if(str ~= nil) then
        	AlertTip.showAlert(str, nil, false)
			require "script/ui/tip/AlertTip"
		end
	end

	if(successCallback) then
		successCallback()
	end
end

function shareRequest( ... )
	local args = CCArray:create()
	Network.rpc(requestCallbackFunc, "user.share", "user.share", nil, true)
end



function shareWeiboAtMenu( ... )
	require "db/DB_Share"
	local shareData = DB_Share.getDataById(Platform.getCurrentPlatform())
	if(shareData.weiboImage ~= nil) then
		Weibo:shareWeibo():sendMessage(shareData.weiboContent, CCFileUtils:sharedFileUtils():fullPathForFilename("images/share/config/" .. shareData.weiboImage) )
	else
		Weibo:shareWeibo():sendMessage(shareData.weiboContent, nil)
	end
end

function shareWeixinAtMenu( ... )
	require "db/DB_Share"
	local shareData = DB_Share.getDataById(Platform.getCurrentPlatform())

	if(BTUtil:getPlatform() == kBT_PLATFORM_ANDROID) then
		local dict = CCDictionary:create()
		if(shareData.weixinUrl ~= nil) then
			dict:setObject(CCString:create(shareData.weixinTitle),"weixinTitle")
			dict:setObject(CCString:create(shareData.weixinContent or " "),"weixinContent")
			dict:setObject(CCString:create(shareData.weixinUrl),"weixinUrl")
			dict:setObject(CCString:create("images/share/config/" ..shareData.wenxinIcon),"weixinIcon")
			protocol:callOCFunctionWithName_oneParam_noBack("sendUrlMessage",dict)
		else
			dict:setObject(CCString:create(shareData.weixinContent or " "),"weixinContent")
			if(shareData.wenxinImage ~= nil) then
				dict:setObject(CCString:create("images/share/config/" ..shareData.wenxinImage),"wenxinImage")
			else
				dict:setObject(CCString:create(" "),"wenxinImage")
			end
			dict:setObject(CCString:create("images/share/config/" ..shareData.wenxinIcon),"weixinIcon")
			protocol:callOCFunctionWithName_oneParam_noBack("sendMessage",dict)
		end
	else
		print("shareData.weixinUrl", shareData.weixinUrl)
		print("shareData.wenxinImage", shareData.wenxinImage)
		print("shareData.weixinContent", shareData.weixinContent)
		print("shareData.wenxinIcon", shareData.wenxinIcon)
		if(shareData.weixinUrl ~= nil and shareData.wenxinImage ~= nil ) then
			local t = os.date("*t",os.time())
			if tonumber(t.day)%2 == 0 then
				TxWeixin:shareTxWeixin():sendUrlMessage(shareData.weixinTitle, shareData.weixinContent or " ", shareData.weixinUrl, CCFileUtils:sharedFileUtils():fullPathForFilename("images/share/config/" ..shareData.wenxinIcon))
			else
				TxWeixin:shareTxWeixin():sendMessage(shareData.weixinContent, CCFileUtils:sharedFileUtils():fullPathForFilename("images/share/config/" ..shareData.wenxinImage),CCFileUtils:sharedFileUtils():fullPathForFilename("images/share/config/" ..shareData.wenxinIcon))
			end	
		else
			TxWeixin:shareTxWeixin():sendMessage(shareData.weixinContent, nil, CCFileUtils:sharedFileUtils():fullPathForFilename("images/share/config/" ..shareData.wenxinIcon))
		end
	end
	
end

function registerDidSendMessage()
  protocol:registerScriptHandlers("shareResult",function( ... )
    local code = protocol:callIntFuncWithParam("didSendMessageListener",nil)
    shareCallback(code)
  end)
end

function shareFacebookAtMenu( ... )
        Platform.sendInformationToPlatform(Platform.kShareButtonClick)
end


