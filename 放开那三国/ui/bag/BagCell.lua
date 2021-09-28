-- Filename：	BagCell.lua
-- Author：		Cheng Liang
-- Date：		2013-5-23
-- Purpose：		背包Cell

module("BagCell", package.seeall)

--[[
	@desc	副本Cell的创建
	@para 	table cellValues,
	@return CCTableViewCell
--]]
function createBagCell(cellValues)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/bagcellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)

	--Icon
	local iconSprite = CCSprite:create("images/bag/".. cellValues.icon)
	print(iconSprite)
	iconSprite:setAnchorPoint(ccp(0,0))
	iconSprite:setPosition(ccp(cellBg:getContentSize().height*0.1, cellBg:getContentSize().height*0.1))
	cellBg:addChild(iconSprite,2,2)

	--名称
	local nameLabel = CCLabelTTF:create(cellValues.name, g_sFontName, 40)
	nameLabel:setPosition(cellBg:getContentSize().width*0.4, cellBg:getContentSize().height*0.6)
	nameLabel:setAnchorPoint(ccp(0, 0))
	nameLabel:setColor(ccc3(255,200,150))
	cellBg:addChild(nameLabel,1,1)

	--描述
	local descLabel = CCLabelTTF:create(cellValues.desc, g_sFontName, 40)
	descLabel:setPosition(cellBg:getContentSize().width*0.3, cellBg:getContentSize().height*0.3)
	descLabel:setAnchorPoint(ccp(0, 0))
	descLabel:setColor(ccc3(255,100,150))
	cellBg:addChild(descLabel,3,3)

	--数量
	local numLabel = CCLabelTTF:create(cellValues.num, g_sFontName, 30)
	numLabel:setPosition(cellBg:getContentSize().width*0.1, 0)
	numLabel:setAnchorPoint(ccp(0, 0))
	numLabel:setColor(ccc3(0,0,0))
	cellBg:addChild(numLabel,4,4)

	--按钮
	require "script/ui/common/LuaMenuItem"
	local menuItem = LuaMenuItem.createItemImage( "images/copy/menu_normal.png", "images/copy/menu_highlighted.png", cellValues.menuName, 30 )
	menuItem:setAnchorPoint(ccp(0,0.5))
	menuItem:setPosition(ccp(cellBg:getContentSize().width*0.7, cellBg:getContentSize().height*0.5))
	cellBg:addChild(menuItem)
	return tCell
end

function setCellValue( bagCell, cellValues)
	local cellBg = tolua.cast(bagCell:getChildByTag(1), "CCSprite")
	--修改名称
	local nameLabel = tolua.cast(cellBg:getChildByTag(1), "CCLabelTTF")
	nameLabel:setString(cellValues.name)
	--修改头像
	local iconSprite = tolua.cast(cellBg:getChildByTag(2), "CCSprite")
	iconSprite:setTexture( CCTextureCache:sharedTextureCache():addImage("images/bag/".. cellValues.icon) )
	--修改描述
	local descLabel = tolua.cast(cellBg:getChildByTag(3), "CCLabelTTF")
	descLabel:setString(cellValues.desc)
	--修改数量
	local numLabel = tolua.cast(cellBg:getChildByTag(4), "CCLabelTTF")
	numLabel:setString(cellValues.num)
	
end

function startBagCellAnimate( bagCell, animatedIndex )
	print("animatedIndex= " .. animatedIndex)
	local cellBg = tolua.cast(bagCell:getChildByTag(1), "CCSprite")
	cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
	cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ), ccp(0,0)))
end


