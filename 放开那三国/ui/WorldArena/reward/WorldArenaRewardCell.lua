-- FileName: WorldArenaRewardCell.lua 
-- Author: licong 
-- Date: 15/7/4 
-- Purpose: 巅峰对决奖励预览


module("WorldArenaRewardCell", package.seeall)

--[[
	@des 	: 创建tableview cell
	@param 	: 
	@return : 
--]]
function createCell( p_data, p_touchPriority, p_zOrder)

	local tCell = CCTableViewCell:create()

	local rect = CCRectMake(0,0,116,124)
	local insert = CCRectMake(52,44,6,4)
	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png",rect,insert)
	cellBg:setContentSize(CCSizeMake(565,210))
	tCell:addChild(cellBg)

	-- 描述文字
	local  descBg= CCSprite:create("images/sign/sign_bottom.png")
	descBg:setPosition(ccp(3,cellBg:getContentSize().height*0.72))
	cellBg:addChild(descBg)

	local rankLabel = CCRenderLabel:create(p_data.rankDes or " " , g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
	rankLabel:setColor(ccc3(0xff,0xfb,0xd9))
	rankLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	descBg:addChild(rankLabel)

	--  显示物品的bg
	local rewardBg= CCScale9Sprite:create("images/reward/item_back.png")
	rewardBg:setContentSize(CCSizeMake(513,137))
	rewardBg:setPosition(ccp(cellBg:getContentSize().width/2 ,18))
	rewardBg:setAnchorPoint(ccp(0.5,0))
	cellBg:addChild(rewardBg)

	-- 创建goods列表
	require "script/ui/item/ItemUtil"
	local all_good = ItemUtil.getItemsDataByStr(nil,p_data.rewardTab)
	-- print("all_good++")
	-- print_t(all_good)
	local cellSize = CCSizeMake(126, 137)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = ItemUtil.createGoodListCell( all_good[a1+1], p_touchPriority+1, p_zOrder, p_touchPriority-20 )
			r = a2
		elseif fn == "numberOfCells" then
			r = #all_good
		else	
		end
		return r
	end)
	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(513, 137))
	goodTableView:setBounceable(true)
	goodTableView:setTouchEnabled(false)
	if( table.count(all_good) > 4) then
		goodTableView:setTouchEnabled(true)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(10, 2))
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	rewardBg:addChild(goodTableView)
	goodTableView:setTouchPriority(p_touchPriority)

	return tCell
end