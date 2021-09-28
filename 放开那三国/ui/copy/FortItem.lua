-- Filename：	FortItem.lua
-- Author：		Cheng Liang
-- Date：		2013-5-27
-- Purpose：		据点的按钮

module("FortItem", package.seeall)



require "script/ui/common/LuaMenuItem"

--[[
 @desc	 创建一个据点的menuItem
 @para 	 table fortData
 @return CCMenuItemImage
 --]]
function createItemImage(fortData, isNeedOpenedAnimated, isNeedStar )
	if(isNeedStar == nil )then
		isNeedStar = true
	end

	require "script/utils/LuaUtil"
	local pngIndex = string.sub(fortData.fortInfo.looks.look.modelURL, 1, 1)
	

	local normalSprite		= CCSprite:create("images/copy/ncopy/fortpotential/" .. pngIndex .. ".png")
	local highlightedSprite = CCSprite:create("images/copy/ncopy/fortpotential/" .. pngIndex .. ".png")
	-- 图片 
	local icon_sp = CCSprite:create("images/base/hero/head_icon/" .. fortData.icon)
	icon_sp:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *0.53))
	normalSprite:addChild(icon_sp)

	local icon_sp_h = CCSprite:create("images/base/hero/head_icon/" .. fortData.icon)
	icon_sp_h:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp_h:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *0.53))
	highlightedSprite:addChild(icon_sp_h)

	highlightedSprite:setScale(0.9)


	-- 按钮
	local menuItem = LuaMenuItem.createItemSprite(normalSprite, highlightedSprite)
	local menuItemSize = menuItem:getContentSize()

	

	-- 文字
	local titleLabel = CCRenderLabel:create(fortData.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- titleLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf5, 0x83), ccc3( 0xff, 0xde, 0x00));
    titleLabel:setColor(ccc3(0xff, 0xff, 0xff))
    titleLabel:setPosition(ccp( (menuItemSize.width-titleLabel:getContentSize().width)/2 , menuItemSize.height*1.2))
    menuItem:addChild(titleLabel)

    local curBaseStars = 0
    local progressState = tostring(fortData.progressStatus)
    if (progressState <= "2") then
		curBaseStars = 0
	elseif (progressState == "3") then
		curBaseStars = 1
	elseif (progressState == "4") then
		curBaseStars = 2
	elseif (progressState == "5") then
		curBaseStars = 3
	else
		curBaseStars = 0
	end

	local totalStars = 0

	if(fortData.npc_army_ids_simple or fortData.army_ids_simple)then
		totalStars = totalStars + 1
	end
	if(fortData.army_num_normal)then
		totalStars = totalStars + 1
	end
	if(fortData.army_ids_hard)then
		totalStars = totalStars + 1
	end

	if(isNeedStar == true)then
	    for i=1,totalStars do
	    	local starSprite = nil
	    	if (curBaseStars < i) then
		    	starSprite = BTGraySprite:create("images/hero/star.png")
		    else
		    	starSprite = CCSprite:create("images/hero/star.png")
		    end
	    	starSprite:setAnchorPoint(ccp(0.5, 0.5))
	    	
	    	if(totalStars == 1)then
	    		starSprite:setPosition(ccp(menuItemSize.width/2 , -menuItemSize.height * 0.1))
	    	elseif(totalStars == 2)then
	    		starSprite:setPosition(ccp(menuItemSize.width/2 - ( 1.5-i ) *starSprite:getContentSize().width* 1.1 , -menuItemSize.height * 0.1))
	    	else
	    		starSprite:setPosition(ccp(menuItemSize.width/2 - ( 2-i ) *starSprite:getContentSize().width* 1.1 , -menuItemSize.height * 0.1))
	    	end

	    	menuItem:addChild(starSprite)
	    end
	end

    if (isNeedOpenedAnimated) then
    	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/fubenkegongji01"), -1,CCString:create(""));
	    spellEffectSprite:retain()
	    spellEffectSprite:setPosition(menuItem:getContentSize().width/2,0)
	    -- spellEffectSprite:setAnchorPoint(ccp(0.5, 0));
	    menuItem:addChild(spellEffectSprite,-1);
	    spellEffectSprite:release()

	    local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/fubenkegongji02"), -1,CCString:create(""));
	    spellEffectSprite_2:retain()
	    -- spellEffectSprite_2:setAnchorPoint(ccp(1, 0));
	    spellEffectSprite_2:setPosition(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height)
	    menuItem:addChild(spellEffectSprite_2,1);
	    spellEffectSprite_2:release()
    end
	-- local mod = math.mod(fortData.fortInfo.looks.look.armyID,5) +1
	-- local itemImage = CCMenuItemImage:create("images/copy/ncopy/fortimage/fort" .. mod .. ".png", "images/copy/ncopy/fortimage/fort" .. mod .. ".png")
	
	return menuItem
end

