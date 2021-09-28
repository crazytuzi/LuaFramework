-- FileName: TuanData.lua 
-- Author: licong 
-- Date: 14-5-21 
-- Purpose: 团购数据处理 


module("TuanData", package.seeall)

require "script/model/utils/ActivityConfig"

local _serviceData = nil -- 服务器数据

-- 设置团购数据
function setServiceData( data )
	_serviceData = data
end

-- 得到团购数据
--[[ -- 后端数据结构
{
    day = 0  -- 活动第几天
    goods_list = {  -- 物品列表
        1 = {  -- 物品id为key
            state = 1  -- 是否购买 0没有 1已经购买
            rewards = { -- 已领取奖励列表
                    reward1
                }
            soldNum = 100 -- 购买人数
        }
    }
}
-- ]]
function getServiceData( ... )
	return _serviceData
end

-- 根据id得到团购奖励数组
--[[ 返回数据结构
	goodsData = {
		retData = {} 		-- 后端返回数据
		goodsId = id 		-- 改商品id
		dbData = {}  		-- 表配置数据
		listData = {} 		-- 奖励列表
	}
--]]
function getGoodsDataById( id )
	local goodsData = {}
	-- 取该物品服务器数据
	local data = getServiceData()
	local retData = {}
	for k,v in pairs(data.goods_list) do
		if(tonumber(k) == tonumber(id) )then
			-- 返回数据
			retData = v
			break
		end
	end
	goodsData.retData = retData
	goodsData.goodsId = tonumber(id)
	-- 表配置数据
	local dbData = ActivityConfig.ConfigCache.groupon.data[tonumber(id)]
	-- print("id",id)
	-- print_t(dbData)
	goodsData.dbData = dbData
	-- 奖励列表
	local listData = {}
	for i=1,tonumber(dbData.numtop) do
		if(dbData["num" .. i]~= nil and dbData["num" .. i]~= "" and dbData["reward" .. i] ~= nil and dbData["reward" .. i] ~= "")then
			local data = {}
			-- 需要参团人数
			data.needNum = tonumber(dbData["num" .. i])
			-- 满足条件奖励
			data.rewardStr = dbData["reward" .. i]
			-- 参团人数
			data.haveNum = tonumber(retData.soldNum)
			-- 奖励id
			data.id = i
			-- goodsId
			data.goodsId = tonumber(id)
			-- 是否参团
			data.state = tonumber(retData.state)
			-- 奖励礼包图片
			data.rewardIcon = dbData["picture" .. i]
			-- 奖励礼包品质
			data.rewardQuality = dbData["quality" .. i]

			table.insert(listData,data)
		end
	end
	goodsData.listData = listData
	return goodsData
end

-- 是否已领奖 true:已领奖
function isHaveReward( goodsId, rewardId )
	local ret = false
	if(_serviceData.goods_list[tostring(goodsId)])then
		if(_serviceData.goods_list[tostring(goodsId)].rewards)then
			for k,v in pairs(_serviceData.goods_list[tostring(goodsId)].rewards) do
				if(v == "reward" .. rewardId)then
					ret = true
					break
				end
			end
		end
	end
	return ret
end

-- 添加已领奖的inde
function addHaveRewardIndex( goodsId, rewardId )
	if(_serviceData.goods_list[tostring(goodsId)])then
		if(_serviceData.goods_list[tostring(goodsId)].rewards)then
			local isHave = false
			for k,v in pairs(_serviceData.goods_list[tostring(goodsId)].rewards) do
				if(v == "reward" .. rewardId)then
					isHave = true
					break
				end
			end
			if(isHave == false)then
				table.insert(_serviceData.goods_list[tostring(goodsId)].rewards,"reward" .. rewardId)
			end
		else
			_serviceData.goods_list[tostring(goodsId)].rewards = {}
			table.insert(_serviceData.goods_list[tostring(goodsId)].rewards,"reward" .. rewardId)
		end
	end
end


-- 得到已购买人数，差多少人数，下级奖励人数
function getPeopleNum( goodsData )
	-- print_t(goodsData)
	local haveNum = tonumber(goodsData.retData.soldNum)
	local nextNum = nil
	for i=1,#goodsData.listData do
		if(haveNum < goodsData.listData[i].needNum)then
			nextNum = goodsData.listData[i].needNum
			break
		end	
	end
	local subNum = nil
	if(nextNum)then
		subNum = nextNum - haveNum
	end
	return haveNum,subNum,nextNum
end


-- 取配置id信息 第几天用第几个配置
-- 0是第一天
function getDataByDay( day )
	local data = string.split(ActivityConfig.ConfigCache.groupon.data[1].goodsId, ",")
	local todayTab = nil
	for i=1,#data do
		if(tonumber(day)+1 == i )then
			todayTab = data[i]
			break
		end
	end
	-- 解析今天使用礼包id
	local idTab = string.split(todayTab, "|")
	return idTab
end


-- 修改购买的人数
function setBuyGoodsNum( ret )
	for k,v in pairs(_serviceData.goods_list) do
		for id,num in pairs(ret) do
			if(tonumber(k) == tonumber(id))then
				v.soldNum = tonumber(num)
			end
		end
	end
end

-- 修改参团状态为1
function setGoodsState( goodsId )
	for k,v in pairs(_serviceData.goods_list) do
		if(tonumber(k) == tonumber(goodsId))then
			v.state = 1
		end
	end
end


-- 得到团购购买结束时间戳
function getTuanEndTime()
	local openDay = tonumber(ActivityConfig.ConfigCache.groupon.data[1].opentime) 
	local starTime = tonumber(ActivityConfig.ConfigCache.groupon.start_time)
	local retTime = starTime + openDay * 24*60*60
	return retTime
end
































