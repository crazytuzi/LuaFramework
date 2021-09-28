-- Filename：	PassHeroCopyLayer.lua
-- Author：		chengliang
-- Date：		2014-4-26
-- Purpose：		列传通关


module ("PassHeroCopyLayer", package.seeall)



local _bgLayer

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -560, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	HeroLayout.closeFortsLayoutAction()
end


function showLayer(htid,hard,addnum)
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 2000)


	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local tipSprite = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	tipSprite:setPreferredSize(CCSizeMake(520, 360))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(tipSprite)
	tipSprite:setScale(g_fScaleX)	

	local alertBgSize = tipSprite:getContentSize()

	-- 特效
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/gongxitongguan/gongxitongguan"), 1,CCString:create(""));
    spellEffectSprite:setPosition(ccp( tipSprite:getContentSize().width*0.5,tipSprite:getContentSize().height*0.95) )
    tipSprite:addChild(spellEffectSprite,1);

    local animationEnd = function(actionName,xmlSprite)
        spellEffectSprite:cleanup()
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)

    --
    local innerSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerSprite:setContentSize(CCSizeMake(450, 210))
	innerSprite:setAnchorPoint(ccp(0.5, 0.5))
	innerSprite:setPosition(ccp(tipSprite:getContentSize().width*0.5,tipSprite:getContentSize().height*0.6))
	tipSprite:addChild(innerSprite)

	-- 武将头像
	local heroIcon = HeroUtil.getHeroIconByHTID(htid)
	heroIcon:setAnchorPoint(ccp(0, 0))
	heroIcon:setPosition(ccp(25, 50))
	innerSprite:addChild(heroIcon)
	local heroDB = DB_Heroes.getDataById(htid)
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDB.potential)
	local nameLabel = CCLabelTTF:create(heroDB.name, g_sFontPangWa, 18)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 1))
	nameLabel:setPosition(ccp(heroIcon:getContentSize().width*0.5, heroIcon:getContentSize().height*0))
	heroIcon:addChild(nameLabel)

	-- 通关文字  
	
	-- 简单绿 普通黄 困难红
	local hardFont = {GetLocalizeStringBy("lic_1036"), GetLocalizeStringBy("lic_1037"), GetLocalizeStringBy("lic_1038")}
	local hardColor = {ccc3(0x00,0xff,0x18), ccc3(0xff,0xf6,0x00), ccc3(0xe8,0x00,0x00)}

	-- 第一行
	local oneStr1 = GetLocalizeStringBy("lic_1039")
	local oneStr2 = heroDB.name
	local oneStr3 = GetLocalizeStringBy("lic_1040")
	local oneStr4 = hardFont[tonumber(hard)]
	local oneStr5 = GetLocalizeStringBy("lic_1041")
	local oneFont1 = CCLabelTTF:create(oneStr1, g_sFontPangWa, 23)
	oneFont1:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont1:setAnchorPoint(ccp(0, 0))
	oneFont1:setPosition(ccp(135, 130))
	innerSprite:addChild(oneFont1)
	local oneFont2 = CCLabelTTF:create(oneStr2, g_sFontPangWa, 23)
	oneFont2:setColor(nameColor)
	oneFont2:setAnchorPoint(ccp(0, 0))
	oneFont2:setPosition(ccp(oneFont1:getPositionX()+oneFont1:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont2)
	local oneFont3 = CCLabelTTF:create(oneStr3, g_sFontPangWa, 23)
	oneFont3:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont3:setAnchorPoint(ccp(0, 0))
	oneFont3:setPosition(ccp(oneFont2:getPositionX()+oneFont2:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont3)
	local oneFont4 = CCLabelTTF:create(oneStr4, g_sFontPangWa, 23)
	oneFont4:setColor(hardColor[tonumber(hard)])
	oneFont4:setAnchorPoint(ccp(0, 0))
	oneFont4:setPosition(ccp(oneFont3:getPositionX()+oneFont3:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont4)
	local oneFont5 = CCLabelTTF:create(oneStr5, g_sFontPangWa, 23)
	oneFont5:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont5:setAnchorPoint(ccp(0, 0))
	oneFont5:setPosition(ccp(oneFont4:getPositionX()+oneFont4:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont5)

	-- 第二行
	if(hardFont[tonumber(hard)+1] ~= nil and (tonumber(hard)+1)~=3)then
		local twoStr1 = heroDB.name
		local twoStr2 = GetLocalizeStringBy("lic_1040")
		local twoStr3 = hardFont[tonumber(hard)+1]
		local twoStr4 = GetLocalizeStringBy("lic_1042")
		local twoFont1 = CCLabelTTF:create(twoStr1, g_sFontPangWa, 23)
		twoFont1:setColor(nameColor)
		twoFont1:setAnchorPoint(ccp(0, 0))
		twoFont1:setPosition(ccp(135, 80))
		innerSprite:addChild(twoFont1)
		local twoFont2 = CCLabelTTF:create(twoStr2, g_sFontPangWa, 23)
		twoFont2:setColor(ccc3(0xff,0xff,0xff))
		twoFont2:setAnchorPoint(ccp(0, 0))
		twoFont2:setPosition(ccp(twoFont1:getPositionX()+twoFont1:getContentSize().width, twoFont1:getPositionY()))
		innerSprite:addChild(twoFont2)
		local twoFont3 = CCLabelTTF:create(twoStr3, g_sFontPangWa, 23)
		twoFont3:setColor(hardColor[tonumber(hard)])
		twoFont3:setAnchorPoint(ccp(0, 0))
		twoFont3:setPosition(ccp(twoFont2:getPositionX()+twoFont2:getContentSize().width, twoFont1:getPositionY()))
		innerSprite:addChild(twoFont3)
		local twoFont4 = CCLabelTTF:create(twoStr4, g_sFontPangWa, 23)
		twoFont4:setColor(ccc3(0xff,0xff,0xff))
		twoFont4:setAnchorPoint(ccp(0, 0))
		twoFont4:setPosition(ccp(twoFont3:getPositionX()+twoFont3:getContentSize().width, twoFont1:getPositionY()))
		innerSprite:addChild(twoFont4)
	end

	-- 第三行
	local threeStr1 = heroDB.name
	local threeStr2 = GetLocalizeStringBy("lic_1043") .. addnum 
	local threeStr3 = GetLocalizeStringBy("lic_1044")
	local threeFont1 = CCLabelTTF:create(threeStr1, g_sFontPangWa, 23)
	threeFont1:setColor(nameColor)
	threeFont1:setAnchorPoint(ccp(0, 0))
	threeFont1:setPosition(ccp(135, 30))
	innerSprite:addChild(threeFont1)
	local threeFont2 = CCLabelTTF:create(threeStr2, g_sFontPangWa, 23)
	threeFont2:setColor(ccc3(0xff,0xff,0xff))
	threeFont2:setAnchorPoint(ccp(0, 0))
	threeFont2:setPosition(ccp(threeFont1:getPositionX()+threeFont1:getContentSize().width, threeFont1:getPositionY()))
	innerSprite:addChild(threeFont2)
	local threeFont3 = CCLabelTTF:create(threeStr3, g_sFontPangWa, 23)
	threeFont3:setColor(ccc3(0xff,0xff,0xff))
	threeFont3:setAnchorPoint(ccp(0, 0))
	threeFont3:setPosition(ccp(threeFont2:getPositionX()+threeFont2:getContentSize().width, threeFont1:getPositionY()))
	innerSprite:addChild(threeFont3)
	local sprite = CCSprite:create("images/biography/awaken" .. hard .. ".png")
	sprite:setAnchorPoint(ccp(0,0))
	sprite:setPosition(ccp(threeFont3:getPositionX()+threeFont3:getContentSize().width, threeFont1:getPositionY()))
	innerSprite:addChild(sprite)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-5601)
	tipSprite:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1696"), ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:registerScriptTapHandler(closeAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	confirmBtn:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.2))



end

