-- Filename：	MoonMultiplyFightResultCell.lua
-- Author：		bzx
-- Date：		2016-06-06
-- Purpose：		连战Cell

module("MoonMultiplyFightResultCell", package.seeall)


require "script/model/utils/HeroUtil"


local textArr = {GetLocalizeStringBy("lic_1249"), GetLocalizeStringBy("key_2665"), GetLocalizeStringBy("key_2579"), GetLocalizeStringBy("key_1504"), GetLocalizeStringBy("key_2645"),  GetLocalizeStringBy("lic_1250"), GetLocalizeStringBy("key_2588"),GetLocalizeStringBy("lic_1251"), GetLocalizeStringBy("key_2525"), GetLocalizeStringBy("key_2065")}

-- index start with 1
function createCell(rewardData, cellSize, index, touchPriority)
	touchPriority = touchPriority or -890
	rewardData = ItemUtil.getServiceReward(rewardData)

	local tCell = CCTableViewCell:create()

	-- 背景
	local bgSprite = CCSprite:create()
	bgSprite:setContentSize(cellSize)
	tCell:addChild(bgSprite)

	-- 头
	local topSprite = CCSprite:create("images/common/top.png") 
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(cellSize.width*0.5, cellSize.height-10))
	bgSprite:addChild(topSprite)

	-- 次数
	local countLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. textArr[index] .. GetLocalizeStringBy("key_3010"), g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    countLabel:setColor(ccc3(0x78, 0x25, 0x00))
    countLabel:setAnchorPoint(ccp(0.5, 0.5))
    countLabel:setPosition(ccp(topSprite:getContentSize().width*0.5, topSprite:getContentSize().height*0.5) )
    topSprite:addChild(countLabel)

	-- 获得战利品
	local t_sprite = CCSprite:create("images/common/line2.png")
	t_sprite:setAnchorPoint(ccp(0.5, 0.5))
	t_sprite:setPosition(ccp(cellSize.width*0.5, cellSize.height - 70))
	bgSprite:addChild(t_sprite)
	local rewardTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2882"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rewardTitleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    rewardTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
    rewardTitleLabel:setPosition(ccp( t_sprite:getContentSize().width*0.5, t_sprite:getContentSize().height*0.5) )
    t_sprite:addChild(rewardTitleLabel)

	for i = 1, #rewardData do
		local itemData = rewardData[i]
        local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemData, touchPriority - 1, 9999, touchPriority - 50, nil,nil,nil,false)
        tCell:addChild(icon)
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPosition(ccp(50 + (icon:getContentSize().width + 40)* math.floor((i - 1) % 3), cellSize.height - 150 - 125 * math.floor((i - 1) / 3)))

        local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
        itemNameLabel:setColor(itemColor)
        itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
        itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.15)
        icon:addChild(itemNameLabel)
	end
	return tCell
end
