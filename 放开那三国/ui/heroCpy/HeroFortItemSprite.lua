-- Filename：	HeroFortItemSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-9-22
-- Purpose：		据点的sprite

module ("HeroFortItemSprite", package.seeall)

-- 创建Sprite
function createSprite( hardLevel, strongholdInfo)

	local bgSpriteName = "images/copy/ncopy/hard_" .. hardLevel .. ".png"

	local bgSprite = nil

	local distance = hardLevel

	-- 银币等
	local silverNum = nil
	local expNum = nil
	local energyNum = nil
	local soulNum = nil
	
	silverNum = 0
	expNum	  = 0
	soulNum	  = 0
	energyNum = 0
	

	-- 银币等颜色
	local textColor = nil

	-- if(distance>1)then
	-- 	bgSprite = BTGraySprite:create(bgSpriteName)
	-- 	-- 战斗
	-- 	local fightNode = BTGraySprite:create("images/common/btn/btn_red2_n.png")
	-- 	fightNode:setAnchorPoint(ccp(0.5, 0.5))
	-- 	fightNode:setPosition(ccp(500, 85))
	-- 	bgSprite:addChild(fightNode)
	-- 	local grayFightLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2565"), g_sFontPangWa, 30, 3, ccc3( 0x00, 0x00, 0x00), type_stroke)
	--     grayFightLabel:setColor(ccc3( 155, 155, 155))
	--     grayFightLabel:setPosition(ccp( (fightNode:getContentSize().width - grayFightLabel:getContentSize().width)/2, 
	--     			(fightNode:getContentSize().height - (fightNode:getContentSize().height - grayFightLabel:getContentSize().height)/2) ))
	--     fightNode:addChild(grayFightLabel)

	--     -- 颜色
	--     textColor = ccc3(155, 155, 155)
	   
	-- else
		bgSprite = CCSprite:create(bgSpriteName)
		-- 战斗
		local fightMenuBar = CCMenu:create()
		fightMenuBar:setPosition(ccp(0, 0))
		bgSprite:addChild(fightMenuBar, 2, 1002)
		fightMenuBar:setTouchPriority(-411)
		-- 战斗按钮
		--兼容东南亚英文版
		local fightBtn
		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
			fightBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red2_n.png","images/common/btn/btn_red2_h.png",CCSizeMake(119, 83),GetLocalizeStringBy("key_2565"),ccc3(0xfe, 0xdb, 0x1c),20,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		else
			fightBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red2_n.png","images/common/btn/btn_red2_h.png",CCSizeMake(119, 83),GetLocalizeStringBy("key_2565"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		end
		fightBtn:setAnchorPoint(ccp(0.5, 0.5))
		fightBtn:setPosition(ccp(500, 85))
		fightBtn:registerScriptTapHandler( HeroFortInfoLayer.fightAction)
		fightMenuBar:addChild(fightBtn, 2, 10000+hardLevel)

		-- 颜色
		textColor = ccc3(255, 255, 255)



	    -- -- 条件字符串
	    -- local starConditionLabel = CCRenderLabel:create(CopyUtil.getStarCondition(hardLevel, strongholdInfo), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    -- starConditionLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    -- starConditionLabel:setPosition(ccp( 200, 30))
	    -- starConditionLabel:setAnchorPoint(ccp(0, 0.5))
	    -- bgSprite:addChild(starConditionLabel)
	-- end

	--  银币
	local silverLabel = CCRenderLabel:create(tostring(silverNum), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    silverLabel:setColor(textColor)
    silverLabel:setPosition(ccp( 180, 110))
    bgSprite:addChild(silverLabel)

    --  将魂
	local soulLabel = CCRenderLabel:create(soulNum, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soulLabel:setColor(textColor)
    soulLabel:setPosition(ccp( 180, 75))
    bgSprite:addChild(soulLabel)

	return bgSprite
end
