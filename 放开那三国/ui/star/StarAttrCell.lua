-- Filename：	StarAttrCell.lua
-- Author：		Cheng Liang
-- Date：		2013-11-27
-- Purpose：		名将属性cell

module("StarAttrCell", package.seeall)

local Star_Img_Path = "images/star/intimate/"

function createCell(ability_info, index)

	index = tonumber(index)

	local tCell = CCTableViewCell:create()
	local bgSprite = nil
	if(math.mod(index, 2) == 1)then
		bgSprite = CCSprite:create()
	else
		bgSprite = CCScale9Sprite:create( "images/star/intimate/item9s.png" )
	end
	bgSprite:setContentSize(CCSizeMake(250, 46))
	tCell:addChild(bgSprite)

	local bgSpriteSize = bgSprite:getContentSize()

	local ccc_color = ccc3(0x00, 0x6d, 0x2f)
	local heart_name = Star_Img_Path .. "heart_s.png"
	local attr_nameColor = ccc3(0x78, 0x25, 0x00)

	if( not ability_info.is_highLight) then
		ccc_color = ccc3(0x3c, 0x3c, 0x3c)
		heart_name = Star_Img_Path .. "heart_gray_s.png"
		attr_nameColor = ccc3(0x3c, 0x3c, 0x3c)
	end

	-- 索引
	local indexLabel = CCLabelTTF:create(index, g_sFontName, 25)
	indexLabel:setColor(ccc_color)
	indexLabel:setAnchorPoint(ccp(0.5, 0.5))
	indexLabel:setPosition(ccp(bgSpriteSize.width*0.1, bgSpriteSize.height*0.5))
	bgSprite:addChild(indexLabel)

	-- 红心
	local heartSprite = CCSprite:create(heart_name)
	heartSprite:setAnchorPoint(ccp(0, 0.5))
	heartSprite:setPosition(ccp(bgSpriteSize.width*0.2, bgSpriteSize.height*0.5))
	bgSprite:addChild(heartSprite)

	-- 属性名称
	local attrNameLabel = CCLabelTTF:create(ability_info.name, g_sFontName, 21)
	attrNameLabel:setColor(attr_nameColor)
	attrNameLabel:setAnchorPoint(ccp(0, 0.5))
	attrNameLabel:setPosition(ccp(bgSpriteSize.width*0.33, bgSpriteSize.height*0.5))
	bgSprite:addChild(attrNameLabel)

	-- 属性值
	local attrNumLabel = CCLabelTTF:create("+" .. ability_info.num, g_sFontName, 21)
	attrNumLabel:setColor(ccc_color)
	attrNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	attrNumLabel:setPosition(ccp(bgSpriteSize.width*0.72, bgSpriteSize.height*0.5))
	bgSprite:addChild(attrNumLabel)

	return tCell
end
