
-- Filename：	GuildBuildingItem.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		军团建筑的按钮

module("GuildBuildingItem", package.seeall)

Tag_Hall 		= 2001 -- 军团大厅
Tag_Guanyu 		= 2002 -- 关公殿
Tag_Shop 		= 2003 -- 军团商城
Tag_LiangCang 	= 2004 -- 军团粮仓
Tag_Book 		= 2005 -- 军团书院
Tag_Military	= 2006 -- 军机大厅
Tag_Science		= 2007 -- 科技大厅

-- 点击区域
local touchSizeDict = {}
touchSizeDict[Tag_Hall]  		= CCSizeMake(235, 280)
touchSizeDict[Tag_Guanyu]  		= CCSizeMake(150, 180)
touchSizeDict[Tag_Shop]  		= CCSizeMake(150, 180)
touchSizeDict[Tag_LiangCang]  	= CCSizeMake(120, 98)
touchSizeDict[Tag_Book]  		= CCSizeMake(150, 180)
touchSizeDict[Tag_Military]  	= CCSizeMake(150, 180)
touchSizeDict[Tag_Science]  	= CCSizeMake(150, 190)

-- 建筑物
local buildingPngArr = {}
buildingPngArr[Tag_Hall] 		= {png_n="images/guild/building/building_1_n.png", png_h="images/guild/building/building_1_h.png"}
buildingPngArr[Tag_Guanyu] 		= {png_n="images/guild/building/building_2_n.png", png_h="images/guild/building/building_2_h.png"}
buildingPngArr[Tag_Shop] 		= {png_n="images/guild/building/building_3_n.png", png_h="images/guild/building/building_3_h.png"}
buildingPngArr[Tag_LiangCang] 	= {png_n= "images/guild/building/building_6_g.png", png_h= "images/guild/building/building_6_g.png"}
buildingPngArr[Tag_Book] 		= {png_n="images/guild/building/building_5_n.png", png_h="images/guild/building/building_5_h.png"}
buildingPngArr[Tag_Military] 	= {png_n="images/guild/building/building_4_n.png", png_h="images/guild/building/building_4_h.png"}
buildingPngArr[Tag_Science] 	= {png_n="images/guild/building/building_7_n.png", png_h="images/guild/building/building_7_h.png"}

function createBuildingItemBy( b_type )

	-- 空白区域
	local item_sprite_n = CCSprite:create()
	item_sprite_n:setContentSize(touchSizeDict[b_type])
	local item_sprite_h = CCSprite:create()
	item_sprite_h:setContentSize(touchSizeDict[b_type])

	local b_itemBtn = CCMenuItemSprite:create(item_sprite_n, item_sprite_h)

	-- 建筑
	if( b_type == Tag_LiangCang)then
		-- 如果是粮仓 特殊处理
		require "script/ui/guild/GuildDataCache"
		local isOpen = GuildDataCache.getBarnIsOpen()
		if(isOpen)then
			buildingPngArr[b_type].png_n = "images/guild/building/building_6_n.png"
			buildingPngArr[b_type].png_h = "images/guild/building/building_6_h.png"
		else
			buildingPngArr[b_type].png_n = "images/guild/building/building_6_g.png"
			buildingPngArr[b_type].png_h = "images/guild/building/building_6_g.png"
		end
	end
	local b_building_sprite_n = CCSprite:create(buildingPngArr[b_type].png_n)
	b_building_sprite_n:setAnchorPoint(ccp(0.5, 0.5))
	b_building_sprite_n:setPosition(ccp(item_sprite_n:getContentSize().width*0.5, item_sprite_n:getContentSize().height*0.5))
	item_sprite_n:addChild(b_building_sprite_n)

	local b_building_sprite_h = CCSprite:create(buildingPngArr[b_type].png_h)
	b_building_sprite_h:setAnchorPoint(ccp(0.5, 0.5))
	b_building_sprite_h:setPosition(ccp(item_sprite_h:getContentSize().width*0.5, item_sprite_h:getContentSize().height*0.5))
	item_sprite_h:addChild(b_building_sprite_h)


	return b_itemBtn

end




