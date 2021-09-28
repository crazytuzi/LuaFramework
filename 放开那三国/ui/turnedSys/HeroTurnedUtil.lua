-- FileName: HeroTurnedUtil.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统工具类

module("HeroTurnedUtil", package.seeall)

require "script/ui/turnedSys/HeroTurnedData"
require "script/battle/BattleCardUtil"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"

--[[
	@desc	: 创建武将形象
    @param	: pTurnId 幻化id
    @param 	: pIsUnLock 是否解锁了
    @return	: CCSprite 武将形象
—-]]
function createHeroDressSpriteById( pTurnId, pIsUnLock )
 	local imgFile = HeroTurnedData.getHeroBodyImgById(pTurnId)
 	local heroSprite = nil
 	if ( pIsUnLock == false ) then
 		heroSprite = BTGraySprite:create(imgFile)
 	else
 		heroSprite = CCSprite:create(imgFile)
 	end
	return heroSprite
end

--[[
	@desc	: 创建武将卡牌
    @param	: pTurnId 幻化id
    @param 	: pIsUnLock 是否解锁了
    @return	: CCSprite 武将卡牌
—-]]
function createHeroCardSpriteById( pTurnId, pIsUnLock )
	pTurnId = tonumber(pTurnId)
	local heroInfo = HeroTurnedData.getTurnDBInfoById(pTurnId)
	local cardSprite = nil
	if (heroInfo) then
		local grade = heroInfo.star_lv or heroInfo.dress_quality
		local imageFile = heroInfo.action_module_id
		local changeY = 0
		local tipFile = "images/turnedSys/turn_tips.png"
		if (pTurnId > 0 and pTurnId < 10000) then
			if (heroInfo.littleOffset ~= nil) then
				changeY = -tonumber(heroInfo.littleOffset)
			end
			tipFile = "images/turnedSys/turn_tips.png"
		elseif (pTurnId > 10000) then
			changeY = BattleCardUtil.getDifferenceYByImageName(pTurnId,imageFile,false)
			tipFile = "images/turnedSys/hero_tips.png"
		end

		-- print("grade =>",grade,"imageFile =>",imageFile,"pIsUnLock =>",pIsUnLock,"changeY =>",changeY)

		local TempSprite = CCSprite
		local labelColor = ccc3(0x00,0xff,0x18)
		if ( pIsUnLock == false ) then
			TempSprite = BTGraySprite
			labelColor = ccc3(0x82,0x82,0x82)
		end

		-- 卡牌背景
		cardSprite = TempSprite:create("images/turnedSys/card/card_" .. (grade) .. ".png")
	    cardSprite:setAnchorPoint(ccp(0.5,0.5))
	    
	    -- 武将形象
	    local heroSprite = TempSprite:create("images/base/hero/action_module/" .. imageFile)
	    heroSprite:setAnchorPoint(ccp(0.5,0))
	    
	    heroSprite:setPosition(cardSprite:getContentSize().width/2,cardSprite:getContentSize().height*0.17+changeY)
	    cardSprite:addChild(heroSprite,2,1)
	    
		-- 顶部花纹
	    local topSprite = TempSprite:create("images/battle/card/card_" .. (grade) .. "_top.png")
	    topSprite:setAnchorPoint(ccp(0,1))
	    topSprite:setPosition(0,cardSprite:getContentSize().height)
	    cardSprite:addChild(topSprite,1,2)

		-- 阴影背景
		local shadowSprite = CCSprite:create("images/battle/card/card_shadow.png")
		shadowSprite:setAnchorPoint(ccp(0,1))
		shadowSprite:setPosition(-6,cardSprite:getContentSize().height+5)
		cardSprite:addChild(shadowSprite,-1,5)
	    
	    -- 武将背景
	    local heroBgSprite = TempSprite:create("images/battle/card/card_hero_bg.png");
	    heroBgSprite:setAnchorPoint(ccp(0.5,0))
	    heroBgSprite:setPosition(cardSprite:getContentSize().width/2,cardSprite:getContentSize().height*0.17)
	    cardSprite:addChild(heroBgSprite,0,8)

	    -- 经典/稀有
	    local tipSprite = TempSprite:create(tipFile)
	    tipSprite:setAnchorPoint(ccp(0.5,0.5))
	    tipSprite:setPosition(10,cardSprite:getContentSize().height-10)
	    cardSprite:addChild(tipSprite,3)

	    -- 武将星级
	    for i=1,grade do
	    	local starSprite = TempSprite:create("images/common/small_star.png")
			starSprite:setAnchorPoint(ccp(0,0.5))
			starSprite:setPosition(5+(i-1)*15,12)
			starSprite:setScale(0.7)
			cardSprite:addChild(starSprite,1)
	    end

	    -- 属性加成
	    local attrArr = HeroTurnedData.getTurnAttrArrById(pTurnId)
	    local i = 0
	    for k,v in pairs(attrArr) do
	    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
	    	local attrStr = affixDesc.sigleName .. ": +" .. displayNum

	    	local attrStrLabel = CCRenderLabel:create(attrStr,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrStrLabel:setColor(labelColor)
			attrStrLabel:setAnchorPoint(ccp(0.5,1))
			attrStrLabel:setPosition(ccp(cardSprite:getContentSize().width*0.5, -15-i*25))
			cardSprite:addChild(attrStrLabel,3)
			i = i + 1
		end
	end
    return cardSprite
end

function createTurnNameSpriteById( pTurnId, pIndex, pIsUnLock )
	-- 形象名称
	local nameBg = CCScale9Sprite:create("images/common/bg/9s_purple.png")
	nameBg:setContentSize(CCSizeMake(260,40))

	-- 标识
	local tipFile = "images/turnedSys/turn_tips.png"
	if (tonumber(pTurnId) > 10000 or pIndex == 1) then
		tipFile = "images/turnedSys/hero_tips.png"
	end
	local TempSprite = CCSprite
	if ( pIsUnLock == false ) then
		TempSprite = BTGraySprite
	end
	-- 经典/稀有
	local tipSprite = TempSprite:create(tipFile)
	tipSprite:setAnchorPoint(ccp(0.5,0.5))
	tipSprite:setPosition(50,nameBg:getContentSize().height-5)
	nameBg:addChild(tipSprite,3)

	local nameStr = HeroTurnedData.getTurnedNameById(pTurnId,pIndex)
	local nameLabel = CCRenderLabel:create(nameStr, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local nameColor = pIsUnLock and ccc3(0xff,0xf6,0x00) or ccc3(0x82, 0x82, 0x82)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5,0.5))
	nameLabel:setPosition(ccp(nameBg:getContentSize().width*0.5, nameBg:getContentSize().height*0.5))
	nameBg:addChild(nameLabel)

	return nameBg
end

--[[
	@desc	: 通过形象id创建武将头像
    @param	: pTurnId 形象id
    @return	: 
—-]]
function createHeroHeadIconById( pTurnId )
	local heroInfo = HeroTurnedData.getTurnDBInfoById(pTurnId)
	local quality = heroInfo.potential or heroInfo.dress_quality
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. quality .. ".png")
	local headFile = HeroTurnedData.getHeroHeadIconById(pTurnId)
	local iconSprite = CCSprite:create(headFile)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
	bgSprite:addChild(iconSprite)
	return bgSprite
end

--[[
	@desc	: 创建箭头闪烁动画
	@param	: pArrow 箭头精灵
	@return : 
--]]
function runArrowAction( pArrow )
	local actionArrs = CCArray:create()
	actionArrs:addObject(CCFadeOut:create(1))
	actionArrs:addObject(CCFadeIn:create(1))
	local sequenceAction = CCSequence:create(actionArrs)
	local foreverAction = CCRepeatForever:create(sequenceAction)
	pArrow:runAction(foreverAction)
end

--[[
	@desc	: 获取武将形象的全身像偏移量
    @param	: pTurnId 幻化id
    @return	: number 全身像偏移量
—-]]
function getHeroBodyOffsetById( pTurnId )
	pTurnId = tonumber(pTurnId)
	local bodyOffset = 0
	if (pTurnId > 0 and pTurnId < 10000) then
		local heroInfo = HeroTurnedData.getTurnDBInfoById(pTurnId)
		if (heroInfo.herosOffset ~= nil) then
			bodyOffset = tonumber(heroInfo.herosOffset)
		end
	elseif (pTurnId > 10000) then
		bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(pTurnId)
	end
	return bodyOffset
end
