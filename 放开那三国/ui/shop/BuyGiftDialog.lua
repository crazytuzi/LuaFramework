-- Filename：	BuyGiftDialog.lua
-- Author：		lichenyang
-- Date：		2013-8-22
-- Purpose：		购买礼包对话框


module ("BuyGiftDialog", package.seeall)
require "script/audio/AudioUtil"

local colorLayer = nil
local didBuyFunc = nil
local giftInfo	 = nil
local okButton 	 = nil
function init( )
	 colorLayer = nil
	 didBuyFunc = nil
end

function create( gift_Info,callbackFunc )

	init()
	giftInfo   = gift_Info
	didBuyFunc = callbackFunc

	colorLayer = BaseUI.createMaskLayer(-1024)

	local g_winSize = CCDirector:sharedDirector():getWinSize()

	local background = CCScale9Sprite:create("images/common/viewbg1.png")
	background:setContentSize(CCSizeMake(565, 430))
	background:setAnchorPoint(ccp(0.5, 0.5))
	background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	colorLayer:addChild(background)
	AdaptTool.setAdaptNode(background)


	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(520, 263))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(background:getContentSize().width*0.5, 110))
	background:addChild(tableBackground)

	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	itemback:setContentSize(CCSizeMake(498, 151))
	itemback:setPosition(ccp(tableBackground:getContentSize().width/2, 94))
	itemback:setAnchorPoint(ccp(0.5, 0))
	tableBackground:addChild(itemback)

	require "script/ui/item/ItemSprite"
	local iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))
	iconSprite:setAnchorPoint(ccp(0, 0.5))
	iconSprite:setPosition(ccp(15, itemback:getContentSize().height/2))
	itemback:addChild(iconSprite)

	local spriteLine = CCScale9Sprite:create("images/common/line01.png")
	spriteLine:setContentSize(CCSizeMake(327, 4))
	spriteLine:setPosition(ccp(0,0.5))
	spriteLine:setPosition(ccp(115, 88))
	itemback:addChild(spriteLine)

	--礼包名称
	local giftNameLabel = CCRenderLabel:create(giftInfo.name , g_sFontPangWa, 36, 1, ccc3(0,0,0))
	giftNameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	giftNameLabel:setPosition(ccp(124 , 140))
	itemback:addChild(giftNameLabel)

	local giftDescLabel = CCLabelTTF:create(giftInfo.desc, g_sFontName, 24, CCSizeMake(330,66), kCCTextAlignmentLeft)
	giftDescLabel:setColor(ccc3(0x78, 0x25,0x00))
	giftDescLabel:setPosition(ccp(124, 90))
	giftDescLabel:setAnchorPoint(ccp(0, 1))
	itemback:addChild(giftDescLabel)


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(-1500)
	background:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeButton:setPosition(ccp(background:getContentSize().width * 0.96, background:getContentSize().height * 0.96))
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)


	okButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(210,73),GetLocalizeStringBy("key_1465"),ccc3(255,222,0))
    okButton:setAnchorPoint(ccp(0.5, 0.5))
    okButton:setPosition(background:getContentSize().width*0.25, background:getContentSize().height*0.13)
	menu:addChild(okButton, 1, tonumber(giftInfo.level))
	okButton:registerScriptTapHandler(okButtonCallback)
	

	local cancelButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(210,73),GetLocalizeStringBy("key_2326"),ccc3(255,222,0))
    cancelButton:setAnchorPoint(ccp(0.5, 0.5))
    cancelButton:setPosition(background:getContentSize().width*0.75, background:getContentSize().height*0.13)
	menu:addChild(cancelButton)
	cancelButton:registerScriptTapHandler(cancelButtonCallback)
 	
 	local alertContent = {}

	-- alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1523"), g_sFontName, 24, 1, ccc3(0x49,0,0))
	alertContent[1] = CCLabelTTF:create(GetLocalizeStringBy("key_1523"), g_sFontName, 24)
	alertContent[1]:setColor(ccc3(0xff, 0xe4, 0x00))

	alertContent[2] = CCSprite:create("images/common/vip.png")

	alertContent[3] = LuaCC.createNumberSprite("images/main/vip", giftInfo.level)

	-- alertContent[4] = CCRenderLabel:create(GetLocalizeStringBy("key_2629"), g_sFontName, 24, 1, ccc3(0x49,0,0))
	alertContent[4] = CCLabelTTF:create(GetLocalizeStringBy("key_2629"), g_sFontName, 24)
	alertContent[4]:setColor(ccc3(0xff, 0xe4, 0x00))

	alertContent[5] = CCSprite:create("images/common/gold.png")

	-- alertContent[6] = CCRenderLabel:create(giftInfo.newPrice, g_sFontName, 24, 1, ccc3(0x49,0,0))
	alertContent[6] = CCLabelTTF:create(giftInfo.newPrice, g_sFontName, 24)
	alertContent[6]:setColor(ccc3(0xff, 0xe4, 0x00))

	local alert = BaseUI.createHorizontalNode(alertContent)
	alert:setAnchorPoint(ccp(0.5, 0.5))
	alert:setPosition(ccp(tableBackground:getContentSize().width * 0.5, tableBackground:getContentSize().height * 0.2))
	tableBackground:addChild(alert, 20)

	-- local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
	-- 		addGuideSignInGuide10()
	-- 	end))
	-- colorLayer:runAction(seq)

	return colorLayer
end

--关闭按钮事件
function closeButtonCallback( tag,sender )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	colorLayer:removeFromParentAndCleanup(true)
end

--确定事件
function okButtonCallback( tag,sender )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/item/ItemUtil"
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		colorLayer:removeFromParentAndCleanup(true)
		return
	end

	local item = tolua.cast(sender, "CCMenuItemImage")
	local vipLevel = item:getTag()
	print("okButtonCallback", vipLevel)
	require "script/model/user/UserModel"
	require "script/ui/shop/GiftService"
	local callbackFunc = function ( ... )
		didBuyFunc()
		local costGoldNUmber = -tonumber(giftInfo.newPrice)
		UserModel.addGoldNumber(costGoldNUmber)
		require "script/ui/shop/ShopLayer"
		ShopLayer.refreshTopUI()
		print("buyAction ok")
		colorLayer:removeFromParentAndCleanup(true)
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2824"))
	end	
	if(tonumber(giftInfo.newPrice) <= UserModel.getGoldNumber()) then
		GiftService.buyVipGift(vipLevel, callbackFunc)
	else
		--require "script/ui/tip/AnimationTip"
		--AnimationTip.showTip(GetLocalizeStringBy("key_3381"))
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		colorLayer:removeFromParentAndCleanup(true)
	end
end

function cancelButtonCallback( tag,sender )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	colorLayer:removeFromParentAndCleanup(true)
end

function getGuideButton( ... )
	return okButton
end

-- -- 签到第10步 确定
-- function addGuideSignInGuide10( ... )
-- 	require "script/guide/NewGuide"
-- 	require "script/guide/SignInGuide"
--     if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 9) then
--         local button = getGuideButton()
--         local touchRect   = getSpriteScreenRect(button)
--         SignInGuide.show(10, touchRect)
--     end
-- end
