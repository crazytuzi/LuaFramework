-- Filename：	StarGiftCell.lua
-- Author：		Cheng Liang
-- Date：		2013-8-8
-- Purpose：		名仕赠送礼物cell

module("StarGiftCell", package.seeall)


require "script/ui/item/ItemSprite"
require "script/utils/LuaUtil"
require "script/libs/LuaCC"
require "script/network/RequestCenter"
require "script/libs/LuaCCLabel"

local Star_Img_Path = "images/star/intimate/"

--[[
	@desc	
	@para 	
	@return 
--]]
function createCell(userData, hasLine)

	local tCell = CCTableViewCell:create()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(userData.item_template_id) )
	iconSprite:setAnchorPoint(ccp(0, 1))
	iconSprite:setPosition(ccp(0, 125))
	tCell:addChild(iconSprite)
	
	tCell:setContentSize( CCSizeMake(iconSprite:getContentSize().width, iconSprite:getContentSize().height + 35) )

	-- 数量
	local numLabel = CCRenderLabel:create("x" .. userData.item_num, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	numLabel:setColor(ccc3(0xff, 0xff, 0xff))
	numLabel:setAnchorPoint(ccp(1, 0))
	numLabel:setPosition(ccp(iconSprite:getContentSize().width*0.95, iconSprite:getContentSize().height*0.05))
	iconSprite:addChild(numLabel)

	-- 竖线
	local lineSprite = CCSprite:create(Star_Img_Path .. "line.png")
	lineSprite:setAnchorPoint(ccp(1,0))
	lineSprite:setPosition(ccp( 103, 0))
	lineSprite:setScaleY(1.5)
	tCell:addChild(lineSprite)

	-- 好感
	local feelLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_1462"), g_sFontName, 18)
	feelLabel:setColor(ccc3(0xff, 0xff, 0xff))
	feelLabel:setAnchorPoint(ccp(0, 0))
	feelLabel:setPosition(ccp(0, 0))
	tCell:addChild(feelLabel)

	require "db/DB_Item_star_gift"
	local gift_data = DB_Item_star_gift.getDataById(tonumber(userData.item_template_id))


	-- 好感数值
	local feelNumLabel = LuaCCLabel.createShadowLabel("+" .. gift_data.coins, g_sFontName, 18)
	feelNumLabel:setColor(ccc3(0x00, 0xeb, 0x21))
	feelNumLabel:setAnchorPoint(ccp(0, 0))
	feelNumLabel:setPosition(ccp(40, 0))
	tCell:addChild(feelNumLabel)

	return tCell
end























