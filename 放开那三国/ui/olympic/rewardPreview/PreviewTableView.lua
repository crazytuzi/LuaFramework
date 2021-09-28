-- Filename: PreviewTableView.lua
-- Author: Zhang Zihang
-- Date: 2014-07-15
-- Purpose: 擂台争霸奖励tableView

module("PreviewTableView", package.seeall)

require "db/DB_Challenge_reward"
require "script/ui/item/ItemUtil"

--[[
	@des 	:创建tableView
	@param 	:
	@return :创建好的tableView
--]]
function createTableView()
	--表里的奖励数量，有多少显示多少
	--不能在 fn == "numberOfCells" 中使用table.count，所以单提出来
	local cellNum = table.count(DB_Challenge_reward.Challenge_reward)
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(575, 220)
		elseif fn == "cellAtIndex" then
			--用a1+1做下标创建cell
			a2 = createPreviewCell(cellNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = cellNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(575, 675))
end

--[[
	@des 	:创建奖励预览cell
	@param 	:奖励的位置，从1开始（即a1+1的值）
	@return :创建好的cell
--]]
function createPreviewCell(p_pos)
	local tCell = CCTableViewCell:create()

	--背景
	local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBgSprite:setContentSize(CCSizeMake(555,200))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(10,10))
	tCell:addChild(cellBgSprite)

	--标题背景
	local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
	titleBgSprite:setAnchorPoint(ccp(0,1))
	titleBgSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
	cellBgSprite:addChild(titleBgSprite)

	--标题名称
	local titleLabel = CCRenderLabel:create(tostring(DB_Challenge_reward.getDataById(p_pos).tips),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2))
	titleBgSprite:addChild(titleLabel)

	--二级白色背景
	local whiteBgSprite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
	whiteBgSprite:setContentSize(CCSizeMake(520,130))
	whiteBgSprite:setAnchorPoint(ccp(0.5,0))
	whiteBgSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,15))
	cellBgSprite:addChild(whiteBgSprite)

	--tableView嵌套tableView
	--策划要求，不得已而为之
	--内存就这么被消耗了
	-- 高甜  10:42:29
	-- 		额- -
	-- 高甜  10:42:48
	-- 		我们这边尽量控制物品在4个以内吧。。
	-- 高甜  10:42:56
	-- 		但 不保证4个内
	-- 高甜  10:43:04
	-- 		所以 还是要做滑动=0=
	-- 高甜  10:43:09
	-- 		类似奖励中心
	local innerTableView = createInnerTableView(p_pos)
	innerTableView:setAnchorPoint(ccp(0,0))
	innerTableView:setPosition(ccp(0,0))
	require "script/ui/olympic/rewardPreview/OlympicRewardLayer"
	innerTableView:setTouchPriority(OlympicRewardLayer.getTouchPriority() - 1)
	innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
	innerTableView:reloadData()
	whiteBgSprite:addChild(innerTableView)

	return tCell
end

--[[
	@des 	:创建内部tableView
	@param 	:奖励条目
	@return :创建好的tableView
--]]
function createInnerTableView(p_innerPos)
	--本来应该放在数据层，可是就一句话，所以就放在这里了
	local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Challenge_reward.getDataById(p_innerPos).reward)

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(130,130)
		elseif fn == "cellAtIndex" then
			a2 = createItemCell(dataAfterDeal[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #dataAfterDeal
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(520,130))
end

--[[
	@des 	:创建内部cell
	@param 	:当前的奖励信息
	@return :创建好的cell
--]]
function createItemCell(p_dataInfo)
	local prizeViewCell = CCTableViewCell:create()
	local itemSprite = ItemUtil.createGoodsIcon(p_dataInfo)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(ccp(65,75))
	prizeViewCell:addChild(itemSprite)

	return prizeViewCell
end