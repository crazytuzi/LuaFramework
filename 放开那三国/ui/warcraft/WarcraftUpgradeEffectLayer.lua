-- Filename: WarcraftUpgradeEffectLayer.lua
-- Author: bzx
-- Date: 2014-11-27
-- Purpose: 阵法升级成功特效


module("WarcraftUpgradeEffectLayer", package.seeall)



local _layer
local _warcraftData
local _touchPriority = -2000
local _zOder = 1100


function show(warcraftData)
	_layer = create(warcraftData)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOder)
end

function init(warcraftData)
	_warcraftData = warcraftData
end

function create(warcraftData)
	init(warcraftData)
	_layer = CCLayerColor:create(ccc4(0, 0, 0, 255))
	_layer:registerScriptHandler(onNodeEvent)
	loadTitle()
	loadEffect()
	loadAffixes()
	return _layer
end

function loadTitle( ... )
	local title = WarcraftLayer.createWarcraftName(_warcraftData.id)
	_layer:addChild(title, 10)
	title:setAnchorPoint(ccp(0.5, 0.5))
	title:setPosition(ccpsprite(0.5, 0.95, _layer))
	title:setScale(MainScene.elementScale)
end

function loadEffect( ... )
	local effect = WarcraftLayer.createWarcraftEffect(_warcraftData.id)
	_layer:addChild(effect)
	effect:setAnchorPoint(ccp(0.5, 0.5))
	effect:setPosition(ccpsprite(0.5, 0.74, _layer))
	effect:setScale(MainScene.elementScale * 0.78)

	local sImgPath=CCString:create("images/warcraft/qianghuachenggong1/qianghuachenggong1")
	local tipEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1, CCString:create(""))
	_layer:addChild(tipEffect)
	tipEffect:setPosition(ccpsprite(0.5, 0.45, _layer))
	effect:setScale(MainScene.elementScale)
end

function loadAffixes( ... )
	local affixType = WarcraftData.getAffixType(_warcraftData.id)
	local affixValues2 = WarcraftData.getAffixValue(_warcraftData.id)
	local affixValues1 = WarcraftData.getAffixValue(_warcraftData.id, _warcraftData.level - 1)
	local affixImages = {"attack.png", "magic_double_defend.png", "life.png"}
	local y = g_winSize.height * 0.35
	for i=1, #affixType do
		local affixName=CCSprite:create("images/hero/transfer/level_up/" .. affixImages[affixType[i]])
		affixName:setScale(MainScene.elementScale)
		affixName:setAnchorPoint(ccp(0, 0.5))
		affixName:setPosition(0.117*g_winSize.width, y)
		_layer:addChild(affixName)

		local affixValue1 = CCLabelTTF:create(tostring(affixValues1[i]), g_sFontName, 35)
		affixValue1:setScale(MainScene.elementScale)
		affixValue1:setColor(ccc3(255, 0x6c, 0))
		affixValue1:setPosition(0.297*g_winSize.width, y)
		affixValue1:setAnchorPoint(ccp(0, 0.5))
		_layer:addChild(affixValue1)
		-- 箭头特效
		local sImgPathArrow=CCString:create("images/base/effect/hero/transfer/jiantou")
		local clsEffectArrow=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathArrow:getCString(), -1, CCString:create(""))
		clsEffectArrow:setScale(MainScene.elementScale)
		clsEffectArrow:setAnchorPoint(ccp(0, 0.5))
		clsEffectArrow:setPosition(0.578*g_winSize.width, y)
		_layer:addChild(clsEffectArrow, 1001, 1003)

		local affixValue2 = CCLabelTTF:create(affixValues2[i], g_sFontName, 35)
		affixValue2:setScale(MainScene.elementScale)
		affixValue2:setPosition(0.7*g_winSize.width, y)
		affixValue2:setColor(ccc3(0x67, 0xf9, 0))
		affixValue2:setAnchorPoint(ccp(0, 0.5))
		_layer:addChild(affixValue2)

		if affixValues2[i] - affixValues1[i] > 0 then
			local csArrowGreen = CCSprite:create("images/hero/transfer/arrow_green.png")
			csArrowGreen:setScale(MainScene.elementScale)
			csArrowGreen:setPosition(0.85*g_winSize.width, y)
			csArrowGreen:setAnchorPoint(ccp(0, 0.5))
			_layer:addChild(csArrowGreen, 1001, 1005)
		end
		y = y - 50 * MainScene.elementScale
	end
end

function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority - 2, true)
        _layer:setTouchEnabled(true)
    elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler(event, x, y)
    if event == "began" then
        return true
    elseif event == "moved" then
    elseif event == "ended" or event == "cancelled" then
    	_layer:removeFromParentAndCleanup(true)
    end
end