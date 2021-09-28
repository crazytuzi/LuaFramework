-- Filename: ExchangeCell.lua.
-- Author: zhz.
-- Date: 2013-09-17
-- Purpose: 该文件用于武将兑换

module("ExchangeCell", package.seeall)


require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicCC"
require "script/ui/item/ItemSprite"
require "db/DB_Tavern_exchange"
require "db/DB_Heroes"
require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/item/ItemUtil"
require "db/DB_Item_hero_fragment"
	

local _curHeroData    -- 当前兑换的碎片信息

local function shopExchangeAction( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok") then
		return
	end
	--AnimationTip.showTip(GetLocalizeStringBy("key_3116") .. _curHeroData.name .. GetLocalizeStringBy("key_1323"))
	require "script/utils/LevelUpUtil"
	LevelUpUtil.showTip(GetLocalizeStringBy("key_3116") .. _curHeroData.name .. GetLocalizeStringBy("key_1323"))
	require "script/ui/shop/HeroExchange"
	DataCache.changeShopPoint(_curHeroData.need_scroe)
	HeroExchange.refreshPoint()
	HeroExchange.refreshTableView()

end


local function confirmCb( tag, itemBtn )
	_curHeroData = DB_Tavern_exchange.getDataById(tag)
	if(tonumber( DataCache.getShopPoint()) < tonumber(_curHeroData.need_scroe)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1760"))
		return
	end
	
	local args = CCArray:create()
    args:addObject(CCInteger:create(_curHeroData.id))
    args:addObject(CCInteger:create(1))
    RequestCenter.shopexchange_buy(shopExchangeAction,args)

end

-- 招募的回调
local function recuitCb(tag, item )
	HeroExchange.closeCb()
	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroLayer"
	MainScene.changeLayer(HeroLayer.createLayer( {index= HeroLayer.m_indexOfSoul}), "HeroLayer")

end

local function getHeroData( exchange_hero_id )
	value = {}

	local heroFragment = DB_Item_hero_fragment.getDataById(exchange_hero_id)
	-- 所需碎片数量
	value.need_part_num = heroFragment.need_part_num
	value.htid = heroFragment.aimItem
	local db_hero = DB_Heroes.getDataById(heroFragment.aimItem)
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

local function heroCb(exchange_hero_id,itemBtn)
	require "script/ui/shop/HeroExchange"
	-- HeroExchange.closeCb()
	local data = getHeroData(exchange_hero_id)
	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroInfoLayer"
	local tArgs = {}
	tArgs.sign = "shopLayer"
	tArgs.fnCreate = ShopLayer.createLayer
	tArgs.reserved =  {index= 10001}
	-- MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
	HeroInfoLayer.createLayer(data, {isPanel=true})
	-- CCDirector:sharedDirector():getRunningScene():addChild(HeroInfoLayer.createLayer(data, tArgs),1111)
end

function createCell( cellValues)

	local tCell = CCTableViewCell:create()

	-- cell 的背景
	local cellBackground = CCScale9Sprite:create("images/shop/exchange_bg.png")
	tCell:addChild(cellBackground)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	cellBackground:addChild(menu)
	menu:setTouchPriority(-556)
	local heroSprite = HeroPublicCC.getCMISHeadIconByHtid(cellValues.aimItem)
	heroSprite:setPosition(ccp(12,30))
	menu:addChild(heroSprite,1,cellValues.exchange_hero_id)
	heroSprite:registerScriptTapHandler(heroCb)

	-- 积分
	local alertContent = {}

    alertContent[1] =CCLabelTTF:create(GetLocalizeStringBy("key_2702") , g_sFontName, 24)
    alertContent[1]:setColor(ccc3(0x48,0x1b,0x00))
    alertContent[2] = CCLabelTTF:create(GetLocalizeStringBy("key_2931") , g_sFontName, 24)
    alertContent[2]:setColor(ccc3(0x90,0x00,0xff))
    alertContent[3] = CCSprite:create("images/common/soul_jade.png")
    alertContent[4] = CCLabelTTF:create( cellValues.need_scroe, g_sFontName, 24)
    alertContent[4]:setColor(ccc3(0x48,0x1b,0x00))

    local vipDesc = BaseUI.createHorizontalNode(alertContent)
    vipDesc:setPosition(ccp(108,76))
    cellBackground:addChild(vipDesc)

    -- 招募武魂所需
    local heroSoulLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2109"), g_sFontName, 24)
    heroSoulLabel:setPosition(ccp(108,39))
    heroSoulLabel:setColor(ccc3(0x48,0x1b,0x00))
    cellBackground:addChild( heroSoulLabel)

    local needSoulNum = DB_Item_hero_fragment.getDataById(cellValues.exchange_hero_id).need_part_num
   -- local hasSoulNum = DataCache.getHeroFragNumByItemTmpid(cellValues.exchange_hero_id)
    local heroFragmentLabel = CCLabelTTF:create( cellValues.hasSoulNum .. "/" .. needSoulNum, g_sFontName,24)
    heroFragmentLabel:setColor(ccc3(0xff,0,0))
    heroFragmentLabel:setPosition(ccp(270, 39))
    cellBackground:addChild(heroFragmentLabel,1, cellValues.exchange_hero_id)

    print("hasSoulNum is : ", cellValues.hasSoulNum)
    -- level sprite
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setPosition(ccp(55,152))
    cellBackground:addChild(lvSp)
	-- 等级
	local lvLabel = CCRenderLabel:create("" .. cellValues.lv , g_sFontName,22,1,ccc3(0x89,0x00,0x1a),type_shadow)
	lvLabel:setColor(ccc3(0xff,0xee,0x3a))
	lvLabel:setAnchorPoint(ccp(0,0))
	lvLabel:setPosition(ccp(90,147))
	cellBackground:addChild(lvLabel)

	-- name
	local nameLabel = CCLabelTTF:create(cellValues.name  , g_sFontName,22)
	nameLabel:setPosition(ccp(140,149))
	nameLabel:setColor(ccc3(0x6c,0xff,0x00))
	cellBackground:addChild(nameLabel)

	-- 星星
	for i =1 , tonumber(cellValues.quality) do
		local starSprite = CCSprite:create("images/common/star.png")
		starSprite:setPosition(ccp(257+ i*37, 149))
		cellBackground:addChild(starSprite)
	end

	-- 国家
    require "script/model/hero/HeroModel"
	local countrySprite = CCSprite:create(HeroModel.getLargeCiconByCidAndlevel(cellValues.country, cellValues.quality))
	countrySprite:setAnchorPoint(ccp(0,1))
	countrySprite:setPosition(ccp(5,cellBackground:getContentSize().height))
	cellBackground:addChild(countrySprite)

	-- 兑换按钮

	local normalSp = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	normalSp:setContentSize(CCSizeMake(130,64))
	local selectSp = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	selectSp:setContentSize(CCSizeMake(130,64))
    local confirmBtn = CCMenuItemSprite:create(normalSp, selectSp)
    confirmBtn:setPosition(ccp(cellBackground:getContentSize().width*0.75,81))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
   	menu:addChild(confirmBtn,1,cellValues.id)
    local confirmLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    confirmLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (confirmBtn:getContentSize().width - confirmLabel:getContentSize().width)/2
    local height = confirmBtn:getContentSize().height/2
    confirmLabel:setPosition(width,54)
    confirmBtn:addChild(confirmLabel)
   	confirmBtn:registerScriptTapHandler(confirmCb)

   	local normalSp2 = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	normalSp2:setContentSize(CCSizeMake(130,64))
	local selectSp2 = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
	selectSp2:setContentSize(CCSizeMake(130,64))
    local recuitBtn = CCMenuItemSprite:create(normalSp2, selectSp2)
    recuitBtn:setPosition(ccp(cellBackground:getContentSize().width*0.75,17))
    recuitBtn:setAnchorPoint(ccp(0.5,0))
   	menu:addChild(recuitBtn,1,cellValues.id)
    local recuitLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2165"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x0),type_stroke)
    recuitLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (recuitBtn:getContentSize().width - recuitLabel:getContentSize().width)/2
    local height = recuitBtn:getContentSize().height/2
    recuitLabel:setPosition(width,54)
    recuitBtn:addChild(recuitLabel)
   	recuitBtn:registerScriptTapHandler(recuitCb)

	return tCell
end
