-- Filename：	PublicSpecialEffects.lua
-- Author：		fang
-- Date：		2013-10-18
-- Purpose：		该文件用于封装游戏中公用特效显示功能

module("PublicSpecialEffects", package.seeall)

-- 强化成功提升等级特效
function enhanceResultEffect(addLv)
	local addSprite 

	if addLv > 0 then
		addSprite = CCSprite:create("images/common/upgrade.png")
		addSprite:setAnchorPoint(ccp(0.5, 0.5))

		-- 等级
		local levelLabel = CCRenderLabel:create(addLv, g_sFontPangWa, 70, 1, ccc3(0, 0, 0), type_stroke)
		levelLabel:setColor(ccc3(255, 255, 255))
		levelLabel:setAnchorPoint(ccp(0.5, 0.5))
		levelLabel:setPosition(ccp(addSprite:getContentSize().width*161.0/270, addSprite:getContentSize().height*43/83))
		addSprite:addChild(levelLabel)
		addSprite:setPosition(ccp(0, -100))
	end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/qianghuachenggong.mp3")
	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/qianghuachenggong"), -1,CCString:create(""));
	if addSprite then
    	spellEffectSprite_2:addChild(addSprite,999)
    end
    local animation_2_End = function(actionName,xmlSprite)
        spellEffectSprite_2:removeFromParentAndCleanup(true)
    end
    spellEffectSprite_2:setScale(g_fScaleX)
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_2_End)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite_2:setDelegate(delegate)

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	spellEffectSprite_2:setPosition(ccp(runningScene:getContentSize().width*0.5, runningScene:getContentSize().height*0.5))
	runningScene:addChild(spellEffectSprite_2, 999)
end

