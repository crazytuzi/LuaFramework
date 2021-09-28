-- Filename：	CopyCell.lua
-- Author：		Cheng Liang
-- Date：		2013-5-23
-- Purpose：		副本Cell

module("CopyCell", package.seeall)



--[[
	@desc	副本Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createCopyCell(cellValues, animatedIndex, isAnimate)

	local tCell = CCTableViewCell:create()
	
	-- 外框
    local cellFrame = nil
    -- 背景
	local cellBg = nil
    if(cellValues.isGray and cellValues.isGray == true)then
    	cellFrame = BTGraySprite:create("images/copy/copyframe.png")
    	cellBg = BTGraySprite:create("images/copy/ncopy/thumbnail/" .. cellValues.copyInfo.thumbnail)
    else
    	cellFrame = CCSprite:create("images/copy/copyframe.png")
    	cellBg = CCSprite:create("images/copy/ncopy/thumbnail/" .. cellValues.copyInfo.thumbnail)
    end
    cellFrame:setAnchorPoint(ccp(0,0))
    tCell:setContentSize(cellFrame:getContentSize())
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	tCell:addChild(cellFrame,1,1)

	-- 名称背景
	local nameBgSp = nil
	if(cellValues.isGray and cellValues.isGray == true)then
		nameBgSp = BTGraySprite:create("images/copy/ncopy/namebg.png")
	else
		nameBgSp = CCSprite:create("images/copy/ncopy/namebg.png")
	end
	nameBgSp:setAnchorPoint(ccp(0.5, 0.5))
	nameBgSp:setPosition(ccp(cellFrame:getContentSize().width* 115.0/640, cellFrame:getContentSize().height*0.7))
    cellFrame:addChild(nameBgSp)
    --副本名称
    local nameSprite = nil
    if(cellValues.isGray and cellValues.isGray == true)then
		nameSprite = BTGraySprite:create("images/copy/ncopy/nameimage/" .. cellValues.copyInfo.image)
	else
		nameSprite = CCSprite:create("images/copy/ncopy/nameimage/" .. cellValues.copyInfo.image)
	end
    nameSprite:setAnchorPoint(ccp(0.5, 0.5))
    nameSprite:setPosition(nameBgSp:getContentSize().width*0.5, nameBgSp:getContentSize().height*0.5);
    nameBgSp:addChild(nameSprite,1,1)

    if(cellValues.isGray and cellValues.isGray == true)then
    	--开启条件
	    local preConditionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1423") .. CopyUtil.getOpenNCopyCondition(cellValues), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        preConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
        preConditionLabel:setPosition(ccp(cellFrame:getContentSize().width*0.9-preConditionLabel:getContentSize().width, cellFrame:getContentSize().height*0.85))
        cellFrame:addChild(preConditionLabel)
    else
		--是否通关
	    if (CopyUtil.isCopyHadPassed(cellValues)) then
		    local passedSprite = CCSprite:create("images/copy/passed.png")
		    passedSprite:setAnchorPoint(ccp(0, 0.5))
		    passedSprite:setPosition(ccp(cellFrame:getContentSize().width*0.75, cellFrame:getContentSize().height*0.7))
		    cellFrame:addChild(passedSprite,2,2)
		end
	    
	--星级
	    local starBgSp = CCSprite:create("images/copy/starbg.png")
	    starBgSp:setPosition(ccp(cellFrame:getContentSize().width*0.649, cellFrame:getContentSize().height*0.12))
	    cellFrame:addChild(starBgSp,3,3);
	    local curStarLabel = CCRenderLabel:create(cellValues.score, g_sFontName,24, 3, ccc3(0x00, 0x00, 0x00), type_stroke)
	   	curStarLabel:setColor(ccc3(0xff, 0xd7, 0x4e))
	    starBgSp:addChild(curStarLabel,1,1)
	    curStarLabel:setPosition(ccp(starBgSp:getContentSize().width*0.32 - curStarLabel:getContentSize().width,starBgSp:getContentSize().height*0.7))
	    local size = curStarLabel:getContentSize()


	    local starSprite1 = CCSprite:create("images/copy/star.png")
	    starSprite1:setPosition(ccp(starBgSp:getContentSize().width*0.35,starBgSp:getContentSize().height*0.08))
	    starBgSp:addChild(starSprite1)
	    local starSprite2 = CCSprite:create("images/copy/star.png")
	    starSprite2:setPosition(ccp(starBgSp:getContentSize().width*0.75,starBgSp:getContentSize().height*0.08))
	    starBgSp:addChild(starSprite2)
	    
	    
	    local totalStarLabel = CCRenderLabel:create("/".. cellValues.copyInfo.all_stars, g_sFontName,24, 3, ccc3(0x00, 0x00, 0x00), type_stroke)
	    -- totalStarLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
	    totalStarLabel:setColor(ccc3( 0xff, 0xd7, 0x4e))
	    starBgSp:addChild(totalStarLabel,3,3)
	    totalStarLabel:setPosition(ccp(starBgSp:getContentSize().width*0.52,starBgSp:getContentSize().height*0.7))
    end

	if(isAnimate == true) then
		print("createCopyCell......" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(0.05 * (animatedIndex ),ccp(0,0)))
	end
	-- 准备相应的数据
	local stars_t, copper_t, silver_t, gold_t = CopyUtil.handleCopyRewardData( cellValues.copyInfo )

	local box_status_t = CopyUtil.handleBoxStatus(cellValues.prized_num, cellValues.score, stars_t)

	-- 是否有未领取的宝箱
	local boxName = nil
	if(box_status_t[3] and box_status_t[3]==2)then
		boxName = "gold"
	elseif(box_status_t[2] and box_status_t[2]==2)then
		boxName = "silver"
	elseif(box_status_t[1] and box_status_t[1]==2)then
		boxName = "copper"
	end
	if(boxName~=nil)then
		local effect = CopyRewardBtn.createEffect(boxName)
		effect:setPosition(ccp(100,40))
		cellBg:addChild(effect)
	end

	return tCell
end

function setCellValue( copyCell, cellValues, animatedIndex, isAnimate)
	local cellFrame = tolua.cast(copyCell:getChildByTag(1), "CCSprite")

	--修改副本名称
	local passedSprite = tolua.cast(cellFrame:getChildByTag(2), "CCSprite")
	if (passedSprite) then
		passedSprite:removeFromParentAndCleanup(true)
		passedSprite = nil
	end

	--修改副本获得的星级
	local starBgSp = tolua.cast(cellFrame:getChildByTag(3), "CCSprite")
	local starSprite1 = tolua.cast(starBgSp:getChildByTag(1), "CCRenderLabel")
	if(starSprite1) then
		starSprite1:removeFromParentAndCleanup(true)
	end
	local starSprite2 = tolua.cast(starBgSp:getChildByTag(3), "CCRenderLabel")
	if(starSprite2) then
		starSprite2:removeFromParentAndCleanup(true)
	end
	--当前星级
	local curStarLabel = CCRenderLabel:create(cellValues.score, g_sFontName,24, 3, ccc3(0x2b, 0x06, 0x00), type_stroke)
    curStarLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    
    starBgSp:addChild(curStarLabel,1,1)
    curStarLabel:setPosition(ccp(starBgSp:getContentSize().width*0.28 - curStarLabel:getContentSize().width,starBgSp:getContentSize().height*0.4))
    --总共
    local totalStarLabel = CCRenderLabel:create("/" .. cellValues.copyInfo.all_stars, g_sFontName,24, 3, ccc3(0x2b, 0x06, 0x00), type_stroke)
    totalStarLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    starBgSp:addChild(totalStarLabel,3,3)
    totalStarLabel:setPosition(ccp(starBgSp:getContentSize().width*0.48,starBgSp:getContentSize().height*0.8))

	if (CopyUtil.isCopyHadPassed(cellValues)) then
	    local passedSprite = CCSprite:create("images/copy/passed.png")
	    passedSprite:setPosition(ccp(cellFrame:getContentSize().width*0.75, cellFrame:getContentSize().height*0.7))
	    cellFrame:addChild(passedSprite,2,2)
	end

	if(isAnimate == true) then
		print("setCellValue-------" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ),ccp(0,0)))
	end
end



