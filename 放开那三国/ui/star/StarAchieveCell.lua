
-- Filename：	StarAchieveCell.lua
-- Author：		Cheng Liang
-- Date：		2013-11-27
-- Purpose：		名将成就cell

module("StarAchieveCell", package.seeall)

-- 
function createCell(achieveData, totalLv)

	local tCell = CCTableViewCell:create()
	local isGray = true
	if( totalLv >= tonumber(achieveData.completeArray) )then
		isGray = false
	end

	local bgName 	 = nil
	local titleColor = nil
	local textColor  = nil
	local attrColor  = nil
	local numColor   = nil
	local starName 	= nil

	if(isGray)then
		bgName 		= "images/star/star_achieve_graybg.png"
		titleColor 	= ccc3(0xca, 0xca, 0xca)
		textColor  	= ccc3(0x2a, 0x1d, 0x18)
		attrColor  	= ccc3(0x2a, 0x1d, 0x18)
		numColor   	= ccc3(0xca, 0xca, 0xca)
		starName 	= "images/star/intimate/heart_gray_s.png"
	else
		bgName 	 	= "images/star/star_achieve_bg.png"
		titleColor 	= ccc3(0x00, 0xe4, 0xff)
		textColor  	= ccc3(0x78, 0x25, 0x00)
		attrColor  	= ccc3(0x14, 0x61, 0x02)
		numColor   	= ccc3(0xff, 0xff, 0x60)
		starName   	= "images/star/intimate/heart_s.png"

	end

	local cellBg = CCSprite:create(bgName)
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)

	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = StarUtil.getStarAchieveIconSprite(achieveData, isGray)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(cellBgSize.width*0.15, cellBgSize.height*0.5))
	cellBg:addChild(iconSprite)

	-- title
	local starNumTitleLabel = CCRenderLabel:create(achieveData.name, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	starNumTitleLabel:setColor(titleColor)
    starNumTitleLabel:setAnchorPoint(ccp(0, 0.5))
    starNumTitleLabel:setPosition(ccp(cellBgSize.width*0.25, cellBgSize.height*0.75))
    cellBg:addChild(starNumTitleLabel)

    local height_scale_1 = 0.5
    local height_scale_2 = 0.3
    if(isGray)then
    	height_scale_1 = 0.4
   		height_scale_2 = 0.2
    end

    -- 条件显示
    local conditionTextLabel = CCLabelTTF:create(achieveData.des, g_sFontName, 25)
	conditionTextLabel:setColor(textColor)
	conditionTextLabel:setAnchorPoint(ccp(0, 0.5))
	conditionTextLabel:setPosition(ccp(cellBgSize.width*0.25, cellBgSize.height*height_scale_1))
	cellBg:addChild(conditionTextLabel)

	-- 条件数字
	local coditionNumTitleLabel = nil
	if(tonumber(achieveData.completeArray) == 1)then
		coditionNumTitleLabel = CCLabelTTF:create(achieveData.completeArray, g_sFontName, 25)
	else
		coditionNumTitleLabel = CCRenderLabel:create(achieveData.completeArray, g_sFontName, 25, 1, ccc3(0, 0, 0), type_stroke)
	end
	coditionNumTitleLabel:setColor(numColor)
    coditionNumTitleLabel:setAnchorPoint(ccp(0, 0.5))
    coditionNumTitleLabel:setPosition(ccp(cellBgSize.width*0.25 +conditionTextLabel:getContentSize().width + 5 , cellBgSize.height*height_scale_1))
    cellBg:addChild(coditionNumTitleLabel)

    -- 心
    local starSprite = CCSprite:create(starName)
    starSprite:setAnchorPoint(ccp(0, 0.5))
    starSprite:setPosition(ccp(cellBgSize.width*0.25 +conditionTextLabel:getContentSize().width + coditionNumTitleLabel:getContentSize().width + 10 , cellBgSize.height*height_scale_1))
    cellBg:addChild(starSprite)

    -- 属性加成
    local textStr = StarUtil.getStringAchieveAttrBy(achieveData)
    local attrTextLabel = CCLabelTTF:create( GetLocalizeStringBy("key_1944") .. textStr, g_sFontName, 25)
	attrTextLabel:setColor(attrColor)
	attrTextLabel:setAnchorPoint(ccp(0, 0.5))
	attrTextLabel:setPosition(ccp(cellBgSize.width*0.25, cellBgSize.height*height_scale_2))
	cellBg:addChild(attrTextLabel)

    if(isGray)then
    	-- 进度
		local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
		bgProress:setContentSize(CCSizeMake(420, 23))
		bgProress:setAnchorPoint(ccp(0, 0.5))
		bgProress:setPosition(ccp(cellBgSize.width*0.25, cellBgSize.height*0.58))
		cellBg:addChild(bgProress)
		
		local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
		progressSp:setContentSize(CCSizeMake(420 * totalLv/tonumber(achieveData.completeArray), 23))
		progressSp:setAnchorPoint(ccp(0, 0.5))
		progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
		bgProress:addChild(progressSp)

		local pTextLabel = CCRenderLabel:create( totalLv .. "/" .. achieveData.completeArray, g_sFontName, 18, 1, ccc3(0, 0, 0), type_stroke)
		pTextLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    pTextLabel:setAnchorPoint(ccp(0.5, 0.5))
	    pTextLabel:setPosition(ccp(bgProress:getContentSize().width*0.5 , bgProress:getContentSize().height*0.5))
	    bgProress:addChild(pTextLabel)

	else
		local passedSprite = CCSprite:create("images/star/dacheng.png")
		passedSprite:setAnchorPoint(ccp(1,1))
		passedSprite:setPosition(ccp(cellBgSize.width, cellBgSize.height))
		cellBg:addChild(passedSprite)
	end

	return tCell
end
