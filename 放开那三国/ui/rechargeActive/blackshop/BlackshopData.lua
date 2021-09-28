-- FileName: BlackShopData.lua 
-- Author: yangrui 
-- Date: 15-8-28
-- Purpose: function description of module 

module("BlackshopData", package.seeall)

require "script/utils/TimeUtil"
require "script/ui/item/ItemUtil"

local _convertedTimes   = {}          -- 已兑换的次数

--[[
	@des 	: 返回活动开启时间戳
	@param 	: 
	@return : 活动配置中的活动开始时间戳
--]]
function getStartTime()
	return ActivityConfigUtil.getDataByKey("blackshop").start_time
end

--[[
	@des 	: 返回活动结束时间戳
	@param 	: 
	@return : 活动配置中的活动结束时间戳
--]]
function getEndTime()
	return ActivityConfigUtil.getDataByKey("blackshop").end_time
end

--[[
	@des 	: 返回活动开启的第多少天
	@param 	: 
	@return : 活动开启的第多少天（第一天为1，过了24点为第二天）
--]]
function whichDay()
	--活动开启时间
	local openTime = getStartTime()
	--将开启时间转换为时，分，秒格式，便于计算当日零点时间戳
	local transFormTime = os.date("*t", openTime)
	--当日零点时间戳
	local zeroTime = openTime - transFormTime.sec - transFormTime.min*60 - transFormTime.hour*3600
	--当前时间
	local curTime = TimeUtil.getSvrTimeByOffset(1)
	--第多少天
	local dayNumber = math.ceil((curTime - zeroTime)/86400)

	return dayNumber
end

--[[
	@des    : 得到已兑换次数
	@param  : 商品id
	@return : 已兑换的次数
--]]
function getConvertedTimes( pId )
	if table.isEmpty(_convertedTimes) then
		return 0
	else
		if _convertedTimes[pId] ~= nil then
			return _convertedTimes[pId]
		else
			return 0
		end
	end
end

--[[
	@des    : 设置已兑换次数
	@param  : 
	@return : 
--]]
function setConvertedTimes( pRet )
	_convertedTimes = {}
	if table.isEmpty(pRet) then
		return
	else
		for k,v in pairs(pRet) do
			_convertedTimes[tonumber(k)] = pRet[k].num
		end
	end
end

--[[
	@des    : 增加Item已兑换次数
	@param  : 
	@return : 
--]]
function addConvertedTimes( pId, pGoodNum )
	local pid = tonumber(pId)
	local goodNum = tonumber(pGoodNum)
	local isNewID = true
	for k,v in pairs(_convertedTimes) do
		if ( pid == k ) then
			isNewID = false
			_convertedTimes[k] = _convertedTimes[k] + goodNum
		end
	end
	if ( isNewID ) then
		_convertedTimes[pid] = goodNum
	end
end

--[[
	@des 	: 获取最大可兑换次数
	@param 	: pId
	@return : 最大可兑换次数
--]]
function getMaxConvertTimes( pId )
	local pid = tonumber(pId)
	return ActivityConfig.ConfigCache.blackshop.data[pid].times
end

--[[
	@des 	: 得到兑换所需商品数据
	@param 	: pId  兑换所需物品id
	@return : 兑换所需商品数据
--]]
function getConvertNeedItem( pId )
	local pid = tonumber(pId)
	local needItemData = ActivityConfigUtil.getDataByKey("blackshop").data[pid].need_item
	return ItemUtil.getItemsDataByStr(needItemData)
end

--[[
	@des 	: 得到兑换获得商品数据
	@param 	: pId  兑换所需物品id
	@return : 兑换获得商品数据
--]]
function getConvertGetItem( pId )
	local pid = tonumber(pId)
	local getItemData = ActivityConfigUtil.getDataByKey("blackshop").data[pid].get_item
	return ItemUtil.getItemsDataByStr(getItemData)
end

--[[
	@des 	: 得到兑换信息
	@param 	: pId  兑换配置id
	@return : 兑换信息
--]]
function getConvertItemsInfo( pId )
	local pid = tonumber(pId)
	return ActivityConfigUtil.getDataByKey("blackshop").data[pid]
end

--[[
	@des 	: 获取兑换所需Item的数量
	@param 	: pId 兑换所需物品的id
	@return : 兑换所需Item的数量
--]]
function getConvertItemNum( pId )
	local pid = tonumber(pId)
	local data = string.split(ActivityConfig.ConfigCache.blackshop.data[pid].get_item, "|")
	local convertItemNum = tonumber(data[3])
    return convertItemNum
end

--[[
	@des 	: 获取物品刷新类型
	@param 	: pId 兑换所需物品的id
	@return : 
--]]
function getRefreshTypeByGoodsId( pId )
	local pid = tonumber(pId)
	local refreshType = tonumber(ActivityConfig.ConfigCache.blackshop.data[pid].refresh_type)
	if refreshType ~= nil or refreshType ~= "" then
		return refreshType
	else
		return 1
	end
end

--[[
	@des 	: 取得当天的活动配置数组
	@param 	: pDay  活动的第几天
	@return : 当天的活动配置数组
--]]
function getTodayData( pDay )
    local data = string.split(ActivityConfig.ConfigCache.blackshop.data[1].show_exchange, ",")
    local retTab = string.split(data[tonumber(pDay)], "|")
    -- local retTab = {}
    -- local configData = ActivityConfig.ConfigCache.blackshop.data
    -- for id,goodsInfo in pairs(configData) do
    -- 	local data = string.split(goodsInfo.show_exchange, ",")
    -- 	for k,v in pairs(data) do
    -- 		if tonumber(v) == tonumber(pDay) then
    -- 			table.insert(retTab,id)
    -- 			table.sort(retTab)
    -- 		end
    -- 	end
    -- end
    return retTab
end
