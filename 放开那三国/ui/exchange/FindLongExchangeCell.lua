-- Filename: ExchangeCell.lua
-- Author: ZQ
-- Date: 2014-06-19
-- Purpose: 创建寻龙积分的兑换表单元格

module("FindLongExchangeCell",package.seeall)

require "script/ui/exchange/FindLongExchangeCache"
require "script/model/user/UserModel"
require "script/ui/exchange/FindLongExchangeBuyLayer"
require "script/ui/hero/HeroPublicLua"

local _canExchangeNumSp = nil

function setCancanExchangeNumSp(sprite)
	_canExchangeNumSp = sprite
end

function getCanExchangeNumSp()
	return _canExchangeNumSp
end

function createOnlyPointCell(cellData)
	local cell = CCTableViewCell:create()

	--背景
	local bg = CCScale9Sprite:create("images/reward/cell_back.png")
	bg:setPreferredSize(CCSizeMake(632,200))
	cell:addChild(bg)

	--物品背景
	local goodBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	goodBg:setPreferredSize(CCSizeMake(453,135))
	goodBg:setAnchorPoint(ccp(0,1))
	goodBg:setPosition(20,181)
	bg:addChild(goodBg)

	-- 兑换物品图标
	--[[
		商品类型：	1：物品ID 
					2：英雄ID
		根据商品类型和对应ID获得对应的精灵图标
	--]]
	local itemTable = cellData.itemsTable
	local itemType, item_id, item_num = itemTable.type, itemTable.tid, itemTable.num
	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
	if(tonumber(itemType) == 1)then
		-- DB_Arena_shop表中每条数据中的 物品数据
		require "script/ui/item/ItemUtil"
		item_data = ItemUtil.getItemById(item_id)
		iconSprite = ItemSprite.getItemSpriteById(item_id,nil, showDownMenu)
		iconSprite:setAnchorPoint(ccp(0,0))
		iconSprite:setPosition(ccp(15,25))
		goodBg:addChild(iconSprite)
		-- 显示物品的数量
        local num_data = item_num or 1
        local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        num_font:setColor(ccc3(0x70, 0xff, 0x18))
        num_font:setAnchorPoint(ccp(1,0))
        num_font:setPosition(ccp(iconSprite:getContentSize().width-5,2))
        iconSprite:addChild(num_font)
	elseif(tonumber(itemType) == 2)then
		-- -- DB_Arena_shop表中每条数据中的 英雄数据
		require "script/model/utils/HeroUtil"
		item_data = HeroUtil.getHeroLocalInfoByHtid(item_id)
		iconSprite = HeroUtil.getHeroIconByHTID(item_id)
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		goodBg:addChild(menu)
		local iconItem = CCMenuItemSprite:create(iconSprite,iconSprite)
		iconItem:setAnchorPoint(ccp(0,0))
		iconItem:setPosition(ccp(15,25))
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

	--物品名称
	local goodName = CCRenderLabel:create(item_data.name,g_sFontPangWa,24,2,ccc3(0x00,0x00,0x00),type_shadow)
	-- local quality = nil
	-- if itemTable.type == 1 then
	-- 	quality = item_data.quality
	-- elseif itemTable.type == 2 then
	-- 	quality = item_data.star_lv
	-- else
	-- end
	-- local fontColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local fontColor = ccc3(0xff,0xe4,0x00)
	goodName:setColor(fontColor)	
	goodName:setAnchorPoint(ccp(0,1))
	goodName:setPosition(126,120)
	goodBg:addChild(goodName)

	--能够兑换的次数
	local totalNum = cellData.remainExchangeNum
	local exchangeNum = nil
	if cellData.limitType == 1 then
		exchangeNum = CCLabelTTF:create(GetLocalizeStringBy("zz_3",totalNum),g_sFontName,18)
	elseif cellData.limitType == 2 then
		exchangeNum = CCLabelTTF:create(GetLocalizeStringBy("zz_9",totalNum),g_sFontName,18)
	else
		exchangeNum = CCLabelTTF:create(GetLocalizeStringBy("zz_9",totalNum),g_sFontName,18)
	end
	exchangeNum:setColor(ccc3(0x00,0xff,0x18))
	exchangeNum:setAnchorPoint(ccp(0,0))
	-- exchangeNum:setPosition(278,113)
	-- goodBg:addChild(exchangeNum,1,100)

	  --兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		exchangeNum:setPosition(475, 35)
		bg:addChild(exchangeNum,1,100)
	else
		exchangeNum:setPosition(278, 95)
		goodBg:addChild(exchangeNum,1,100)
	end

	--分割线
	local sparateLine = CCScale9Sprite:create("images/hunt/brownline.png")
	sparateLine:setPreferredSize(CCSizeMake(330,4))
	sparateLine:setAnchorPoint(ccp(0,1))
	sparateLine:setPosition(108,85)
	goodBg:addChild(sparateLine)

	--物品说明
	local declarationStr = ""
	if item_data.desc then
		declarationStr = item_data.desc
	end
	local declaration = CCLabelTTF:create(declarationStr,g_sFontName,20,CCSizeMake(325,70), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	declaration:setColor(ccc3(0x78,0x25,0x00))
	--declaration:setContentSize(CCSizeMake(330,70))
	declaration:setAnchorPoint(ccp(0,1))
	declaration:setPosition(117,78)
	goodBg:addChild(declaration)

	--按钮
	local btnMenu = BTMenu:create()
	local exchangeTable = FindLongExchangeLayer.getExchangeTable()
	btnMenu:setAnchorPoint(ccp(0,0))
	btnMenu:setPosition(474,71)
	btnMenu:setScrollView(exchangeTable)
	bg:addChild(btnMenu)

	local btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(145, 80),GetLocalizeStringBy("key_2689"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	btnMenu:addChild(btn,1,cellData.id)

	local function btnCb(tag, itemBtn)
		if not preExchange(cellData) then return end

		setCancanExchangeNumSp(exchangeNum)
		
		FindLongExchangeBuyLayer.showPurchaseLayer(cellData)
	end
	btn:registerScriptTapHandler(btnCb)

	--底部描述
	local bottomStr = CCRenderLabel:create(GetLocalizeStringBy("zz_5"),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_shadow)
	bottomStr:setColor(ccc3(0xff,0xf6,0x00))
	bottomStr:setAnchorPoint(ccp(0,0.5))
	bottomStr:setPosition(24,28)
	bg:addChild(bottomStr)

	--底部图标
	local bottomSprite = CCSprite:create("images/forge/xunlongjifen_icon.png")
	bottomSprite:setAnchorPoint(ccp(0,0.5))
	bottomSprite:setPosition(bottomStr:getPositionX()+bottomStr:getContentSize().width,bottomStr:getPositionY())
	bg:addChild(bottomSprite)

	--底部数目
	local bottomNum = CCRenderLabel:create(tostring(cellData.costPrestige),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_shadow)
	bottomNum:setColor(ccc3(0xff,0xff,0xff))
	bottomNum:setAnchorPoint(ccp(0,0.5))
	bottomNum:setPosition(bottomSprite:getPositionX()+bottomSprite:getContentSize().width,bottomStr:getPositionY())
	bg:addChild(bottomNum)

	--底部需要人物等级
    if UserModel.getHeroLevel()< tonumber(cellData.needLevel) and tonumber(cellData.needLevel) > 1 then
	    local needLvLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3131"), g_sFontPangWa, 25)
	    needLvLabel:setColor(ccc3(0x78, 0x25, 0x00))
	    needLvLabel:setAnchorPoint(ccp(0,0))
	    needLvLabel:setPosition(350, 16)
	    bg:addChild(needLvLabel)
	    local lvLabel = CCLabelTTF:create(cellData.needLevel, g_sFontPangWa, 25)
	    lvLabel:setColor(ccc3(0x00, 0x8d, 0x3d))
	    lvLabel:setAnchorPoint(ccp(0,0))
	    lvLabel:setPosition(needLvLabel:getPositionX()+needLvLabel:getContentSize().width+5, 16)
	    bg:addChild(lvLabel)
	end

	return cell
end

--点击兑换按钮，提交数据前的数据处理
function preExchange(cellData)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	--英雄等级必须达到物品兑换所需等级
	require "script/ui/tip/SingleTip"
	if UserModel.getHeroLevel() < cellData.needLevel then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_2749") .. tonumber(cellData.needLevel) .. GetLocalizeStringBy("key_3184"))
		return false
	end

	--兑换目标物品需要其它物品材料时，物品材料拥有数量不能为零
	if cellData.needItem ~= nil then
		local hasNum = ItemUtil.getCacheItemNumBy(cellData.needItem.tid)
		print("needItem",hasNum,cellData.needItem.num)
		if hasNum < cellData.needItem.num then
			SingleTip.showSingleTip(GetLocalizeStringBy("zz_103"))
			return false
		end
	end

	--能够兑换的次数次数必须大于等于1
	-- require "script/ui/exchange/FindLongExchangeLayer"
	local findDrogonNum = FindLongExchangeLayer.getFindDrogonNum()
	local canBuyNum = math.floor(findDrogonNum / tonumber(cellData.costPrestige))
	if canBuyNum < 1 then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_6"))
		return false
	end

	--剩余兑换次数必须大于等于1
	if cellData.remainExchangeNum < 1 then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_8") .. cellData.remainExchangeNum)
		return false
	end

	require "script/ui/exchange/FindLongExchangeCache"
	if not FindLongExchangeCache.canBagReceiveFeedback(cellData) then
		--已有提示
		--SingleTip.showSingleTip(GetLocalizeStringBy("key_1432"))
		return false
	end

	if not FindLongExchangeCache.canCarryHero(cellData) then
		--SingleTip.showSingleTip(GetLocalizeStringBy("key_1198"))
		return false
	end

	return true
end

--兑换成功后的回调函数
function exchangeSuccessful(cellData)

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
    local tArgs = {}
    tArgs.sign = "FindLongExchangeLayer"
    tArgs.fnCreate = FindLongExchangeLayer.create
    tArgs.reserved =  {index = 10001}
    HeroInfoLayer.createLayer(data, {isPanel=true}, nil, nil, nil, showDownMenu)
end

-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, true)
end

--[[
	@desc :	在需要物品材料的兑换表格中创建带有物品名字和数量的物品图标
	@param:	pType 类型 1:物品 2:英雄
			pItemTid 模版id
			pNum 数量
	@ret  :	CCSprite
--]]
function createItemIcon( pType, pItemTid, pNum)
	local icon = tonumber(pType) == 1 and ItemSprite.getItemSpriteById(pItemTid) or HeroUtil.getHeroIconByHTID(pItemTid)
	local data = tonumber(pType) == 1 and ItemUtil.getItemById(pItemTid) or HeroUtil.getHeroLocalInfoByHtid(pItemTid)

	local numLabel = CCRenderLabel:create(tostring(pNum), g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
	numLabel:setColor(ccc3(0x70, 0xff, 0x18))
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPosition(icon:getContentSize().width-5,2)
	icon:addChild(numLabel)

	local nameLabel = CCRenderLabel:create(data.name, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
	nameLabel:setColor(ccc3(0xff,0xe4,0x00))
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(icon:getContentSize().width*0.5,3)
	icon:addChild(nameLabel)

	return icon
end

--[[
	@desc :	在需要物品材料的兑换表格中创建带有数量的积分图标
	@param:	pNum 数量
	@ret  :	CCSprite
--]]
function createPointsIcon( pNum )
	local pointIcon = CCSprite:create("images/forge/xunlongjifen_icon.png")
	local size = pointIcon:getContentSize()

	local numLabel = CCRenderLabel:create(tostring(pNum), g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
	numLabel:setColor(ccc3(0xff,0xff,0xff))
	numLabel:setAnchorPoint(ccp(0,0.5))
	numLabel:setPosition(size.width+5,size.height*0.5)
	pointIcon:addChild(numLabel)

	pointIcon:setContentSize(CCSizeMake(size.width+numLabel:getContentSize().width+5, size.height))

	return pointIcon
end

--[[
	@desc :	创建需要物品材料的兑换表格
	@param:	pCellData 单元格数据
	@ret  :	CCTableViewCell
--]]
function createNeedItemCell( pCellData )
	local cell = CCTableViewCell:create()

	--背景
	local bg = CCScale9Sprite:create("images/reward/cell_back.png")
	bg:setPreferredSize(CCSizeMake(632,200))
	cell:addChild(bg)

	--物品背景
	local goodBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	goodBg:setPreferredSize(CCSizeMake(453,135))
	goodBg:setAnchorPoint(ccp(0,1))
	goodBg:setPosition(20,135)
	bg:addChild(goodBg)

	--名称
	local itemData = pCellData.itemsTable.type == 1 and ItemUtil.getItemById(pCellData.itemsTable.tid) or HeroUtil.getHeroLocalInfoByHtid(pCellData.itemsTable.tid)
	local nameLabel = CCRenderLabel:create(itemData.name, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
	--nameLabel:setColor(ccc3(0xff,0xe4,0x00))
	nameLabel:setColor(ccc3(0x00, 0xff, 0x18))
	nameLabel:setAnchorPoint(ccp(0,0))
	nameLabel:setPosition(35,155)
	bg:addChild(nameLabel)

	--兑换次数
	local exchangeStr = pCellData.limitType == 1 and GetLocalizeStringBy("zz_3", pCellData.remainExchangeNum) or GetLocalizeStringBy("zz_9",pCellData.remainExchangeNum)
	local exchangeNum = CCLabelTTF:create(exchangeStr, g_sFontName, 20)
	exchangeNum:setColor(ccc3(0x00,0xff,0x18))
	exchangeNum:setAnchorPoint(ccp(0,0))
	exchangeNum:setPosition(0,15)
	bg:addChild(exchangeNum)

	--兑换示意图
	local fnc = pCellData.itemsTable.type == 1 
	local exchangeMapTable = {
		[1] = {createItemIcon(1, pCellData.needItem.tid, pCellData.needItem.num)},
		[2] = {CCSprite:create("images/formation/potential/newadd.png")},
		[3] = {createPointsIcon(pCellData.costPrestige)},
		[4] = {CCSprite:create("images/recharge/change/deng.png")},
		[5] = {createItemIcon(1, pCellData.itemsTable.tid, pCellData.itemsTable.num)},
 	}
 	local positionX = 40
 	for i = 1,#exchangeMapTable do
 		exchangeMapTable[i][1]:setAnchorPoint(ccp(0,0.5))
 		exchangeMapTable[i][1]:setPosition(positionX,60)
 		goodBg:addChild(exchangeMapTable[i][1])
 		positionX = positionX + exchangeMapTable[i][1]:getContentSize().width + 5
 	end

	--按钮
	local btnMenu = BTMenu:create()
	local exchangeTable = FindLongExchangeLayer.getExchangeTable()
	btnMenu:setAnchorPoint(ccp(0,0))
	btnMenu:setPosition(474,71)
	btnMenu:setScrollView(exchangeTable)
	bg:addChild(btnMenu)

	local btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(145, 80),GetLocalizeStringBy("key_2689"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	btnMenu:addChild(btn,1,pCellData.id)

	local function btnCb(tag, itemBtn)
		if not preExchange(pCellData) then return end

		setCancanExchangeNumSp(exchangeNum)
		
		FindLongExchangeBuyLayer.showPurchaseLayer(pCellData)
	end
	btn:registerScriptTapHandler(btnCb)

	-- --底部需要人物等级
 --    if UserModel.getHeroLevel()< tonumber(pCellData.needLevel) and tonumber(pCellData.needLevel) > 1 then
	--     local needLvLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3131"), g_sFontPangWa, 25)
	--     needLvLabel:setColor(ccc3(0x78, 0x25, 0x00))
	--     needLvLabel:setAnchorPoint(ccp(0,0))
	--     needLvLabel:setPosition(350, 16)
	--     bg:addChild(needLvLabel)
	--     local lvLabel = CCLabelTTF:create(pCellData.needLevel, g_sFontPangWa, 25)
	--     lvLabel:setColor(ccc3(0x00, 0x8d, 0x3d))
	--     lvLabel:setAnchorPoint(ccp(0,0))
	--     lvLabel:setPosition(needLvLabel:getPositionX()+needLvLabel:getContentSize().width+5, 16)
	--     bg:addChild(lvLabel)
	-- end

	return cell
end

--[[
	@desc :	创建单元格
	@param:	pCellData 单元格数据
	@ret  :	CCTableViewCell
--]]
function create( pCellData )
	local cell = (pCellData.addItems == nil) and createOnlyPointCell(pCellData) or createNeedItemCell(pCellData)
	return cell
end