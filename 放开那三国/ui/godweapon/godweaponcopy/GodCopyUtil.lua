
-- Filename：	GodCopyUtil.lua
-- Author：		Chengliang
-- Date：		2014-12-16
-- Purpose：		购买buff界面


module("GodCopyUtil", package.seeall)



function showGodCopySprite( p_title )
	-- runningscence
	local layer = CCLayer:create()

	local onTouchesHandler= function (eventType,x,y)
		if eventType == "began" then
		    return true
	    elseif eventType == "moved" then
	    else
		end
	end

    local onNodeEvent = function (event)
		if event == "enter" then
			layer:registerScriptTouchHandler(onTouchesHandler,false,-1000,true)
			layer:setTouchEnabled(true)
		elseif event == "exit" then
			if(layer ~= nil)then
				layer:unregisterScriptTouchHandler()
			end
		end
	end
	local moveEnd = function ( ... )
	    if(layer ~= nil)then
	    	layer:removeFromParentAndCleanup(true)
			layer = nil
		end
    end

	local curScene = CCDirector:sharedDirector():getRunningScene()
	layer:registerScriptHandler(onNodeEvent)
    curScene:addChild(layer,4001)
    layer:setTag(757)
    --灰色背景图
    local containSprite = CCScale9Sprite:create("images/god_weapon/view_bg_3.png")
    containSprite:setContentSize(CCSizeMake(g_winSize.width/MainScene.elementScale,90))
    containSprite:setScale(MainScene.elementScale)

    containSprite:setAnchorPoint(ccp(0,0.5))
    layer:addChild(containSprite)
    containSprite:setPosition(ccp(g_winSize.width,g_winSize.height*0.5))
    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(containSprite:getContentSize().width*0.35,containSprite:getContentSize().height *0.5))
    containSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    rightFlower:setScaleX(-1)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(containSprite:getContentSize().width*0.65,containSprite:getContentSize().height *0.5))
    containSprite:addChild(rightFlower)

    local titleStr = p_title or " "
    local titleLabel = CCRenderLabel:create(titleStr,g_sFontPangWa,42,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	titleLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(containSprite:getContentSize().width *0.5,containSprite:getContentSize().height *0.5))
	containSprite:addChild(titleLabel)


    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(0.1))
    --走进来
    actionArray:addObject(CCMoveTo:create(0.1,ccp(0,g_winSize.height*0.5)))
    --停留
    actionArray:addObject(CCDelayTime:create(0.4))
    --走出去
	actionArray:addObject(CCMoveTo:create(0.1,ccp(-g_winSize.width,g_winSize.height*0.5)))
	actionArray:addObject(CCCallFuncN:create(moveEnd))
	local seqAction = CCSequence:create(actionArray)
	containSprite:runAction(seqAction)

end

-- 小手
function figleEffectAction()
	local bgSprite = CCSprite:create()
	bgSprite:setContentSize(CCSizeMake(300, 200))

	local m_sprite = CCSprite:create("images/godweaponcopy/little_handle.png")
	m_sprite:setAnchorPoint(ccp(0.5, 0))
	m_sprite:setPosition(ccp(150, 35))
	bgSprite:addChild(m_sprite)

	local m_y = 20
	local actionArray = CCArray:create()
	local moveUp = CCMoveBy:create(0.5, ccp(0, m_y))
    actionArray:addObject(moveUp)

    local moveDown = CCMoveBy:create(0.5, ccp(0, -m_y))
    actionArray:addObject(moveDown)

    m_sprite:runAction(CCRepeatForever:create(CCSequence:create(actionArray)))

    -- 文字
    --关卡名称
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10038"), g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	tipLabel:setColor(ccc3(0xff,0xff,0xff))
	bgSprite:addChild(tipLabel)
	tipLabel:setAnchorPoint(ccp(0.5,0))
	tipLabel:setPosition(ccp(150, 0))

    return bgSprite
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

-- 通关layer
function showPassAllEffect( ... )
	-- body
	local _bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -99999, true)
	_bgLayer:setTouchEnabled(true)
	local curScene = CCDirector:sharedDirector():getRunningScene()

	curScene:addChild(_bgLayer,3200)
	--congratulation.png
	local shineSprite = CCSprite:create("images/godweaponcopy/shine.png")
	shineSprite:setAnchorPoint(ccp(0.5,0.5))
	shineSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.6))
	_bgLayer:addChild(shineSprite)

	local congratulationSprite = CCSprite:create("images/godweaponcopy/congratulation.png")
	congratulationSprite:setAnchorPoint(ccp(0.5,0.5))
	congratulationSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.6))
	_bgLayer:addChild(congratulationSprite)

	local actionArr = CCArray:create()
    actionArr:addObject(CCRotateTo:create(2,360*2))
    actionArr:addObject(CCCallFunc:create(function ( ... )
    	_bgLayer:unregisterScriptTouchHandler()
        _bgLayer:setVisible(false)
        shineSprite:setVisible(false)
        shineSprite:removeFromParentAndCleanup(true)
        _bgLayer:removeFromParentAndCleanup(true)
    end))
    shineSprite:runAction(CCSequence:create(actionArr))

end

-- 转场过渡效果
function addNextTransActionEffect()
	local bgLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
	bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -99999, true)
	bgLayer:setTouchEnabled(true)
	local curScene = CCDirector:sharedDirector():getRunningScene()

	curScene:addChild(bgLayer,4002)

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(0.5))
    actionArray:addObject(CCFadeOut:create(1))
    actionArray:addObject(CCCallFuncN:create(function( ... )
    	bgLayer:unregisterScriptTouchHandler()
    	bgLayer:setVisible(false)
    	bgLayer:removeFromParentAndCleanup(true)
    end))
    bgLayer:runAction(CCSequence:create(actionArray))

end




