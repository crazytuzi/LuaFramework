-- FileName: LimitFundData.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-13
-- Purpose: 限时基金数据层

module("LimitFundData",package.seeall)
local _dataInfo = {}

--获取后端传送的数据
function setDataInfo( pData )
	_dataInfo = pData
	getEndTimeOfBuy()
end

function getDataInfo( ... )
	return _dataInfo.limitFundInfo
end
--获取配置表内容
function getLimitFundInfo( ... )
	-- 读配置表
	local limitFundData = ActivityConfigUtil.getDataByKey("limitFund").data
	return limitFundData
end


--通过id获取某一条数据
function getLimitFundInfoById( pId )
	local data = getLimitFundInfo()
	return data[pId]
end
--获取购买次数
function getNumOfAllBuy( ... )
	local data = getLimitFundInfoById(1)
	return tonumber(data.max_times)
end

--获取开始时间
function getBeginTime( ... )
	return ActivityConfigUtil.getDataByKey("limitFund").start_time
end

--获取结束时间
function getEndTime( ... )
	return ActivityConfigUtil.getDataByKey("limitFund").end_time
end

--获取购买阶段结束时间
function getEndTimeOfBuy( ... )
	local buyTime = tonumber(getLimitFundInfoById(1).buy_time)
	local begin = getBeginTime()
	return (begin + buyTime*24*60*60)
end

--判断现在活动处于什么阶段(购买阶段0  返还阶段1)
function getPeriodOfActivity( ... )
	--获取当前时间
	local curTime = BTUtil:getSvrTimeInterval()
	local buyEndTime = getEndTimeOfBuy()
	print("curTime =>",curTime,"buyEndTime =>",buyEndTime)
	if(curTime <= buyEndTime)then
		return 0
	else
		return 1
	end
end


--判断活动是否可以转到返还阶段(false不可以进入   true可以进入)
function isCanEnterRetuen( ... )
	if(table.isEmpty(_dataInfo.limitFundInfo))then
		return false
	else
		return true
	end
end

--判断返还阶段按钮状态(0为未到领取条件，1为可以领取，2为已领取)id 第几期
function getStatues( pId ,period)
	for k1,v1 in pairs(_dataInfo.limitFundInfo) do
		if(tonumber(k1) == tonumber(pId))then
			for k2,v2 in pairs(v1.gain) do
				if(tonumber(k2) == tonumber(period))then
					return tonumber(v2)
				end
			end
		end
	end
end

function getTypeOfNumTable( ... )
	local typeNum = {}
	if(not table.isEmpty(_dataInfo.limitFundInfo))then
		for k,v in pairs(_dataInfo.limitFundInfo) do
			local tableOfK = {}
			tableOfK.type = tonumber(k)
			table.insert(typeNum,tableOfK)
		end
	end
	-- print("输出形式888888")
	-- print_t(typeNum)
	return typeNum
end


function getTypeOfNumTableById( pId )
	local isHaveBuy = false
	if(not table.isEmpty(_dataInfo.limitFundInfo))then
		for k,v in pairs(_dataInfo.limitFundInfo) do
			if(tonumber(k) == pId)then
				isHaveBuy = true
				break
			end
		end
	end
	return isHaveBuy
end

--获取可购买的最大次数
function getMaxBuyTimes( ... )
	local allTime = getNumOfAllBuy()
	local allreadyBuy = 0
	if(not table.isEmpty(_dataInfo.limitFundInfo))then
		for i=1,3 do
			for k,v in pairs(_dataInfo.limitFundInfo) do
				if(tonumber(k) == i)then
					allreadyBuy = tonumber(v.buyNum)
					allTime = allTime - allreadyBuy
				end
			end
		end
	end
	
	return allTime
end

--活动是否开启
function isOpen( ... )
	if(not ActivityConfigUtil.isActivityOpen("limitFund"))then
		return false
	end
	local beginTime = getBeginTime()
	local endTime = getEndTime()
	local curTime = BTUtil:getSvrTimeInterval()
	if(table.isEmpty(_dataInfo.limitFundInfo))then
		endTime = getEndTimeOfBuy()
	end
	if(curTime >= beginTime and curTime < endTime)then
		return true
	else
		return false
	end

	
end


--获取已经购买次数
function getAllreadyNum( pId )
	local allreadyBuy = 0
	if(not table.isEmpty(_dataInfo.limitFundInfo))then
		for k,v in pairs(_dataInfo.limitFundInfo) do
			if(tonumber(k) == tonumber(pId))then
				allreadyBuy = tonumber(v.buyNum)
			end
		end
	end
	return allreadyBuy
end

--判断活动是否结束(true为结束  false未结束)
function isActivityOver( ... )
	local endTime = getEndTime()
	local curTime = BTUtil:getSvrTimeInterval()
	if(table.isEmpty(_dataInfo.limitFundInfo))then
		endTime = getEndTimeOfBuy()
	end
	if(curTime >= endTime)then
		return true
	else
		return false
	end
end

--获取字段way的内容(天数|物品类型|id|数量)
function getDataOfWay( pId )
	local dataTable = {}
	local data = getLimitFundInfo()[tonumber(pId)]
	local dataInfo = string.split(data.way,",")
	for i=1,#dataInfo do
		local info = dataInfo[i]
		local dataTable1 = string.split(info,"|")
		table.insert(dataTable,dataTable1)
	end
	
	return dataTable
end

--获取某一类基金的奖励期数
function getNumOfPeriod( pId )
	local data = getLimitFundInfo()[pId]
	local dataInfo = string.split(data.way,",")
	return #dataInfo
end

--获取活动持续了几天
function getDayOfAlreadyOpen( ... )
	local beginTime = getBeginTime()
	local mergeZeroTime = TimeUtil.getCurDayZeroTime(beginTime)
	local lastTime= BTUtil:getSvrTimeInterval() - mergeZeroTime
	local lastDay= math.ceil(lastTime/(24*60*60)) 
    return lastDay
end

--预期收益
function getExpectMoney( ... )
	return tonumber(_dataInfo.expectMoney)
end

--改变基金已购买次数
function setInfoOfGoods( pId,pNum )
	local isHaveId = false
	if(table.isEmpty(_dataInfo.limitFundInfo))then
		if (_dataInfo.limitFundInfo[pId] == nil) then
			_dataInfo.limitFundInfo[pId] = {}
		end
		_dataInfo.limitFundInfo[pId].buyNum = pNum
	else
		for k,v in pairs(_dataInfo.limitFundInfo) do
			if(tonumber(k) == pId)then
				v.buyNum = v.buyNum + pNum
				isHaveId = true
				break
			end		
		end
		if(not isHaveId)then
			if (_dataInfo.limitFundInfo[pId] == nil) then
				_dataInfo.limitFundInfo[pId] = {}
			end
			_dataInfo.limitFundInfo[pId].buyNum = pNum
		end
	end	
end


--改变返还阶段状态
function changeGainNum( period )
	for k,v in pairs(_dataInfo.limitFundInfo) do
		
			for k2,v2 in pairs(v.gain) do
				if(tonumber(k2) == tonumber(period))then
					v.gain[tostring(period)] = 2

				end
		end		
	end
end

--获取一次返还的金币数
function getGoldOfReturn( pId )
	local data = getLimitFundInfoById(tonumber(pId))
	return tonumber(data.gold)
end

--修改预期基金
function addExpectMoney( pGoldNum )
	_dataInfo.expectMoney = tonumber(_dataInfo.expectMoney) + pGoldNum
end

-- 得到兑换物品的 天数，金币量，返次数
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end

function getTableOfShow( str )	
	local dataTable = string.split(str,"|")
	return dataTable
end

--[[
	@desc	: 创建箭头闪烁动画
	@param	: pArrow 箭头精灵
	@return : 
--]]
function runArrowAction( pArrow )
	local actionArrs = CCArray:create()
	actionArrs:addObject(CCFadeOut:create(1))
	actionArrs:addObject(CCFadeIn:create(1))
	local sequenceAction = CCSequence:create(actionArrs)
	local foreverAction = CCRepeatForever:create(sequenceAction)
	pArrow:runAction(foreverAction)
end


--判断红点
function isRedTip( ... )
	local redTip = false
	if(table.isEmpty(_dataInfo.limitFundInfo))then
		return
	end
	local typeNumTable = getTypeOfNumTable()
	if(table.isEmpty(typeNumTable))then
		return
	end
	
	for id,v in pairs(_dataInfo.limitFundInfo) do
		-- for k1,v1 in pairs(typeNumTable) do
			if(tonumber(id) == tonumber(typeNumTable[1].type))then
				for k2,v2 in pairs(v.gain) do
					if(tonumber(v2) == 1)then
						redTip = true
						break
					end
				end
			end
		-- end
	end
	return redTip
end

function getTimeDesByInterval( timeInt )

	local result = ""
	local oh	 = math.floor(timeInt/3600)
	local om 	 = math.floor((timeInt - oh*3600)/60)
	local os 	 = math.floor(timeInt - oh*3600 - om*60)
	local hour = oh
	local day  = 0
	if(oh>=24) then
		day  = math.floor(hour/24)
		hour = oh - day*24
	end
	if(day ~= 0) then
		result = result .. day .. GetLocalizeStringBy("key_2825")
	end
	if(hour ~= 0) then
		result = result .. hour ..GetLocalizeStringBy("key_1769")
	end
	if(om ~= 0) then
		result = result .. om .. GetLocalizeStringBy("key_3249")
	end
	-- if(os ~= 0)then
		result = result .. os .. GetLocalizeStringBy("key_3240")
	-- end
	return result
end