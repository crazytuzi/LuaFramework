-- Filename：	ShowAwardWayCell.lua
-- Author：		Cheng Liang
-- Date：		2014-4-9
-- Purpose：		显示该物品的获得途径的Cell

module("ShowAwardWayCell", package.seeall)


--[[
	@desc	副本Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createCopyCell(cellValues)
	print_t(cellValues)
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

    -- 据点名称
    local s_name_color = ccc3(0xff,0xf6,0x00)
    if(cellValues.isGray and cellValues.isGray == true)then
    	s_name_color = ccc3(155,155,155)
	end
    local strongholdNameLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1845") .. cellValues.targetStronghold.name, g_sFontPangWa, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    strongholdNameLabel:setColor(s_name_color)
    strongholdNameLabel:setAnchorPoint(ccp(0,0.5))
    strongholdNameLabel:setPosition(ccp(cellFrame:getContentSize().width*0.05, cellFrame:getContentSize().height*0.45))
    cellFrame:addChild(strongholdNameLabel)
    

    if(cellValues.isGray and cellValues.isGray == true)then
    	--开启条件
	    local preConditionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1423") .. CopyUtil.getOpenNCopyCondition(cellValues), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        preConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
        preConditionLabel:setPosition(ccp(cellFrame:getContentSize().width*0.9-preConditionLabel:getContentSize().width, cellFrame:getContentSize().height*0.85))
        cellFrame:addChild(preConditionLabel)
    else
    	-- 点击前往
    	local passedSprite = CCSprite:create("images/copy/forward.png")
	    passedSprite:setAnchorPoint(ccp(0, 0.5))
	    passedSprite:setPosition(ccp(cellFrame:getContentSize().width*0.7, cellFrame:getContentSize().height*0.3))
	    cellFrame:addChild(passedSprite,2,2)
    end


	return tCell
end
