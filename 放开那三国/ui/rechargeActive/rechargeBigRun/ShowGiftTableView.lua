-- Filename：	ShowGiftTableView.lua
-- Author：		Zhang Zihang
-- Date：		2014-7-11
-- Purpose：		充值大放送今日奖励tableView

module("ShowGiftTableView", package.seeall)

require "script/ui/item/ItemUtil"

local _todayData = nil		--今日的奖励信息

--[[
	@des 	:创建奖励预览tableView
	@param 	:
	@return :创建好的tableView
--]]
function createShowGiftTableView()
	--得到所有奖励的数据
	--数据里Key值如下
	-- type：物品类型
	-- num：数量
	-- tid：物品id
	-- name:物品名称
	_todayData = RechargeBigRunData.getDataByDay(RechargeBigRunData.getToday())

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(470, 120)
		elseif fn == "cellAtIndex" then
			--创建每一行，因为策划要求所以每一行四个图标
			--以下是策划qq记录
			-- 王晨  11:31:17
			--     这个还是上下滑动比较好   子航尽力哇
			-- 王晨  11:32:15
			--     我相信你哈 子航
			a2 = createShowGiftCell(a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = math.ceil(#_todayData/4)
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(475, 125))
	
end

--[[
	@des 	:创建Cell
	@param 	:tableView的a1值
	@return :tableViewCell
--]]
function createShowGiftCell(index)
	local prizeViewCell = CCTableViewCell:create()
	--位置的比例table
	local posArrX = {0.14,0.38,0.62,0.86}
	for i = 1,4 do
		if(_todayData[index*4 + i] ~= nil)then
			local itemSprite = ItemUtil.createGoodsIcon(_todayData[index*4 + i],nil,nil,nil,nil,true)
			itemSprite:setAnchorPoint(ccp(0.5,1))
			itemSprite:setPosition(ccp(470*posArrX[i],115))
			prizeViewCell:addChild(itemSprite)
		end
	end

	return prizeViewCell
end
