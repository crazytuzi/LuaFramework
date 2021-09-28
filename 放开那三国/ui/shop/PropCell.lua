-- Filename：	PropCell.lua
-- Author：		Cheng Liang
-- Date：		2013-8-22
-- Purpose：		购买道具cell

module("PropCell", package.seeall)


require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"

local goodsData = nil

-- 购买回调
function buyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		print("_goodsData.id==", goodsData.id)
		if(goodsData.id == 11 )then
			UserModel.addGoldNumber( -ShopUtil.getBuySiliverTotalPriceBy(ShopUtil.getBuyNumBy(11)+1, 1))
			UserModel.addSilverNumber(1 * tonumber(goodsData.buy_siliver_num))
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. goodsData.buy_siliver_num .. GetLocalizeStringBy("key_1687") )
		elseif( goodsData.id == 12) then
			UserModel.addGoldNumber( -ShopUtil.getBuySoulTotalPriceBy(ShopUtil.getBuyNumBy(12)+1, 1))
			UserModel.addSoulNum(1 * tonumber(goodsData.buy_soul_num))
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. goodsData.buy_soul_num .. GetLocalizeStringBy("key_1616") )
		else
			UserModel.addGoldNumber(-1 * goodsData.current_price)
			local itemInfo = ItemUtil.getItemById(goodsData.item_id)
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. goodsData.buy_soul_num .. GetLocalizeStringBy("key_2557") .. itemInfo.name )
		end
		ShopLayer.refreshTopUI()
		DataCache.addBuyNumberBy( goodsData.id, 1 )
		
		
		PropLayer.reloadDataFunc()
		
	end
end

local function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("tagtagtag.id==", tag)
	require "db/DB_Goods"
	goodsData = DB_Goods.getDataById(tonumber(tag))

	if(goodsData.vip_needed and tonumber(goodsData.vip_needed)>tonumber(UserModel.getVipLevel())) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2597").. goodsData.vip_needed .. GetLocalizeStringBy("key_2005") )
		return
	end
	if(goodsData.user_lv_needed and  tonumber(goodsData.user_lv_needed)> tonumber( UserModel.getHeroLevel())) then
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

	require "script/ui/shop/PurchaseLayer"
	PurchaseLayer.showPurchaseLayer(tag)

	-- 是否是银币或者将魂
	-- if(tonumber(tag) == 11) then
	-- 	-- 是否限购
	-- 	-- if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id) > 0) then
	-- 	-- 	local maxLimitNum = - ShopUtil.getBuyNumBy(goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id)
	-- 	-- 	if(maxLimitNum<=0)then
	-- 	-- 		AnimationTip.showTip(GetLocalizeStringBy("key_2553"))
	-- 	-- 		return
	-- 	-- 	end
	-- 	-- end	
	-- 	if(ShopUtil.getBuySiliverTotalPriceBy(ShopUtil.getBuyNumBy(11)+1, 1) <= UserModel.getGoldNumber()) then
	-- 		local args = Network.argsHandler(goodsData.id, 1)
	-- 		RequestCenter.shop_buyGoods(buyCallback, args)
	-- 	else
	-- 		require "script/ui/tip/LackGoldTip"
	-- 		LackGoldTip.showTip()
	-- 		--AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
	-- 	end
	-- elseif(tonumber(tag) == 12) then

	-- 	-- 是否限购
	-- 	-- if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id) > 0) then
	-- 	-- 	local maxLimitNum = - ShopUtil.getBuyNumBy(goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id)
	-- 	-- 	if(maxLimitNum<=0)then
	-- 	-- 		AnimationTip.showTip(GetLocalizeStringBy("key_2553"))
	-- 	-- 		return
	-- 	-- 	end
	-- 	-- end

	-- 	if(ShopUtil.getBuySoulTotalPriceBy(ShopUtil.getBuyNumBy(12)+1, 1) <= UserModel.getGoldNumber()) then
	-- 		local args = Network.argsHandler(goodsData.id, 1)
	-- 		RequestCenter.shop_buyGoods(buyCallback, args)
	-- 	else
	-- 		require "script/ui/tip/LackGoldTip"
	-- 		LackGoldTip.showTip()
	-- 		--AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
	-- 	end
	-- else
	-- 	-- 是否限购
	-- 	-- if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id) > 0) then

	-- 	-- 	local maxLimitNum = - ShopUtil.getBuyNumBy(goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id)
	-- 	-- 	if(maxLimitNum<=0)then
	-- 	-- 		AnimationTip.showTip(GetLocalizeStringBy("key_2553"))
	-- 	-- 	else
	-- 	-- 		require "script/ui/shop/PurchaseLayer"
	-- 	-- 		PurchaseLayer.showPurchaseLayer(tag)
	-- 	-- 	end
	-- 	-- else
	-- 		require "script/ui/shop/PurchaseLayer"
	-- 		PurchaseLayer.showPurchaseLayer(tag)
	-- 	-- end
	-- end
	
end

function createCell( goods_data )
	local tCell = CCTableViewCell:create()
	--背景
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(640, 210))
	tCell:addChild(cellBackground)

	-- 小背景
	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	textBg:setContentSize(CCSizeMake(450, 135))
	textBg:setAnchorPoint(ccp(0,0))
	textBg:setPosition(ccp(20, 55))
	cellBackground:addChild(textBg)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	cellBackground:addChild(buyMenuBar)
	-- 购买
	local buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(145, 80),GetLocalizeStringBy("key_1523"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	buyBtn:setAnchorPoint(ccp(0, 0))
	buyBtn:setPosition(ccp(475, 65))
	buyBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(buyBtn, 1, goods_data.id)

	-- 物品名称
	-- local nameLabel = CCRenderLabel:create("text", g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
 --    nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
 --    nameLabel:setPosition(130, 125)
 --    textBg:addChild(nameLabel)
    -- 横线
	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setScaleX(2.8)
	lineSprite:setAnchorPoint(ccp(0, 0))
	lineSprite:setPosition(ccp(110, 85))
	textBg:addChild(lineSprite)
    -- 描述
    local goodsDesc = ""
    if(goods_data.desc)then 
    	goodsDesc = goods_data.desc
    end

    local descLabel = CCLabelTTF:create(goodsDesc, g_sFontName, 20, CCSizeMake(325,70), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLabel:setColor(ccc3(0x78, 0x25, 0x00))
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setPosition(ccp(125, 5))
    textBg:addChild(descLabel)

    local iconSprite = nil
    local curPrice = ShopUtil.getNeedGoldByGoodsAndTimes( goods_data.id, ShopUtil.getBuyNumBy(goods_data.id)+1)
	if(goods_data.buy_siliver_num) then
		-- 是购买银币
		-- 物品名称
		local nameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1041"), g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    nameLabel:setPosition(130, 125)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getSiliverIconSpriteForShop()
		curPrice = ShopUtil.getSiliverPriceBy( ShopUtil.getBuyNumBy(11)+1 )
	elseif(goods_data.buy_soul_num) then
		-- 是购买将魂
		-- 物品名称
		local nameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3397"), g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    nameLabel:setPosition(130, 125)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getSoulIconSpriteForShop()
		curPrice = ShopUtil.getSoulPriceBy( ShopUtil.getBuyNumBy(12)+1 )
	elseif(goods_data.item_id ~= nil )then
		local itemDesc = ItemUtil.getItemById(goods_data.item_id)
		-- 物品名称
		local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    nameLabel:setPosition(130, 125)
	    textBg:addChild(nameLabel)
		iconSprite = ItemSprite.getItemSpriteByItemId(goods_data.item_id)
	elseif( goods_data.hero_id ~= nil )then
		local heroDesc = HeroUtil.getHeroLocalInfoByHtid(goods_data.hero_id)
		-- 武将名称
		local nameLabel = CCRenderLabel:create(heroDesc.name, g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    nameLabel:setPosition(130, 125)
	    textBg:addChild(nameLabel)
		iconSprite = HeroUtil.getHeroIconByHTID(goods_data.hero_id)
	end
	iconSprite:setAnchorPoint(ccp(0,0))
	iconSprite:setPosition(ccp(15,25))
	textBg:addChild(iconSprite)

	-- 限购
	if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id) > 0) then
		local maxLimitNum = - ShopUtil.getBuyNumBy(goods_data.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goods_data.id)
		local limitLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2611").. maxLimitNum .. GetLocalizeStringBy("key_1362") , g_sFontName, 20)--, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    limitLabel:setColor(ccc3(0x00, 0x00, 0x00))
	    limitLabel:setAnchorPoint(ccp(0,0))
	    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	    	limitLabel:setPosition(260, -30)
	    else
	    	limitLabel:setPosition(260, 95)
	    end
	    textBg:addChild(limitLabel)
	end

	if(goods_data.sell_mode == 1) then
		-- 原价
		local goldSp_1 = CCSprite:create("images/common/gold.png")
		goldSp_1:setAnchorPoint(ccp(0,0))
		goldSp_1:setPosition(ccp(102,18))
		cellBackground:addChild(goldSp_1)
		local origPriceLabel = CCRenderLabel:create(goods_data.original_price, g_sFontName, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    origPriceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	    origPriceLabel:setPosition(135, 45)
	    cellBackground:addChild(origPriceLabel)

		local origPriceSp 	= CCSprite:create("images/shop/origprice.png")
		origPriceSp:setAnchorPoint(ccp(0,0))
		origPriceSp:setPosition(ccp(30,18))
		cellBackground:addChild(origPriceSp)
		

		-- 现价
		local curPriceSp 	= CCSprite:create("images/shop/curprice.png")
		curPriceSp:setAnchorPoint(ccp(0,0))
		curPriceSp:setPosition(ccp(260,15))
		cellBackground:addChild(curPriceSp)
		local goldSp_2 = CCSprite:create("images/common/gold.png")
		goldSp_2:setAnchorPoint(ccp(0,0))
		goldSp_2:setPosition(ccp(74,2))
		curPriceSp:addChild(goldSp_2)
		local curPriceLabel = CCRenderLabel:create(curPrice, g_sFontName, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    curPriceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	    curPriceLabel:setPosition(105, 30)
	    curPriceSp:addChild(curPriceLabel)

	else
		local priceLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1667"), g_sFontName, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    priceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	    priceLabel:setPosition(35, 50)
	    cellBackground:addChild(priceLabel)
	    local goldSp_1 = CCSprite:create("images/common/gold.png")
		goldSp_1:setAnchorPoint(ccp(0,0))
		goldSp_1:setPosition(ccp(108,18))
		cellBackground:addChild(goldSp_1)
		local curPriceLabel = CCRenderLabel:create(curPrice, g_sFontName, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
	    curPriceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
	    curPriceLabel:setPosition(138, 47)
	    cellBackground:addChild(curPriceLabel)
	
	end

	return tCell
end

