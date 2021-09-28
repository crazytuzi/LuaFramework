-- Filename：	GiftsTableCell.lua
-- Author：		lichenyang
-- Date：		2013-8-26
-- Purpose：		商店礼包cell
require "script/ui/rewardCenter/AdaptTool"

GiftsTableCell = class("GiftsTableCell", function ( ... )
	return CCTableViewCell:create()
end)

GiftsTableCell.__index = GiftsTableCell

GiftsTableCell.newPriceLabel 	= nil
GiftsTableCell.oldPriceLabel 	= nil
GiftsTableCell.descLabel 		= nil
GiftsTableCell.iconSprite 		= nil
GiftsTableCell.buyButton		= nil

function GiftsTableCell:create( giftInfo,cellSize )
	local tableCell = GiftsTableCell:new()
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	-- add by zhz
	cellBackground:setContentSize(CCSizeMake(640, 210))
	tableCell:addChild(cellBackground,0, 100)
	--setAdaptNode(cellBackground)


	local cellTitlePanel = CCSprite:create("images/reward/cell_title_panel.png")
	cellTitlePanel:setAnchorPoint(ccp(0, 0.5))
	cellTitlePanel:setPosition(ccp(0, cellBackground:getContentSize().height))
	cellBackground:addChild(cellTitlePanel,1,200)

	--类型标题
	local alertContent = {}

	alertContent[1] = CCSprite:create("images/common/vip.png")
	alertContent[2] = LuaCC.createNumberSprite("images/main/vip", giftInfo.level)
	alertContent[3] = CCSprite:create("images/shop/vip_desc.png")

	tableCell.title = BaseUI.createHorizontalNode(alertContent)
	tableCell.title:setAnchorPoint(ccp(0, 1))
	local x = (cellTitlePanel:getContentSize().width - tableCell.title:getContentSize().width)/2
	local y = cellTitlePanel:getContentSize().height - (cellTitlePanel:getContentSize().height - tableCell.title:getContentSize().height)/2
	tableCell.title:setPosition(ccp(x , y))
	cellTitlePanel:addChild(tableCell.title)


	--创建奖励物品
	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	itemback:setContentSize(CCSizeMake(406, 125))
	itemback:setPosition(ccp(23, 60))
	itemback:setAnchorPoint(ccp(0, 0))
	cellBackground:addChild(itemback,1,201)

	require "script/ui/item/ItemSprite"
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	itemback:addChild(menu,1,202)


	local normalSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))
	local selectSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))
	local disableSprite = ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))

	tableCell.iconSprite = CCMenuItemSprite:create(normalSprite, selectSprite, disableSprite)
	tableCell.iconSprite:setAnchorPoint(ccp(0, 0.5))
	tableCell.iconSprite:setPosition(ccp(15, itemback:getContentSize().height/2))
	tableCell.iconSprite:registerScriptTapHandler(function ( ... )
		---[==[签到 清除新手引导
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideSignIn) then
			require "script/guide/SignInGuide"
			SignInGuide.cleanLayer()
			NewGuide.guideClass = ksGuideClose
			BTUtil:setGuideState(false)
			NewGuide.saveGuideClass()
		end
		---------------------end-------------------------------------
		--]==]
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		print("item icon click")
		require "script/utils/ItemTableView"
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local itemData = getGiftInfo(giftInfo.id)
		print("itemData")
		print_t(itemData)
		local layer = ItemTableView:create(itemData)
		layer:setTitle(GetLocalizeStringBy("key_3213"))

		alertContent[1] = CCSprite:create("images/common/vip.png")
		alertContent[2] = LuaCC.createSpriteOfNumbers("images/main/vip", giftInfo.level, 15)
		alertContent[3] = CCRenderLabel:create(GetLocalizeStringBy("key_2466"), g_sFontName, 24, 1, ccc3(0x00, 0x00, 0x00))
		alertContent[3]:setColor(ccc3(0xff, 0xe4, 0x00))

		local alert = BaseUI.createHorizontalNode(alertContent)
		layer:setContentTitle(alert)

		runningScene:addChild(layer,10000)
	end)
	menu:addChild(tableCell.iconSprite,1, 203)

	local oldPriceSprite = CCSprite:create("images/shop/origprice.png")
	oldPriceSprite:setAnchorPoint(ccp(0, 0.5))
	oldPriceSprite:setPosition(ccp(32,36))
	cellBackground:addChild(oldPriceSprite, 10)

	local oldGoldSprite = CCSprite:create("images/common/gold.png")
	oldGoldSprite:setAnchorPoint(ccp(0,0.5))
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		oldGoldSprite:setPosition(ccp(120,36))
	else
		oldGoldSprite:setPosition(ccp(100,36))
	end
	cellBackground:addChild(oldGoldSprite)

	local newPriceSprite = CCSprite:create("images/shop/curprice.png")
	newPriceSprite:setAnchorPoint(ccp(0, 0.5))
	newPriceSprite:setPosition(ccp(263,36))
	cellBackground:addChild(newPriceSprite)

	local newGoldSprite = CCSprite:create("images/common/gold.png")
	newGoldSprite:setAnchorPoint(ccp(0,0.5))
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		newGoldSprite:setPosition(ccp(358,36))
	else
		newGoldSprite:setPosition(ccp(338,36))
	end
	cellBackground:addChild(newGoldSprite)

	tableCell.newPriceLabel = CCRenderLabel:create(giftInfo.newPrice, g_sFontName, 24, 1, ccc3(0x00, 0x00, 0x00))
	tableCell.newPriceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		tableCell.newPriceLabel:setPosition(ccp(390,45))
	else
		tableCell.newPriceLabel:setPosition(ccp(370,45))
	end
	cellBackground:addChild(tableCell.newPriceLabel)


	tableCell.oldPriceLabel = CCRenderLabel:create(giftInfo.oldPrice, g_sFontName, 24, 1, ccc3(0x00, 0x00, 0x00))
	tableCell.oldPriceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		tableCell.oldPriceLabel:setPosition(ccp(152,45))
	else
		tableCell.oldPriceLabel:setPosition(ccp(132,45))
	end
	cellBackground:addChild(tableCell.oldPriceLabel)

	tableCell.descLabel = CCLabelTTF:create(giftInfo.desc, g_sFontName, 20, CCSizeMake(280, 100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	tableCell.descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	tableCell.descLabel:setPosition(ccp(115, 90))
	tableCell.descLabel:setAnchorPoint(ccp(0, 1))
	itemback:addChild(tableCell.descLabel)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setAnchorPoint(ccp(0, 0))
	cellBackground:addChild(buyMenuBar, 1, 101)
	-- 购买
	local buyAction = function ( tag,sender )
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		-- ---[==[签到 新手引导屏蔽层
		-- ---------------------新手引导---------------------------------
		-- --add by licong 2013.09.29
		-- require "script/guide/NewGuide"
		-- if(NewGuide.guideClass == ksGuideSignIn) then
		-- 	require "script/guide/SignInGuide"
		-- 	SignInGuide.changLayer()
		-- end
		-- ---------------------end-------------------------------------
		-- --]==]
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		local menuItem = tolua.cast(sender, "CCMenuItemSprite")
		local didBuyCallbackFunc = function ( ... )
			menuItem:setVisible(false)
			local hasReceiveItem = CCSprite:create("images/common/yigoumai.png")
	        hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
	        hasReceiveItem:setPosition(ccp(548, cellBackground:getContentSize().height/2))
	        cellBackground:addChild(hasReceiveItem)
			print("buyAction ok")
		end
		require "script/ui/shop/BuyGiftDialog"
		local layer = BuyGiftDialog.create(giftInfo,didBuyCallbackFunc)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(layer,2000)
	end

	
	-- local buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(145, 80),GetLocalizeStringBy("key_1523"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x47, 0x00, 0x00))\

	local normalSprite 	= CCScale9Sprite:create("images/common/btn/btn_shop_n.png")
	normalSprite:setContentSize(CCSizeMake(144,85))

	local normalLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1523"), g_sFontPangWa, 36, 1, ccc3(0x00, 0x00, 0x00))
	normalLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	normalSprite:addChild(normalLabel)	
	local x = (normalSprite:getContentSize().width - normalLabel:getContentSize().width)/2
	local y = normalSprite:getContentSize().height - (normalSprite:getContentSize().height - normalLabel:getContentSize().height)/2
	normalLabel:setPosition(ccp(x, y))

	local selectSprite 	= CCScale9Sprite:create("images/common/btn/btn_shop_h.png")
	selectSprite:setContentSize(CCSizeMake(144,85))

	local selectLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1523"), g_sFontPangWa, 36, 1, ccc3(0x00, 0x00, 0x00))
	selectLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	selectSprite:addChild(selectLabel)
	local x = (selectSprite:getContentSize().width - selectLabel:getContentSize().width)/2
	local y = selectSprite:getContentSize().height - (selectSprite:getContentSize().height - selectLabel:getContentSize().height)/2
	selectLabel:setPosition(ccp(x, y))	

	-- local disableSprite = CCScale9Sprite:create("images/shop/btn/btn_shop_n.png")
	-- disableSprite:setContentSize(CCSizeMake(144,85))

	-- local disableLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1502"), g_sFontPangWa, 36, 1, ccc3(0x00, 0x00, 0x00))
	-- disableLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	-- disableSprite:addChild(disableLabel)
	-- local x = (disableSprite:getContentSize().width - disableLabel:getContentSize().width)/2
	-- local y = disableSprite:getContentSize().height - (disableSprite:getContentSize().height - disableLabel:getContentSize().height)/2
	-- disableLabel:setPosition(ccp(x, y))
	local disableSprite = CCSprite:create("images/shop/buyed.png")

	tableCell.buyButton = CCMenuItemSprite:create(normalSprite,selectSprite,disableSprite)
	tableCell.buyButton:setAnchorPoint(ccp(0.5, 0.5))
	tableCell.buyButton:setPosition(ccp(548, cellBackground:getContentSize().height/2))
	tableCell.buyButton:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(tableCell.buyButton, 1, 102)
	if(getVipGiftPurchased(tonumber(giftInfo.level))) then
		tableCell.buyButton:setVisible(false)
		local hasReceiveItem = CCSprite:create("images/common/yigoumai.png")
        hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
        hasReceiveItem:setPosition(ccp(548, cellBackground:getContentSize().height/2))
        cellBackground:addChild(hasReceiveItem)
	end

	return tableCell
end

function GiftsTableCell:updateCell( giftInfo )
	self.newPriceLabel:setString(giftInfo.newPrice)
	self.oldPriceLabel:setString(giftInfo.oldPrice)
	self.descLabel:setString(giftInfo.desc)

	local normalSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))
	local selectSprite 	= ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))
	local disableSprite = ItemSprite.getItemSpriteByItemId(tonumber(giftInfo.id))

	self.iconSprite:setNormalImage(normalSprite)
	self.iconSprite:setSelectedImage(selectSprite)
	self.iconSprite:setDisabledImage(disableSprite)
end

function GiftsTableCell:getBuyButton( )
	print("GiftsTableCell:getBuyButton")
	print("self.buyButton:", self.buyButton)
	return self.buyButton
end

--得到礼包是否已购买
function getVipGiftPurchased( vipLevel )
	require "script/model/DataCache"
	local shopCache = DataCache.getShopCache()
	local vipGiftInfo = shopCache.va_shop.vip_gift
	print("vipGiftInfo")
	print_t(vipGiftInfo)
	if(tonumber(vipGiftInfo[tonumber(vipLevel+1)]) == 1) then
		return true
	else
		return false
	end
end

--得到礼包物品数据
function getGiftInfo( itemId )
	require "script/ui/item/ItemUtil"		
	local itemTableInfo = ItemUtil.getItemById(tonumber(itemId))
	local awardItemIds 	= string.split(itemTableInfo.award_item_id, ",")
	print("itemTableInfo.award_item_id", itemTableInfo.award_item_id)
	print_t(awardItemIds)
	local items = {}
	for k,v in pairs(awardItemIds) do
		local tempStrTable = string.split(v, "|")
		local item = {}
		item.tid  = tempStrTable[1]
		item.num = tempStrTable[2]
		item.type = "item"
		print_t(item)
		table.insert(items, item)
	end
    if(itemTableInfo.coins ~= nil) then
		local item = {}
		item.type = "silver"
		item.num  = itemTableInfo.coins
		table.insert(items, item)
	end
	if(itemTableInfo.general_soul ~= nil) then
		local item = {}
		item.type = "soul"
		item.num  = itemTableInfo.general_soul
		table.insert(items, item)
	end
	return items
end


















