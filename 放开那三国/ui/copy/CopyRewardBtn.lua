-- Filename：	CopyRewadBtn.lua
-- Author：		Cheng Liang
-- Date：		2013-7-3
-- Purpose：		副本奖励按钮

module("CopyRewardBtn", package.seeall)




function createBtn( type_str, status, stars )
	local menuItem = CCMenuItemImage:create("images/copy/reward/box/box_" .. type_str .. "_" .. status .. "_n.png", "images/copy/reward/box/box_" .. type_str .. "_" .. status .. "_h.png")

	if( tonumber(status) == 2)then
		if("copper" == type_str)then
			-- 铜宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/copperBox/tongxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite);
		    spellEffectSprite:release()

		elseif("silver" == type_str)then
			-- 银宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/silverBox/yinxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite);
		    spellEffectSprite:release()
		elseif("gold" == type_str)then
			-- 金宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/goldBox/jinxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5+3,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite);
		    spellEffectSprite:release()
		end
	end


	-- 星星数
	local starsLabel = CCRenderLabel:create(stars, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- starsLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf5, 0x83), ccc3( 0xff, 0xde, 0x00));
    starsLabel:setColor(ccc3(0xf2, 0xf7, 0x7e))
    starsLabel:setPosition(ccp( menuItem:getContentSize().width*0.35 , menuItem:getContentSize().height*0.6))
    menuItem:addChild(starsLabel)

	-- 星星sp
	local star_sprite = CCSprite:create("images/hero/star.png")
	star_sprite:setAnchorPoint(ccp(0, 0))
	star_sprite:setPosition(ccp(menuItem:getContentSize().width*0.8, menuItem:getContentSize().height*0.2))
	menuItem:addChild(star_sprite)
	return menuItem
end

function createEffect(type_str)
	local effectName = ""
	if("copper" == type_str)then
		-- 铜宝箱
		effectName = CCString:create("images/base/effect/copy/copperBox/tongxiangzi")
	elseif("silver" == type_str)then
		-- 银宝箱
		effectName = CCString:create("images/base/effect/copy/silverBox/yinxiangzi")
	elseif("gold" == type_str)then
		-- 金宝箱
		effectName = CCString:create("images/base/effect/copy/goldBox/jinxiangzi")
	end
	return CCLayerSprite:layerSpriteWithName(effectName, -1,CCString:create(""));
end
