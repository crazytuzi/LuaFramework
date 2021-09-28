-- Filename：	StepTableView.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-12
-- Purpose：		计步活动奖励预览TableView

module ("StepTableView", package.seeall)

require "script/ui/rechargeActive/stepCounterActive/StepCounterData"
require "script/ui/item/ItemUtil"

--[[
	@des 	:创建奖励预览tableView
	@param 	:
	@return :创建好的tableView
--]]
function createTableView()
	local giftData = StepCounterData.getCurDayGift()
	local giftNum = table.count(giftData)

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(121, 145)
		elseif fn == "cellAtIndex" then
			a2 = createCell(giftData[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = giftNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(605, 145))
end

--[[
	@des 	:创建单个物品的图标cell
	@param 	:物品信息
	@return :创建好的cell
--]]
function createCell(p_giftInfo)
	local prizeViewCell = CCTableViewCell:create()
	local itemSprite = ItemUtil.createGoodsIcon(p_giftInfo,nil,nil,nil,nil,true)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(ccp(121/2,145/2 + 10))
	prizeViewCell:addChild(itemSprite)

	return prizeViewCell
end