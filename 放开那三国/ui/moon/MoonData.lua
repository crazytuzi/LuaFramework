-- Filename：	MoonData.lua
-- Author：		bzx
-- Date：		2015-04-27
-- Purpose：		水月之镜数据

module("MoonData", package.seeall)

require "db/DB_Treasure_copymap"
require "db/DB_Treasure_smallcopy"
require "db/DB_Stronghold"
require "db/DB_Treasure_copyitem"
require "db/DB_Treasure_copy"
require "db/DB_Treasure_copygift"
require "db/DB_Treasure_copymall"
require "db/DB_Vip"

GridStatus = {
	LOCKED = "1",
	OPENED = "2",
	PASSED = "3",
}

kNormal = 1  		-- 普通boss
kHigh = 2			-- 恶梦boss

local _moonInfo = {}
local _copyCount = nil
local _smallCopyCount = nil
local _attackMonsterInfo = {}
local _shopInfo = {}
local _openBoxInfo = {}
local _buyBoxInfo = {}
local _number = nil

function setMoonInfo( moonInfo )
	_moonInfo = moonInfo
	UserModel.setGodCardNum(moonInfo.tg_num)
end

function getMoonInfo( ... )
	return _moonInfo
end

function copyIsOpened( copyId )
	if copyId <= tonumber(_moonInfo.max_pass_copy) + 1 then
		return true
	end
	return false
end

function getCopyCount( ... )
	if not _copyCount then
		_copyCount = table.count(DB_Treasure_copymap.Treasure_copymap)
	end
	return _copyCount
end

function getSmallCopyCount( ... )
	if _smallCopyCount == nil then
		_smallCopyCount = table.count(DB_Treasure_smallcopy.Treasure_smallcopy)
	end
	return _smallCopyCount
end

function setAttackMonsterInfo( attackMonsterInfo, gridIndex )
	_attackMonsterInfo = attackMonsterInfo
	if not table.isEmpty(_attackMonsterInfo.open_grid) then
		setGridStatus(gridIndex, GridStatus.PASSED)
		for i = 1, #_attackMonsterInfo.open_grid do
			setGridStatus(_attackMonsterInfo.open_grid[i], GridStatus.OPENED)
		end
	elseif attackMonsterInfo.appraise ~= "E" and attackMonsterInfo.appraise ~= "F" then
		setGridStatus(gridIndex, GridStatus.PASSED)
	end
end

function getAttackMonsterInfo( ... )
	return _attackMonsterInfo
end

function setGridStatus(index, status)
	_moonInfo.grid[tostring(index)] = status
end

function getDropItems( smallCopyId, bossType )
	local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(smallCopyId)
	local externalItems = nil
	bossType = bossType or kNormal
	if bossType == kNormal then
		externalItems = parseField(treasureSmallcopyDb.reward_show, 2)
	else
		externalItems = parseField(treasureSmallcopyDb.reward_show2, 2)
	end
	return externalItems
end

function setShopInfo( shopInfo )
	_shopInfo = shopInfo
end

function getShopInfo( ... )
	print_t(_shopInfo)
	return _shopInfo
end
function getNumberRef( ... ) ---获取免费刷新次数
	print(tonumber(_shopInfo.free_refresh_num))
	return tonumber(_shopInfo.free_refresh_num)
end

function addNumberRef( p_num )
	_shopInfo.free_refresh_num = tonumber(_shopInfo.free_refresh_num) + p_num
end

function handleBuyGoods(p_goodsId)
	_shopInfo.goods_list[tostring(p_goodsId)] = tonumber(_shopInfo.goods_list[p_goodsId]) - 1
end

function setOpenBoxInfo( p_openBoxInfo, p_gridIndex )
	_openBoxInfo = p_openBoxInfo
	setGridStatus(p_gridIndex, GridStatus.PASSED)
	if not table.isEmpty(p_openBoxInfo.open_grid) then
		for i = 1, #p_openBoxInfo.open_grid do
			setGridStatus(p_openBoxInfo.open_grid[i], GridStatus.OPENED)
		end
	end
end

function getOpenBoxInfo( ... )
	return _openBoxInfo
end

function getMaxAttackBossCount( ... )
	local treasureCopy = DB_Treasure_copy.getDataById(1)
	return treasureCopy.num
end

function getAttackNum( )
	return tonumber(_moonInfo.atk_num)
end

function addAttackNum( addNum )
	_moonInfo.atk_num = tonumber(_moonInfo.atk_num) + addNum
end

function setAttackNum( num )
	_moonInfo.atk_num = num
end

function addBuyAttackNum( addNum )
	addAttackNum(addNum)
	_moonInfo.buy_num = tonumber(_moonInfo.buy_num) + addNum
end

function addBuyHighAttackNum( addNum )
	addHighAttackNum(addNum)
	_moonInfo.nightmare_buy_num = tonumber(_moonInfo.nightmare_buy_num) + addNum
end

function getMaxAttackHighBossCount( ... )
	local treasureCopy = DB_Treasure_copy.getDataById(1)
	return treasureCopy.num2
end

function getHighAttackNum( ... )
	return tonumber(_moonInfo.nightmare_atk_num)
end

function addHighAttackNum( addNum )
	_moonInfo.nightmare_atk_num = tonumber(_moonInfo.nightmare_atk_num) + addNum
end

function setHighAttackNum( num )
	_moonInfo.nightmare_atk_num = num
end

function bossIsShow(p_smallCopyId)
	local ret = true
	if p_smallCopyId - 1 > tonumber(_moonInfo.max_pass_copy) then
		ret = false
	elseif p_smallCopyId - 1 == tonumber(_moonInfo.max_pass_copy) then
		for k, v in pairs(_moonInfo.grid) do
			if v ~= GridStatus.PASSED then
				ret = false
				break
			end
		end
	end
	return ret
end


function highBossIsLocked(p_smallCopyId)
	local ret = true
	if p_smallCopyId -1 <= tonumber(_moonInfo.max_nightmare_pass_copy or 0) then
		ret = false
	end
	return ret
end

function setAttackBossData(attackData, p_copyId, p_bossType)
	if p_bossType == kNormal then
		if attackData.open_copy ~= "0" then
			_moonInfo.max_pass_copy = tonumber(_moonInfo.max_pass_copy) + 1
			_moonInfo.grid = {}
			local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(_moonInfo.max_pass_copy + 1)
			local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
			local gridCount = #gridDbs
			for i = 1, gridCount do
				if i == treasureSmallcopyDb.open_id then
					_moonInfo.grid[tostring(i)] = GridStatus.OPENED
				else
					_moonInfo.grid[tostring(i)] = GridStatus.LOCKED
				end
			end
		end
	else
		if p_copyId > tonumber(_moonInfo.max_nightmare_pass_copy) then
			_moonInfo.max_nightmare_pass_copy = tonumber(_moonInfo.max_nightmare_pass_copy) + 1
		end
	end
end

function getGridInfos( p_smallCopyId )
	local gridInfos = {}
	if p_smallCopyId <= tonumber(_moonInfo.max_pass_copy) then
		local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(p_smallCopyId)
		local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
		local gridCount = #gridDbs
		for i = 1, gridCount do
			gridInfos[tostring(i)] = GridStatus.PASSED
		end
	elseif p_smallCopyId == tonumber(_moonInfo.max_pass_copy) + 1 then
		gridInfos = _moonInfo.grid
	else
		local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(p_smallCopyId)
		local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
		local gridCount = #gridDbs
		for i = 1, gridCount do
			gridInfos[tostring(i)] = GridStatus.LOCKED
		end
	end
	return gridInfos
end

function getOpenBoxCost( ... )
	local treasureCopyDb = DB_Treasure_copy.getDataById(1)
	local costs = parseField(treasureCopyDb.case_prize, 2)
	local curCount = tonumber(_shopInfo.buy_box_count)
	for i = 1, #costs do
		local cost = costs[i]
		if curCount < cost[1] then
			return cost[2]
		end
	end
	return costs[#costs][2]
end

function getOpenBoxLimit( ... )
	local treasureCopyDb = DB_Treasure_copy.getDataById(1)
	local costs = parseField(treasureCopyDb.case_prize, 2)
	return costs[#costs][1]
end

function setBuyBoxInfo( buyBoxInfo )
	_buyBoxInfo = buyBoxInfo
	_shopInfo.buy_box_count = tonumber(_shopInfo.buy_box_count) + 1
end

function getBuyBoxInfo( ... )
	return _buyBoxInfo
end

function getRefreshCost( ... )
	local treasureCopymallDb = DB_Treasure_copymall.getDataById(1)
	local costs = parseField(treasureCopymallDb.goldGost, 2)
	local curCount = tonumber(_shopInfo.gold_refresh_num)
	print("curCount")
	print(curCount)
	for i = 1, #costs do
		local cost = costs[i]
		if curCount < cost[1] then
			return cost[2]
		end
	end
	return costs[#costs][2]
end

function getRefreshLimit( ... )  --获取不同等级的刷新上限
	-- 获取当前用户vip等级
	local vipLevel = UserModel.getVipLevel()
	local vipDb = DB_Vip.getDataById(vipLevel + 1)
	return vipDb.refresh
end

function setRefreshGoodsList( refreshInfo )
	local number = nil
	_shopInfo.goods_list = refreshInfo.goods_list
	if(MoonData.getNumberRef()<= 0)then  --如果免费刷新用完
		_shopInfo.gold_refresh_num = tonumber(_shopInfo.gold_refresh_num) + 1
	else
  		--免费刷新次数没有用完时，要将免费次数-1
 		addNumberRef(-1)
	end
end

-- function getRefreshRemainTime( ... )
-- 	local curTime = TimeUtil.getSvrTimeByOffset()
-- 	local remainTime = tonumber(_shopInfo.refresh_cd) - curTime
-- 	return remainTime
-- end

function addBossReward( p_smallCopyId, bossType)
	local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(p_smallCopyId)
	local itemDatas = nil
	if bossType == kNormal then
		itemDatas = ItemUtil.getItemsDataByStr(treasureSmallcopyDb.reward)
	else
		itemDatas = ItemUtil.getItemsDataByStr(treasureSmallcopyDb.reward2)
	end
	ItemUtil.addRewardByTable(itemDatas)
end

function resetMoonInfo( ... )
	_moonInfo.atk_num = 0
	_moonInfo.buy_num = 0
end

function resetMoonShopInfo( ... )
	_shopInfo.gold_refresh_num = 0
end

function getMoonShopPreviewItemIds( ... )
	local treasureCopymallDb = DB_Treasure_copymall.getDataById(1)
	local displayItemsIds = parseField(treasureCopymallDb.display)
	return displayItemsIds
end
