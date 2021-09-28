-- Filename：	PropCell.lua
-- Author：		yangrui
-- Date：		2015-09-21
-- Purpose：		购买道具cell

module("PropCell", package.seeall)

require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"

local goodsData     = nil
local _isNewEnter   = nil

local function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "db/DB_Goods"
	goodsData = DB_Goods.getDataById(tonumber(tag))

	if(goodsData.vip_needed and tonumber(goodsData.vip_needed)>tonumber(UserModel.getVipLevel())) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2597").. goodsData.vip_needed .. GetLocalizeStringBy("key_2005") )
		return
	end
	if(goodsData.user_lv_needed and tonumber(goodsData.user_lv_needed)> tonumber( UserModel.getHeroLevel())) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2803").. goodsData.user_lv_needed .. GetLocalizeStringBy("key_1093") )
		return
	end
	-- 是否限购
	if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id) > 0) then
		local maxLimitNum = - ShopUtil.getBuyNumBy(goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id)
		if(maxLimitNum<=0)then
			AnimationTip.showTip(GetLocalizeStringBy("key_2553"))
			return
		end
	end

	require "script/ui/shopall/prop/PurchaseLayer"
	PurchaseLayer.showPurchaseLayer(tag,_isNewEnter)
end

function createCell( goods_data, isNewEnter )
	_isNewEnter = isNewEnter
	local tCell = CCTableViewCell:create()
	--背景
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(430, 178))
	tCell:addChild(cellBackground)
	-- 小背景
	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	textBg:setContentSize(CCSizeMake(260, 115))
	textBg:setAnchorPoint(ccp(0,0))
	textBg:setPosition(ccp(20, 45))
	cellBackground:addChild(textBg)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(270,10))
	cellBackground:addChild(buyMenuBar)
	-- 购买
	local buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("key_1523"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	buyBtn:setAnchorPoint(ccp(0, 0))
	buyBtn:setPosition(ccp(18, 60))
	buyBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(buyBtn, 1, goods_data.id)

    local iconSprite = nil
    local nameLabel = nil
    local curPrice = ShopUtil.getNeedGoldByGoodsAndTimes( goods_data.id, ShopUtil.getBuyNumBy(goods_data.id)+1)
	if(goods_data.buy_siliver_num) then
		-- 是购买银币
		-- 物品名称
		nameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1041"), g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    local quality = ItemSprite.getSilverQuality()
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(110, 100)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getSiliverIconSpriteForShop()
		curPrice = ShopUtil.getSiliverPriceBy( ShopUtil.getBuyNumBy(11)+1 )
	elseif(goods_data.buy_soul_num) then
		-- 是购买将魂
		-- 物品名称
		nameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3397"), g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    local quality = ItemSprite.getSoulQuality()
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(110, 100)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getSoulIconSpriteForShop()
		curPrice = ShopUtil.getSoulPriceBy( ShopUtil.getBuyNumBy(12)+1 )
	elseif(goods_data.item_id ~= nil )then
		local itemDesc = ItemUtil.getItemById(goods_data.item_id)
		-- 物品名称
		nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    local quality = ItemUtil.getTreasureQualityByTid(goods_data.item_id)
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(110, 100)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getItemSpriteById(goods_data.item_id)
	elseif( goods_data.hero_id ~= nil )then
		local heroDesc = HeroUtil.getHeroLocalInfoByHtid(goods_data.hero_id)
		-- 武将名称
		nameLabel = CCRenderLabel:create(heroDesc.name, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDesc.star_lv)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(110, 100)
	    textBg:addChild(nameLabel)
		iconSprite = HeroUtil.getHeroIconByHTID(goods_data.hero_id)
	end
	iconSprite:setAnchorPoint(ccp(0,0))
	iconSprite:setPosition(ccp(12,12))
	textBg:addChild(iconSprite)

	if(goods_data.sell_mode == 1) then
		-- 原价
		local origPriceSp 	= CCSprite:create("images/shop/origprice.png")
		origPriceSp:setAnchorPoint(ccp(0,0))
		origPriceSp:setPosition(ccp(122,nameLabel:getPositionY()-2*nameLabel:getContentSize().height))
		textBg:addChild(origPriceSp,1)
		local goldSp_1 = CCSprite:create("images/common/gold.png")
		goldSp_1:setAnchorPoint(ccp(0,0))
		goldSp_1:setPosition(ccp(180,nameLabel:getPositionY()-2*nameLabel:getContentSize().height))
		textBg:addChild(goldSp_1)
		local origPriceLabel = CCRenderLabel:create(goods_data.original_price, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    origPriceLabel:setColor(ccc3(0xff, 0xff, 0xff))
		origPriceLabel:setAnchorPoint(ccp(0,0))
	    origPriceLabel:setPosition(goldSp_1:getPositionX()+goldSp_1:getContentSize().width, nameLabel:getPositionY()-2*nameLabel:getContentSize().height)
	    textBg:addChild(origPriceLabel)
		-- 现价
		local curPriceSp 	= CCSprite:create("images/shop/curprice.png")
		curPriceSp:setAnchorPoint(ccp(0,0))
		curPriceSp:setPosition(ccp(126, origPriceSp:getPositionY()-origPriceSp:getContentSize().height))
		curPriceSp:setScale(0.7)
		textBg:addChild(curPriceSp)
		local goldSp_2 = CCSprite:create("images/common/gold.png")
		goldSp_2:setAnchorPoint(ccp(0,0))
		goldSp_2:setPosition(ccp(180,origPriceSp:getPositionY()-origPriceSp:getContentSize().height))
		textBg:addChild(goldSp_2)
		local curPriceLabel = CCRenderLabel:create(curPrice, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    curPriceLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    curPriceLabel:setAnchorPoint(ccp(0,0))
	    curPriceLabel:setPosition(goldSp_2:getPositionX() + goldSp_2:getContentSize().width, origPriceSp:getPositionY()-origPriceSp:getContentSize().height)
	    textBg:addChild(curPriceLabel)
	else
		local priceLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1667"), g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    priceLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    priceLabel:setPosition(110, 50)
	    textBg:addChild(priceLabel)
	    local goldSp_1 = CCSprite:create("images/common/gold.png")
		goldSp_1:setAnchorPoint(ccp(0,0))
		goldSp_1:setPosition(ccp(priceLabel:getPositionX() + priceLabel:getContentSize().width,25))
		textBg:addChild(goldSp_1)
		local curPriceLabel = CCRenderLabel:create(curPrice, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
	    curPriceLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    curPriceLabel:setPosition(goldSp_1:getPositionX() + goldSp_1:getContentSize().width, 50)
	    textBg:addChild(curPriceLabel)
	end

	-- 限购
	if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id) > 0) then
		local maxLimitNum = - ShopUtil.getBuyNumBy(goods_data.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id)
		local limitLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2611").. maxLimitNum .. GetLocalizeStringBy("key_1362") , g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)--, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    limitLabel:setColor(ccc3(0x00, 0xff, 0x18))
	    limitLabel:setAnchorPoint(ccp(0,0))
	    limitLabel:setPosition(20, 18)
	    cellBackground:addChild(limitLabel)
	end
	if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id) > 0) then
		local maxLimitNum = - ShopUtil.getBuyNumBy(goods_data.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id)
		if(maxLimitNum<=0)then
			buyBtn:setVisible(false)
			local hasReceiveItem = CCSprite:create("images/common/yigoumai.png")
            hasReceiveItem:setAnchorPoint(ccp(0,0))
            hasReceiveItem:setPosition(ccp(280,70))
            cellBackground:addChild(hasReceiveItem)
		end
	end
	return tCell
end

