-- Filename：	FortItemSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-9-22
-- Purpose：		据点的sprite

module ("FortItemSprite", package.seeall)

-- 创建Sprite
function createSprite( hardLevel, strongholdInfo, curBaseStars, defeat_num )

	local bgSpriteName = "images/copy/ncopy/hard_" .. hardLevel .. ".png"

	local bgSprite = nil

	local distance = hardLevel - curBaseStars

	-- 银币等
	local silverNum = nil
	local expNum = nil
	local energyNum = nil
	local soulNum = nil
	if(hardLevel == 1) then
		silverNum = strongholdInfo.coin_simple or 0
		expNum	  = strongholdInfo.exp_simple or 0
		soulNum	  = strongholdInfo.soul_simple or 0
		energyNum = strongholdInfo.cost_energy_simple or 0
	elseif(hardLevel == 2) then
		silverNum = strongholdInfo.coin_normal or 0
		expNum	  = strongholdInfo.exp_normal or 0
		soulNum	  = strongholdInfo.soul_normal or 0
		energyNum = strongholdInfo.cost_energy_normal or 0
	elseif(hardLevel == 3) then
		silverNum = strongholdInfo.coin_hard or 0
		expNum	  = strongholdInfo.exp_hard or 0
		soulNum	  = strongholdInfo.soul_hard or 0
		energyNum = strongholdInfo.cost_energy_hard or 0
	end
	require "script/ui/rechargeActive/BenefitActiveLayer"
	local isOpen, openData = BenefitActiveLayer.isNormalCopyOpen()
	if(isOpen == true)then
		
		local silverRate = 1
		local soulRate = 1
		local expRate = 1
		local str1_arr = string.split(openData, ",")
		for k,v in pairs(str1_arr) do
			local str2_arr = string.split(v, "|")

			if(tonumber(str2_arr[1]) == 1 )then
				-- 银币
				silverRate = tonumber(str2_arr[2])/10000
			end
			if(tonumber(str2_arr[1]) == 2 )then
				-- 战魂
				soulRate = tonumber(str2_arr[2])/10000
			end
			if(tonumber(str2_arr[1]) == 3 )then
				-- 经验
				expRate = tonumber(str2_arr[2])/10000
			end
			
		end

		silverNum = silverNum * silverRate
		soulNum = soulNum * soulRate
	end


	-- 银币等颜色
	local textColor = nil

	-- 星星
	local starSprite = nil

	if(distance>1)then
		bgSprite = BTGraySprite:create(bgSpriteName)
		-- 战斗
		local fightNode = BTGraySprite:create("images/common/btn/btn_red2_n.png")
		fightNode:setAnchorPoint(ccp(0.5, 0.5))
		fightNode:setPosition(ccp(500, 85))
		bgSprite:addChild(fightNode)
		local grayFightLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2565"), g_sFontPangWa, 30, 3, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    grayFightLabel:setColor(ccc3( 155, 155, 155))
	    grayFightLabel:setPosition(ccp( (fightNode:getContentSize().width - grayFightLabel:getContentSize().width)/2, 
	    			(fightNode:getContentSize().height - (fightNode:getContentSize().height - grayFightLabel:getContentSize().height)/2) ))
	    fightNode:addChild(grayFightLabel)

	    -- 颜色
	    textColor = ccc3(155, 155, 155)

	    -- 星星
	    starSprite = BTGraySprite:create("images/hero/star.png")
	   
	else
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
		fightBtn:registerScriptTapHandler( FortInfoLayer.fightAction)
		fightMenuBar:addChild(fightBtn, 2, 10000+hardLevel)

		-- 颜色
		textColor = ccc3(255, 255, 255)

	    -- 星星
	    starSprite = BTGraySprite:create("images/hero/star.png")

	    -- 得星条件
		local starConditionTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2215"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    starConditionTitleLabel:setColor(ccc3(0x36, 0xff, 0x00))
	    starConditionTitleLabel:setPosition(ccp( 110, 30))
	    starConditionTitleLabel:setAnchorPoint(ccp(0, 0.5))
	    bgSprite:addChild(starConditionTitleLabel)
	    -- 条件字符串
	    local starConditionLabel = CCRenderLabel:create(CopyUtil.getStarCondition(hardLevel, strongholdInfo), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    starConditionLabel:setColor(ccc3(0xff, 0xff, 0xff))
	     --兼容东南亚英文版
		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	    	starConditionLabel:setPosition(ccp( 350, 30))
	    else
	    	starConditionLabel:setPosition(ccp( 200, 30))
	    end
	    starConditionLabel:setAnchorPoint(ccp(0, 0.5))
	    bgSprite:addChild(starConditionLabel)

	    if(distance <= 0)then

	    	if( DataCache.getSweepCoolTime() and (DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset()) > 0 )then

	    		local fight10Btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(125, 83),"",ccc3(0xfe, 0xdb, 0x1c),29,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				fight10Btn:setAnchorPoint(ccp(0.5, 0.5))
				fight10Btn:setPosition(ccp(350, 85))
				fight10Btn:registerScriptTapHandler(FortInfoLayer.resetSweepCdAction)
				fightMenuBar:addChild(fight10Btn, 1, 20000+hardLevel)

	    	elseif(tonumber(defeat_num)>0)then
	    		-- 战10按钮
				--兼容东南亚英文版
	    		local fight10Btn
	    		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	    			fight10Btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(125, 83),GetLocalizeStringBy("key_1787") .. defeat_num .. GetLocalizeStringBy("key_3010"),ccc3(0xfe, 0xdb, 0x1c),19,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	    		else
					fight10Btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(125, 83),GetLocalizeStringBy("key_1787") .. defeat_num .. GetLocalizeStringBy("key_3010"),ccc3(0xfe, 0xdb, 0x1c),29,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				end
				fight10Btn:setAnchorPoint(ccp(0.5, 0.5))
				fight10Btn:setPosition(ccp(350, 85))
				fight10Btn:registerScriptTapHandler(FortInfoLayer.fight10Action)
				fightMenuBar:addChild(fight10Btn, 1, 20000+hardLevel)
	    	end

			-- 星星
	    	starSprite = CCSprite:create("images/hero/star.png")
	    end
	end

	-- 星星
	starSprite:setAnchorPoint(ccp(0.5, 0.5))
	starSprite:setPosition(ccp(60, 55))
	bgSprite:addChild(starSprite)

	--  银币
	local silverLabel = CCRenderLabel:create(silverNum, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    silverLabel:setColor(textColor)
    silverLabel:setPosition(ccp( 180, 110))
    bgSprite:addChild(silverLabel)

    --  将魂
	local soulLabel = CCRenderLabel:create(soulNum, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    soulLabel:setColor(textColor)
    soulLabel:setPosition(ccp( 180, 75))
    bgSprite:addChild(soulLabel)

    -- 经验
    -- local expLabel = CCRenderLabel:create(expNum*UserModel.getHeroLevel(), g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- expLabel:setColor(textColor)
    -- expLabel:setPosition(ccp( 180, 44))
    -- bgSprite:addChild(expLabel)

	return bgSprite
end
