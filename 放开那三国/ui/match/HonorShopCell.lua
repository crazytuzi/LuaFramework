-- FileName: HonorShopCell.lua 
-- Author: licong 
-- Date: 14-6-19 
-- Purpose: function description of module 


module("HonorShopCell", package.seeall)

require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"

-- 查看物品信息返回回调 为了显示下排按钮
local function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, true)
end

-- 兑换按钮action
local function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("兑换物品id: tag==", tag)
	-- 是否限购
	require "db/DB_Contest_shop"
	local goods_data = DB_Contest_shop.getDataById(tag)
	local maxLimitNum =  tonumber(goods_data.baseNum) - MatchData.getBuyNumBy(goods_data.id)
	if(maxLimitNum<=0)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2129"))
		return
	end
	if(UserModel.getHeroLevel()< tonumber(goods_data.needLevel))then
		AnimationTip.showTip(GetLocalizeStringBy("key_2749") .. tonumber(goods_data.needLevel) .. GetLocalizeStringBy("key_3184"))
		return
	end
	-- 弹出选择数量界面
	require "script/ui/match/HonorShopBuyLayer"
	HonorShopBuyLayer.showPurchaseLayer(tag)
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
	textBg:setPosition(ccp(20, 45))
	cellBackground:addChild(textBg)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	cellBackground:addChild(buyMenuBar)
	-- 兑换
	-- 兑换物品id
	local itemType, item_id, item_num = MatchData.getItemData( goods_data.items )
	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
	if(tonumber(itemType) == 1)then
		-- DB_Contest_shop表中每条数据中的 物品数据
		require "script/ui/item/ItemUtil"
		item_data = ItemUtil.getItemById(item_id)
		iconSprite = ItemSprite.getItemSpriteById(item_id,nil, showDownMenu)
		iconSprite:setAnchorPoint(ccp(0,0))
		iconSprite:setPosition(ccp(20,20))
		textBg:addChild(iconSprite)
		-- 显示物品的数量
        local num_data = item_num or 1
        local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        num_font:setColor(ccc3(0x70, 0xff, 0x18))
        num_font:setAnchorPoint(ccp(1,0))
        num_font:setPosition(ccp(iconSprite:getContentSize().width-5,2))
        iconSprite:addChild(num_font)
	elseif(tonumber(itemType) == 2)then
		-- -- DB_Contest_shop表中每条数据中的 英雄数据
		require "script/model/utils/HeroUtil"
		item_data = HeroUtil.getHeroLocalInfoByHtid(item_id)
		iconSprite = HeroUtil.getHeroIconByHTID(item_id)
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		textBg:addChild(menu)
		local iconItem = CCMenuItemSprite:create(iconSprite,iconSprite)
		iconItem:setAnchorPoint(ccp(0,0))
		iconItem:setPosition(ccp(20,20))
		menu:addChild(iconItem,1,tonumber(item_id))
		iconItem:registerScriptTapHandler(heroSpriteCb)
		-- 显示物品的数量
        local num_data = item_num or 1
        local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        num_font:setColor(ccc3(0x70, 0xff, 0x18))
        num_font:setAnchorPoint(ccp(1,0))
        num_font:setPosition(ccp(iconItem:getContentSize().width-8,3))
        iconItem:addChild(num_font)
	end

	local buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(145, 80),GetLocalizeStringBy("key_2689"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	buyBtn:setAnchorPoint(ccp(0, 0))
	buyBtn:setPosition(ccp(475, 65))
	buyBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(buyBtn, 1, tonumber(goods_data.id))

    -- 横线
	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setScaleX(2.8)
	lineSprite:setAnchorPoint(ccp(0, 0))
	lineSprite:setPosition(ccp(110, 85))
	textBg:addChild(lineSprite)
    -- 描述
    local goodsDesc = ""
    if(item_data.desc)then 
    	goodsDesc = item_data.desc
    end
    local descLabel = CCLabelTTF:create(goodsDesc, g_sFontName, 20, CCSizeMake(325,70), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLabel:setColor(ccc3(0x78, 0x25, 0x00))
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setPosition(ccp(125, 5))
    textBg:addChild(descLabel)
    
	-- 物品名称
	local nameLabel = CCRenderLabel:create(item_data.name, g_sFontPangWa, 23, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    nameLabel:setColor(ccc3(0xff, 0xa8, 0x00))
    nameLabel:setPosition(130, 105)
    textBg:addChild(nameLabel)

	-- 限购
	local maxLimitNum =  tonumber(goods_data.baseNum) - MatchData.getBuyNumBy(goods_data.id)
	print("cell maxLimitNum",maxLimitNum)
	local str = nil
	if( tonumber(goods_data.limitType) == 1)then
		str = GetLocalizeStringBy("key_1589").. maxLimitNum .. GetLocalizeStringBy("key_3357")
	elseif(tonumber(goods_data.limitType) == 2)then
		str = GetLocalizeStringBy("key_2885").. maxLimitNum .. GetLocalizeStringBy("key_3357")
	elseif(tonumber(goods_data.limitType) == 3)then
		str = GetLocalizeStringBy("lic_1083").. maxLimitNum .. GetLocalizeStringBy("key_3357")
	else
	end
	local limitLabel = CCLabelTTF:create( str, g_sFontName, 20)--, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    limitLabel:setColor(ccc3(0x00, 0x00, 0x00))
    limitLabel:setAnchorPoint(ccp(0,0))
	limitLabel:setPosition(20, 18)
	-- cellBackground:addChild(limitLabel)

  	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		limitLabel:setPosition(475, 35)
		cellBackground:addChild(limitLabel)
	else
		limitLabel:setPosition(260, 95)
		textBg:addChild(limitLabel)
	end

	-- 价格
	local priceLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1084"), g_sFontName, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    priceLabel:setColor(ccc3(0xff, 0xf6, 0x01))
    priceLabel:setPosition(35, 50)
    cellBackground:addChild(priceLabel)
    local goldSp_1 = CCSprite:create("images/common/s_honor.png")
	goldSp_1:setAnchorPoint(ccp(0,0))
	goldSp_1:setPosition(ccp(priceLabel:getPositionX() + priceLabel:getContentSize().width,18))
	cellBackground:addChild(goldSp_1)
	local curPrice = tonumber(goods_data.costHonor)
	local curPriceLabel = CCRenderLabel:create(curPrice, g_sFontName, 18, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    curPriceLabel:setColor(ccc3(0xff, 0xff, 0xff))
    curPriceLabel:setPosition(goldSp_1:getPositionX() + goldSp_1:getContentSize().width, 47)
    cellBackground:addChild(curPriceLabel)

    -- 需要人物等级
    if(UserModel.getHeroLevel()< tonumber(goods_data.needLevel))then
	    local needLvLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3131"), g_sFontPangWa, 25)
	    needLvLabel:setColor(ccc3(0x78, 0x25, 0x00))
	    needLvLabel:setAnchorPoint(ccp(0,0))
	    needLvLabel:setPosition(350, 20)
	    cellBackground:addChild(needLvLabel)
	    local lvLabel = CCLabelTTF:create(goods_data.needLevel, g_sFontPangWa, 25)
	    lvLabel:setColor(ccc3(0x00, 0x8d, 0x3d))
	    lvLabel:setAnchorPoint(ccp(0,0))
	    lvLabel:setPosition(needLvLabel:getPositionX()+needLvLabel:getContentSize().width+5, 10)
	    cellBackground:addChild(lvLabel)
	end

	return tCell
end

-- 获得英雄的信息
local function getHeroData( htid)
    value = {}

    value.htid = htid
    require "db/DB_Heroes"
    local db_hero = DB_Heroes.getDataById(htid)
    value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.name = db_hero.name
    value.level = db_hero.lv
    value.star_lv = db_hero.star_lv
    value.hero_cb = menu_item_tap_handler
    value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
    value.quality_h = "images/hero/quality/highlighted.png"
    value.type = "HeroFragment"
    value.isRecruited = false
    value.evolve_level = 0

    return value
end

-- 点击英雄头像的回调函数
function heroSpriteCb( tag,menuItem )
    local data = getHeroData(tag)
    -- local tArgs = {}
    -- tArgs.sign = "PrestigeShop"
    -- tArgs.fnCreate = HonorShop.createHonorShopLayer
    -- tArgs.reserved =  {index= 10001}
    HeroInfoLayer.createLayer(data, {isPanel=true})
end
