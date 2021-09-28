-- Filename: WishRewardPreviewTableView.lua
-- Author:   zhangdaofeng
-- Date:     2015-01-24
-- Purpose:  个人跨服赛膜拜奖励预览TableView

module("WishRewardPreviewTableView", package.seeall)

require "script/ui/item/ItemUtil"

local kCellBgImage      = "images/reward/cell_back.png"
local kCellTitleBgImage = "images/sign/sign_bottom.png"
local kWhiteBgImage     = "images/recycle/reward/rewardbg.png"

local _cellSize = CCSizeMake(575, 210)  -- TableView的Cell大小

--[[
	@des    : 创建TableView
	@param  : width,  TableView宽度
			  height, TableView高度
	@return : TableView
--]]
function createTableView(width, height) 
	local rewardDataTable = getWishRewardData()
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(_cellSize.width, _cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = createTableViewCell(rewardDataTable[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r =  #rewardDataTable
		else
			print("other function")
		end
		return r
	end)

	return LuaTableView:createWithHandler(handler, CCSizeMake(width, height))
end

--[[
	@des    : 创建TableView的Cell
	@param  : p_cellValuesTable, 从表中得到的Cell值, 是一个table, keys={"id", "des", "reward"}
	@return : CCTableViewCell
--]]
function createTableViewCell(p_cellValuesTable) 
	local tCell = CCTableViewCell:create()

	-- Cell背景
	local cellBgSprite = CCScale9Sprite:create(kCellBgImage)
	cellBgSprite:setContentSize(CCSizeMake(555, 200))
	cellBgSprite:setAnchorPoint(ccp(0.5, 1))
	cellBgSprite:setPosition(ccp(_cellSize.width/2, _cellSize.height-10))
	tCell:addChild(cellBgSprite)

	-- 标题背景
	local titleBgSprite = CCSprite:create(kCellTitleBgImage)
	titleBgSprite:setAnchorPoint(ccp(0, 1))
	titleBgSprite:setPosition(ccp(0, cellBgSprite:getContentSize().height))
	cellBgSprite:addChild(titleBgSprite)

	-- 标题文字
	local titleTextLabel = CCRenderLabel:create(p_cellValuesTable.des, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
	titleTextLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00))
	titleTextLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleTextLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2, titleBgSprite:getContentSize().height/2+2))
	titleBgSprite:addChild(titleTextLabel)

	-- 奖励区域的白色背景
	local whiteBgSprite = CCScale9Sprite:create(kWhiteBgImage)
	whiteBgSprite:setContentSize(CCSizeMake(520,130))
	whiteBgSprite:setAnchorPoint(ccp(0.5,0))
	whiteBgSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,15))
	cellBgSprite:addChild(whiteBgSprite)

	-- 显示奖励条目的内层TableView，可以水平滚动
	local itemsData = getItemsDataByString(p_cellValuesTable.reward)
	local innerTableView = createInnerTableView(itemsData)
	innerTableView:setAnchorPoint(ccp(0, 0))
	innerTableView:setPosition(ccp(0, 0))
	require "script/ui/guildWar/reward/GuildWarWorshipRewardDialog"
	innerTableView:setTouchPriority(GuildWarWorshipRewardDialog.getTouchPriority()-2)
	innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
	innerTableView:reloadData()
	whiteBgSprite:addChild(innerTableView)
	
	return tCell
end


--[[
	@des    : 创建内层TableView
	@param  : p_itemsData, 物品奖励数据table
	@return : 内层TableView
--]]
function createInnerTableView(p_itemsData) 
	local handler = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(130, 130)
		elseif fn == "cellAtIndex" then
			a2 = createInnerTableViewCell(p_itemsData[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #p_itemsData
		else
			print("other function")
		end
		return r
	end)

	return LuaTableView:createWithHandler(handler, CCSizeMake(520,130))
end

--[[
	@des    : 创建内层TableViewCell
	@param  : p_itemData, 一个物品奖励数据
	@return : 内层TableViewCell
--]]
function createInnerTableViewCell(p_itemData) 
	local tCell = CCTableViewCell:create()
	require "script/ui/guildWar/reward/GuildWarWorshipRewardDialog"
	local itemSprite = ItemUtil.createGoodsIcon(p_itemData, 
												GuildWarWorshipRewardDialog.getTouchPriority()-1, 
												GuildWarWorshipRewardDialog.getZOrder()+1)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(ccp(65,75))
	tCell:addChild(itemSprite)

	return tCell
end


--[[
	@des    : 通过奖励字符串获取奖励物品
	@param  : p_rewardString, 物品奖励字符串
	@return : 奖励物品
--]]
function getItemsDataByString(p_rewardString) 
	require "script/ui/item/ItemUtil"
	return ItemUtil.getItemsDataByStr(p_rewardString)
end

--[[
	@des    : 读表, 获取膜拜奖励数据
	@param  : 
	@return : 膜拜奖励数据, 是一个table, 形式为{
												{20001, "文君酒", "12|0|100,7|60017|1", },
												{20002, "杜康酒", "7|30701|2,12|0|200,7|60017|2", },
												{20003, "清圣浊贤", "7|30701|5,12|0|300,7|60017|5", },
											}
--]]
function getWishRewardData() 
	require "script/model/utils/ActivityConfig"
	require "db/DB_Kuafu_legionchallengereward"
	local rewardIdTable = string.split(ActivityConfig.ConfigCache.guildwar.data[1].wishReward, ",")

	local function sortById(rewardIdStr1, rewardIdStr2)
        return tonumber(rewardIdStr1) < tonumber(rewardIdStr2)
    end
    table.sort(rewardIdTable, sortById)

	local rewardData = {}
	for i,v in ipairs(rewardIdTable) do
		rewardData[#rewardData+1] = DB_Kuafu_legionchallengereward.getDataById(v)
	end

	return rewardData
end




