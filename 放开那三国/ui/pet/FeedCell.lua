-- Filename：	PetData.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的食物的Cell


module("FeedCell", package.seeall)

require "script/ui/item/ItemSprite"


--  
function createCell(cellvalues)
	local tCell =  CCTableViewCell:create()

	local iconBg = ItemSprite.getItemSpriteByItemId( tonumber(cellvalues.item_template_id) )
	iconBg:setAnchorPoint(ccp(0, 0))
	iconBg:setPosition(ccp(5, 26))
	tCell:addChild(iconBg,1,1)

	-- 物品的数量
	local numberLabel =CCRenderLabel:create( cellvalues.item_num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke) 
	numberLabel:setColor(ccc3(0x00,0xff,0x18))
	numberLabel:setAnchorPoint(ccp(0,0))
	local width = iconBg:getContentSize().width - numberLabel:getContentSize().width- 6
	numberLabel:setPosition(ccp(width , 6))
	iconBg:addChild(numberLabel)

	-- 经验
	local experiencelLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_1907"), g_sFontName, 18)
	experiencelLabel:setColor(ccc3(0xff, 0xff, 0xff))
	-- 经验的数值
	require "db/DB_Item_feed"
	local experience_data = DB_Item_feed.getDataById(tonumber(cellvalues.item_template_id))
	local experienceNumLabel = LuaCCLabel.createShadowLabel( "+" .. experience_data.add_exp , g_sFontName, 18)
	experienceNumLabel:setColor(ccc3(0x00, 0xeb, 0x21))

	local expNode = BaseUI.createHorizontalNode({experiencelLabel, experienceNumLabel})
    expNode:setPosition(iconBg:getContentSize().width/2,-4)
    expNode:setAnchorPoint(ccp(0.5,1))
    iconBg:addChild(expNode)
	-- 竖线
	local lineSprite = CCSprite:create("images/common/line02.png")
	lineSprite:setAnchorPoint(ccp(0.5,-1))
	lineSprite:setPosition(ccp( iconBg:getContentSize().width/2, -35))
	-- lineSprite:setScaleY(1.5)
	iconBg:addChild(lineSprite)



	return tCell
end
