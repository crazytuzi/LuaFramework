-- Filename: WeekendShopData.lua
-- Author: zhangqiang
-- Date: 2014-10-11
-- Purpose: 周末商店数据处理

module("WeekendShopData", package.seeall)
require "db/DB_Weekendshop"
require "db/DB_Weekendshop_goods"

kSoulJewelTag = 1
kGoldTag = 2
kSilverTag = 3

local _allInfo = nil
local _curShopData = nil
local _curShopAllGoods = nil
local _curGoodList = nil

--[[
	@desc :	初始化
	@param:
	@ret  :
--]]
function init( pWeekCount )
	-- setAllInfo(pData)
	-- print("----------weekend shop----------")
	-- print_t(_allInfo)
	local curShopId = getCurShopId(pWeekCount)
	_curShopData = getShopDataById( curShopId )
	_curShopAllGoods = getShopAllGoodsById(curShopId)
	--_curGoodList = getRandomGoodList()
end

--[[
	@desc :	初始化商店开启时的界面数据
	@param:
	@ret  :
--]]
function initOpenShop( pData )
	setAllInfo(pData)
	print("----------weekend shop----------")
	print_t(_allInfo)
	_curGoodList = getRandomGoodList()
end	

--[[
	@desc :	设置所有信息
	@param:
	@ret  :
--]]
function setAllInfo( pAllInfo )
	_allInfo = pAllInfo
end

--[[
	@desc :	获取所有信息
	@param:
	@ret  :
--]]
function getAllInfo(  )
	return _allInfo
end

--[[
	@desc :	获取当前商店信息
	@param:
	@ret  :
--]]
function getCurShopData( ... )
	return _curShopData
end

--[[
	@desc :	获取当前商店开启时间
	@param:
	@ret  :
--]]
function getCurShopStartTime( ... )
	return _curShopData.startTime
end

--[[
	@desc :	获取当前商店关闭时间
	@param:
	@ret  :
--]]
function getCurShopEndTime( ... )
	return _curShopData.endTime
end

--[[
	@desc :	获取当前商店所有的商品信息，用于商品预览
	@param:
	@ret  :
--]]
function getCurShopAllGoods( ... )
	return _curShopAllGoods
end

--[[
	@desc :	获取当前随机的商品列表
	@param:
	@ret  :
--]]
function getCurGoodList( ... )
	return _curGoodList
end

--[[
	@desc :	刷新当前随机的商品列表数据
	@param:
	@ret  :
--]]
function updateCurGoodList( ... )
	_curGoodList = getRandomGoodList()
end


--[[
	@desc :	根据商店id获取商店信息
	@param:
	@ret  : 
	{
		config = table --本地配置信息
		startTime = int --当前商店开启时间
		endTime = int --当前商店关闭时间
	}
--]]
function getShopDataById( pShopId )
	pShopId = tonumber(pShopId)

	local shopData = {}
	--获取本地配置
	shopData.config = DB_Weekendshop.getDataById(pShopId)

	--获取商店的开启和结束时间戳
	shopData.startTime, shopData.endTime = getShopIntervalById(pShopId)

	--获取商店可用于花费的物品类型和每次刷新消耗的数量
	shopData.costItem = getRefreshCostById(pShopId)
	print("getShopDataById")
	print_t(shopData)

	return shopData
end

--[[
	@desc :	从服务器数据中获取当前商店id
	@param:
	@ret  :
--]]
function getCurShopId( pWeekCount )
	--当前是第几周
	--local weekCount = tonumber(_allInfo.weekendshop_num)
	local weekCount = tonumber(pWeekCount) --从0开始
	local loopShopIds = lua_string_split(DB_Weekendshop.getDataById(1).circleId, ",")
	local curShopId = loopShopIds[weekCount%(#loopShopIds)+1]
	return tonumber(curShopId)
end	

--[[
	@desc :	获得商店开启和关闭的时间戳
	@param:
	@ret  :
--]]
function getShopIntervalById( pShopId )
	local configData = DB_Weekendshop.getDataById(pShopId)
	if configData == nil then return end

	local timeStr = lua_string_split(configData.lastTime, ",")
	local timeTable = {}
	for k,v in ipairs(timeStr) do
		local temp = lua_string_split(v, "|")
		timeTable[k] = {}
		timeTable[k].wday = tonumber(temp[1])
		timeTable[k].hour = tonumber(string.sub(temp[2],1,2))
		timeTable[k].min = tonumber(string.sub(temp[2],3,4))
		timeTable[k].sec = tonumber(string.sub(temp[2],5,6))
	end

	local curTime = BTUtil:getSvrTimeInterval()
	local curTimeTable = os.date("*t",curTime)

	--为了与timeTable中的wday计数方式统一
	--配置中:星期1 ＝> 1 在os.date中:星期1 ＝> 2
	curTimeTable.wday = curTimeTable.wday - 1
	curTimeTable.wday = curTimeTable.wday == 0 and 7 or curTimeTable.wday
	
	print("getShopIntervalById")
	print_t(timeTable)
	print_t(curTimeTable)
	local startTime = curTime + (timeTable[1].wday - curTimeTable.wday)*24*3600 + (timeTable[1].hour - curTimeTable.hour)*3600
	                  + (timeTable[1].min - curTimeTable.min)*60 + (timeTable[1].sec - curTimeTable.sec)
	local endTime =  curTime + (timeTable[2].wday - curTimeTable.wday)*24*3600 + (timeTable[2].hour - curTimeTable.hour)*3600
	                 + (timeTable[2].min - curTimeTable.min)*60 + (timeTable[2].sec - curTimeTable.sec)
	return startTime, endTime
end

--[[
	@desc :	获取在用物品或金币刷新商店随机物品列表时，可用于花费的物品类型和每次刷新消耗的数量
	@param:
	@ret  :
--]]
function getRefreshCostById( pShopId )
	local configData = DB_Weekendshop.getDataById(pShopId)
	if configData == nil then return end

	local costStr = lua_string_split(configData.costItem, ",")
	local costItem = {}
	for k,v in ipairs(costStr) do
		local temp = lua_string_split(v, "|")
		costItem[k] = {}
		costItem[k].tid = tonumber(temp[1])
		costItem[k].num = tonumber(temp[2])
		costItem[k].hasNum = ItemUtil.getCacheItemNumBy(costItem[k].tid)
	end
	return costItem
end

--[[
	@desc :	周末商人时候在开启时间段内
	@param:
	@ret  :
--]]
function doShopOpen( ... )
	local ret = false
	local curTime = BTUtil:getSvrTimeInterval()
	if _curShopData ~= nil and curTime >= _curShopData.startTime and curTime <= _curShopData.endTime then
		ret = true
	end
	return ret
end

--[[
	@desc :	根据指定的商店id的获取商店的所有商品信息
	@param:
	@ret  : allGoods = {
		{
			{
				config = table
				good = {
					type = int
					tid = int
					num = int
				}
			}
		}
	}
--]]
function getShopAllGoodsById( pShopId )
	local shopConfig = DB_Weekendshop.getDataById(tonumber(pShopId))
	local goodIds = lua_string_split(shopConfig.showItems, ",")
	local allGoods = {}
	for k,v in ipairs(goodIds) do
		local temp = getGoodDataById(tonumber(v))
		if temp ~= nil then
			table.insert(allGoods, temp)
		end
	end
	return allGoods
end

--[[
	@desc :	根据商品id获取商品信息
	@param:
	@ret  : goodData = {
		config = table --商品配置表
		good = {
			type = int
			tid = int
			num = int
		}
		
	}
--]]
function getGoodDataById( pGoodId )
	local goodConfig = DB_Weekendshop_goods.getDataById(pGoodId)
	if goodConfig == nil or goodConfig.isSold ~= 1 then return end

	local goodData = {}
	goodData.config = goodConfig

	--商品类型，tid，单次兑换数量
	goodData.good = {}
	local goodTemp = lua_string_split(goodConfig.items, "|")
	goodData.good.type = tonumber(goodTemp[1])
	goodData.good.tid = tonumber(goodTemp[2])
	goodData.good.num = tonumber(goodTemp[3])

	return goodData
end

--[[
	@desc :	获得随机出售的商品列表
	@param:
	@ret  :
	{
		{
			config = table --商品配置表
			remian = int   --剩余兑换次数
			good = {
				type = int
				tid = int
				num = int
			}
			
		}
	}
--]]
function getRandomGoodList( ... )
	if _allInfo == nil or table.isEmpty(_allInfo.goodslist) then return {} end

	local goodList = {}
	for k,v in pairs(_allInfo.goodslist) do
		local goodData = getGoodDataById(k)
		if goodData ~= nil then
			goodData.remain = tonumber(v)
			table.insert(goodList, goodData)
		end
	end
	return goodList
end

--[[
	@desc :	获得当前商店剩余的兑换次数
	@param:
	@ret  :
--]]
function getRemainBuyNum( ... )
	if table.isEmpty(_allInfo) then return 0 end
	require "db/DB_Vip"
	local vipConfig = DB_Vip.getDataById(UserModel.getVipLevel()+1)

	return vipConfig.weekendShopBuy - tonumber(_allInfo.has_buy_num)
end

--[[
	@desc :	购买或兑换商品时，判断是否满足购买或兑换条件
	@param:
	@ret  :
--]]
function doMeetBuyConditions( pCellIndex )
	local goodData = _curGoodList[pCellIndex]
	local ret = true
	local retStr = ""

	--魂玉、金币或银币不足
	local hasNum = 0
	if goodData.config.costType == kSoulJewelTag then
		hasNum = UserModel.getJewelNum()
		retStr = GetLocalizeStringBy("key_1510")
	elseif goodData.config.costType == kGoldTag then
		hasNum = UserModel.getGoldNumber()
		retStr = GetLocalizeStringBy("key_1491")
	elseif goodData.config.costType == kSilverTag then
		hasNum = UserModel.getSilverNumber()
		retStr = GetLocalizeStringBy("key_1687")
	else
		error("cost type miss")
	end
	if hasNum < goodData.config.costNum then
		ret = false
		retStr = GetLocalizeStringBy("zz_121", retStr)
		return ret, retStr
	end

	--超过当天可兑换次数
	if getRemainBuyNum() <= 0 then
		ret = false
		retStr = GetLocalizeStringBy("zz_122")
		return ret, retStr
	end

	--该商品兑换次数不足
	if goodData.remain <= 0 then
		ret = false
		retStr = GetLocalizeStringBy("zz_123")
		return ret, retStr
	end

	return ret, retStr
end

--[[
	@desc :	购买或兑换商品时，成功购买或兑换商品后消耗资源
	@param:
	@ret  :
--]]
function buyGoodSuccessful( pCellIndex )
	local goodData = _curGoodList[pCellIndex]

	--消耗魂玉、金币或银币
	if goodData.config.costType == kSoulJewelTag then
		UserModel.addJewelNum( -goodData.config.costNum )
	elseif goodData.config.costType == kGoldTag then
		UserModel.addGoldNumber( -goodData.config.costNum )
	elseif goodData.config.costType == kSilverTag then
		UserModel.addSilverNumber( -goodData.config.costNum )
	else
		error("cost type miss")
	end

	--消耗该商品的可兑换次数
	_allInfo.goodslist[tostring(goodData.config.id)] = tostring(tonumber(_allInfo.goodslist[tostring(goodData.config.id)]) - 1)

	--消耗当天可兑换次数
	_allInfo.has_buy_num = tostring(tonumber(_allInfo.has_buy_num) + 1)

	--刷新当天剩余可兑换次数
	WeekendShopLayer.refreshRemainBuyNum()

	--刷新当前魂玉数量
	WeekendShopLayer.refreshSoulJewelNum()

	--更新当前随机商品列表数据（兑换次数变化)， 刷新表格
	WeekendShopLayer.refreshTableView(true)

	--获得物品的弹窗提示
	require "script/ui/rechargeActive/ActiveUtil"
	ActiveUtil.showItemGift(goodData.good)

end

--[[
	@desc :	用物品或金币刷新商品时，判断是否满足刷新条件
	@param:
	@ret  :
--]]
function doMeetRefreshConditions( ... )
	local ret = true
	local retStr = ""

	local costTid, costNum, hasNum = getRefreshCostItem()
	if costTid == kGoldTag then
		if costNum > hasNum or costNum == 0 then
			--组合能够刷新的物品名字
			for k,v in ipairs(_curShopData.costItem) do
				local itemData = ItemUtil.getItemById(v.tid)
				retStr = retStr .. itemData.name .. "、"
			end

			--costNum为0时，表示不能用金币刷新
			if costNum == 0 then
				--去掉末尾的“、”（3 byte）
				retStr = string.sub(retStr,1,-4)
			else
				--连接字符串“金币”
				retStr = retStr .. GetLocalizeStringBy("key_1491")
			end

			ret = false
			retStr = GetLocalizeStringBy("zz_126",retStr)
			print("doMeetRefreshConditions", ret, retStr)
			return ret, retStr
		end
	end

	return ret, retStr
end

--[[
	@desc :	刷新商品时，获取用于花费的物品
	@param:
	@ret  :
--]]
function getRefreshCostItem( ... )
	--首先判断是否拥有足够的用于刷新的物品(刷新令/免战牌)
	for k,v in ipairs(_curShopData.costItem) do
		if v.hasNum >= v.num then
			return v.tid, v.num, v.hasNum
		end
	end

	--用于刷新的物品不够时， 用金币刷新
	local costNum = _curShopData.config.goldBase + _curShopData.config.goldGrow*tonumber(_allInfo.rfr_num_by_player)
	if _curShopData.config.maxGold ~= nil then
		costNum = costNum > _curShopData.config.maxGold and _curShopData.config.maxGold or costNum
	end
	local costTid = kGoldTag
	local hasNum = UserModel.getGoldNumber()
	return costTid, costNum, hasNum
end

--[[
	@desc :	用物品或金币成功刷新随机商品列表后，消耗相应资源
	@param:
	@ret  :
--]]
function refreshGoodSuccessful( pCostTid, pCostNum)
	if pCostTid == kGoldTag then
		UserModel.addGoldNumber(-pCostNum)
	else
		for k,v in ipairs(_curShopData.costItem) do
			if v.tid == pCostTid then
				_curShopData.costItem[k].hasNum = v.hasNum - v.num
				break
			end
		end
	end

	WeekendShopLayer.refreshRefreshBtn()

	WeekendShopLayer.refreshTableView(false)
end