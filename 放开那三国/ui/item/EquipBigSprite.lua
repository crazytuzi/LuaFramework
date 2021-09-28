-- Filename：EquipBigSprite.lua
-- Author：  yangrui
-- Date：    2015-11-04
-- Purpose： 装备整合之后的装备信息的展示

module("EquipBigSprite", package.seeall)

require "script/libs/LuaCC"

local _bigSprite     = nil
local _qualitySprite = nil
local _LvSprite      = nil

local function init( ... )
	_bigSprite     = nil
	_qualitySprite = nil
	_LvSprite      = nil
end

local function create( item_tmpl_id, pItemId, pScore, pQuality )
	print("===|pItemId|===",pItemId)
	local localData = nil
	local itemData = nil
	if pItemId ~= nil then
		itemData = ItemUtil.getItemByItemId(tonumber(pItemId))
		if itemData == nil then
			itemData = ItemUtil.getEquipInfoFromHeroByItemId(tonumber(pItemId))
		end
		if table.isEmpty(itemData.itemDesc) then
			itemData.itemDesc = ItemUtil.getItemById(tonumber(itemData.item_template_id))
		end
		localData = itemData.itemDesc
	else
		require "db/DB_Item_arm"
		localData = DB_Item_arm.getDataById(item_tmpl_id)
	end
	-- 卡牌背景
    local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(37,37,1,1)
	local cardSprite = CCScale9Sprite:create("images/item/equipinfo/info_bg.png",fullRect,insetRect)
	cardSprite:setContentSize(CCSizeMake(587,530))
	-- 星级
	-- local quality = localData.quality
	-- local quality = ItemUtil.getEquipQualityByItemInfo(itemData)
	local quality = nil
	if pQuality ~= -1 then
		quality = tonumber(pQuality)
	elseif itemData ~= nil then
		quality = ItemUtil.getEquipQualityByItemInfo(itemData)
	end
	if quality == nil then
		quality = localData.quality
	end
	print("===pQuality",pQuality,quality)
	-- 星星背景
	local starsBgSp = CCSprite:create("images/formation/stars_bg.png")
	starsBgSp:setAnchorPoint(ccp(0.5,1))
	starsBgSp:setPosition(ccp(cardSprite:getContentSize().width/2,cardSprite:getContentSize().height - 30))
	cardSprite:addChild(starsBgSp,20)
	-- 星星的坐标
	local starsXPositions       = {0.5,0.4,0.6,0.3,0.7,0.2,0.8}
	local starsYPositions       = {0.75,0.74,0.74,0.71,0.71,0.68,0.68}
	local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
	local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}
	for k = 1,quality do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5,0.5))
		if ( (quality%2) ~= 0 ) then
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width*starsXPositions[k],starsBgSp:getContentSize().height*starsYPositions[k]))
		else
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width*starsXPositionsDouble[k],starsBgSp:getContentSize().height*starsYPositionsDouble[k]))
		end
		starsBgSp:addChild(starSprite)
	end
    -- 装备Sprite
    local iconSprite = nil
    if localData.new_bigicon ~= nil and quality == 7 then
	    iconSprite = CCSprite:create("images/base/equip/big/" .. localData.new_bigicon)
	else
		iconSprite = CCSprite:create("images/base/equip/big/" .. localData.icon_big)
	end
    iconSprite:setAnchorPoint(ccp(0.5,0.5))
    iconSprite:setPosition(ccp(cardSprite:getContentSize().width/2,cardSprite:getContentSize().height*0.55))
    cardSprite:addChild(iconSprite)
    -- 装备名称背景
    -- 名字 等级 背景
	itemNameBg = CCScale9Sprite:create("images/treasure/name_bg.png")
	itemNameBg:setPreferredSize(CCSizeMake(224,45))
	itemNameBg:setAnchorPoint(ccp(0.5,1))
	itemNameBg:setPosition(ccp(iconSprite:getContentSize().width*0.5,50))
	iconSprite:addChild(itemNameBg)
    -- 装备名字
    local nameLabel = CCRenderLabel:create(localData.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setAnchorPoint(ccp(0.5,0.5))
    nameLabel:setPosition(ccp(itemNameBg:getContentSize().width*0.5,itemNameBg:getContentSize().height*0.5))
    itemNameBg:addChild(nameLabel)
	-- 加入装备名字比较长，动态变动 itemNameBg 的宽
	local desNodeWidth = nameLabel:getContentSize().width
	if desNodeWidth > 224 then
		itemNameBg:setPreferredSize(CCSizeMake(desNodeWidth,45))
	end
	-- 品级
    pinSprite = CCSprite:create("images/common/pin.png")
    pinSprite:setAnchorPoint(ccp(0,0.5))
    pinSprite:setPosition(ccp(-60-pinSprite:getContentSize().width,itemNameBg:getPositionY()-itemNameBg:getContentSize().height*0.5-5))
    itemNameBg:addChild(pinSprite)
    local totalScore = tonumber(pScore)
    scoreSprite = LuaCC.createSpriteOfNumbers("images/item/equipnum",totalScore,17)
    if scoreSprite ~= nil then
        scoreSprite:setAnchorPoint(ccp(0,0.5))
        scoreSprite:setPosition(pinSprite:getPositionX()+pinSprite:getContentSize().width+5,pinSprite:getPositionY())
        itemNameBg:addChild(scoreSprite)
	end
    -- 如果是红装 则显示已进阶等级
    local nameColor = nil
    local devLv = nil
    if itemData ~= nil then
    	devLv = itemData.va_item_text.armDevelop
    end
    if devLv ~= nil and tonumber(devLv) > 0 then
    	SuitInfoLayer.setCardStatus(true)
    	local devLvLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_4000",devLv),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    	devLvLabel:setAnchorPoint(ccp(0,0.5))
    	devLvLabel:setPosition(ccp(nameLabel:getContentSize().width+5,nameLabel:getPositionY()-5))
    	devLvLabel:setColor(ccc3(0x00,0xff,0x18))
    	nameLabel:addChild(devLvLabel)
	elseif tonumber(devLv) == 0 then
		SuitInfoLayer.setCardStatus(true)
	else
		SuitInfoLayer.setCardStatus(false)
    end
	nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	nameLabel:setColor(nameColor)

    return cardSprite
end

function createSprite( item_tmpl_id, pItemId, pScore, pQuality )
    init()
	return create(item_tmpl_id,pItemId,pScore,pQuality)
end
