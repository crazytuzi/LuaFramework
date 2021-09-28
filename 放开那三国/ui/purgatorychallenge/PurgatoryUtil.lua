module("PurgatoryUtil", package.seeall)

-- 通关layer
function showPassAllEffect( ... )
	-- body
	local curScene = CCDirector:sharedDirector():getRunningScene()
	if(curScene:getChildByTag(101)~=nil)then
		curScene:removeChildByTag(101,true)
	end
	local _bgLayer = CCLayer:create()
	_bgLayer:setTouchEnabled(true)

	curScene:addChild(_bgLayer,10,101)
	--congratulation.png
	-- 已通关特效
	local _spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/purgatory/lianyu_tongguan/lianyu_tongguan"), -1,CCString:create(""));
    _spellEffectSprite:setAnchorPoint(ccp(0.5,0))
    _spellEffectSprite:retain()
    _spellEffectSprite:setScale(g_fElementScaleRatio)
    _spellEffectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_spellEffectSprite,999);
    _spellEffectSprite:release()
end