-- FileName: HolidayHappyData.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 节日狂欢数据层

module("HolidayHappyData",package.seeall)
require "script/ui/holidayhappy/HolidayHappyDef"


local _dataOfAll
local _redTipArray = {}
--从后端接口获取的数据
function SetDataOfAll( pData )
	_dataOfAll = pData
end

function getDataOfAll( ... )
	return _dataOfAll
end
--获取表festival_act内容
function getDataOfFestival_act( ... )
	local festivalAct = ActivityConfigUtil.getDataByKey("festivalAct").data
	return festivalAct 
end

--判断是登陆的第几天
function getDayOfLog( ... )
	return tonumber(_dataOfAll.day)
end
--获取是第几季
function getSeasonNum( ... )
	return tonumber(_dataOfAll.period)
end

--设置是第几季
function setSeasonNum( pSeason )
	_dataOfAll.period = tonumber(pSeason)
end
--获取第一季内容
function getOneDataOfFestival_act( pSeason )
	local festivalAct = getDataOfFestival_act()
	return festivalAct[pSeason]
end

--获取表festival_reward内容
function getDataOfFestival_reward( ... )
	local festivalActReward = ActivityConfigUtil.getDataByKey("festivalActReward").data
	return festivalActReward
end

--通过任务id获取具体奖励内容
function getDataOfFestival_rewardByTaskId( taskId )
	local data = getDataOfFestival_reward()
	return data[taskId]
end

--判断按钮状态
function getStatusOfButton( bigType,taskId,tag)
	-- 判断是第几季
	local seasonNum = tag
	local statues = 1
	local data =_dataOfAll.data[tostring(seasonNum)]
	if(HolidayHappyDef.kTypeOfTaskFour == tonumber(bigType) or HolidayHappyDef.kTypeOfTaskOne == tonumber(bigType))then
		local dataInfo = _redTipArray
		for k,v in pairs(dataInfo) do
			if(tonumber(k) == tonumber(taskId))then
				statues = tonumber(v)
				break
			end
		end
	else
		local dataInfo = data[tostring(bigType)]
		for k,v in pairs(dataInfo) do
			if(tonumber(k) == tonumber(taskId))then
				statues = tonumber(v[2])
				break
			end
		end
	end
	return statues
end

--充值类任务领取成功后修改缓存
function setredTipArray( taskId,value )
		for k,v in pairs(_redTipArray) do
			if(tonumber(k) == tonumber(taskId))then
				_redTipArray[k] = tostring(value) 
				break
			end
		end
end
--获取任务类型为3的所有任务id
function getAllDataOfTypeOfTaskThree( ... )
	local taskId = {}
	local dataInfo = _dataOfAll.exchange
	for id,v in pairs(dataInfo) do
		table.insert(taskId,tonumber(id))
	end
	return taskId
end
--修改购买次数(任务id,购买了几次)
function setNumOfBuy( taskId,buyNum)
	--现在是第几季
	local seasonNum = getSeasonNum()
	if(seasonNum == 0)then
		local rewardData = HolidayHappyData.getDataOfFestival_act()
		seasonNum = #rewardData
	end
	local data =_dataOfAll.data[tostring(seasonNum)]
	local idData = getDataOfFestival_rewardByTaskId(tonumber(taskId))
	local bigType = idData.bigtype
	local dataInfo = data[bigType]
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(taskId))then
			v[1] = tostring(tonumber(v[1])+buyNum)
		end
	end
	
end

--修改按钮状态
function setStatuesOfButton(taskId,value,seasonNum)
	local data =_dataOfAll.data[tostring(seasonNum)]
	local bigType = getDataOfFestival_rewardByTaskId(taskId).bigtype
	local dataInfo = data[tostring(bigType)]
		for k,v in pairs(dataInfo) do
			if(tonumber(k) == taskId)then
				dataInfo[tostring(k)][2] = tostring(value)
				break
			end
		end
end
--活动开始时间
function getStartTime( ... )
	return tonumber(ActivityConfigUtil.getDataByKey("festivalAct").start_time)
end

--活动结束时间
function getEndTime( ... )
	local rewardData = getDataOfFestival_act()
	local seasonNum = #rewardData
	local endTime = tonumber(getDataOfFestival_act()[seasonNum].end_time)
	return endTime 
end

--活动开始时间  格式为 x年x月x日x时
function startTimeLable( ... )
	local time = getStartTime()
	return TimeUtil.getTimeFormatYMDH(time)
end

--结束时间 格式为 x年x月x日x时
function endTimeLable( ... )
	local time = tonumber(ActivityConfigUtil.getDataByKey("festivalAct").end_time)
	return TimeUtil.getTimeFormatYMDH(time)
end
--判断活动结束
function isActiveOver( ... )
	if tonumber(TimeUtil.getSvrTimeByOffset()) >= getEndTime() then
		return true
	else
		return false
	end
end

--每季活动的剩余时间,参数为第几季
function remineTimeOfSeason( PseasonNum )
	local festivalAct = getDataOfFestival_act()
	local endTime = TimeUtil.getIntervalByTimeDesString(festivalAct[PseasonNum].end_time)
	return TimeUtil.getRemainTime(endTime)
end

function remineTimeOfSeasonStr( PseasonNum )
	local festivalAct = getDataOfFestival_act()
return  TimeUtil.getIntervalByTimeDesString(festivalAct[PseasonNum].end_time) - BTUtil:getSvrTimeInterval()

end
--解析价格
function getMoneyCost( pCost )
	return string.split(pCost,"|")
end
-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end
--通过后端返回的数据来判断已经购买了几次
function getAlreadyBuyTimes( bigType,taskId,seasonNumOfClick)
	local alreadyBuyTimes = 0
	local seasonNum = getSeasonNum()
	if(seasonNum == 0)then
		local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
	end
	if(seasonNumOfClick <= seasonNum)then
		local data =_dataOfAll.data[tostring(seasonNumOfClick)]
		local dataInfo = data[tostring(bigType)]
		for k,v in pairs(dataInfo) do
			if(tonumber(k) == tonumber(taskId))then
				alreadyBuyTimes = tonumber(v[1])
			end
		end
	end
	return alreadyBuyTimes
end
--折扣商品可购买剩余次数
function remainTimeOfBuy( pData ,seasonNumOfClick)
	return tonumber(pData.bugtimes) - getAlreadyBuyTimes(pData.bigtype,pData.id,seasonNumOfClick)
end
--获取所有任务id
function getAllTaskId( pSeason )
	local missionArray = {}
	local festivalAct = getDataOfFestival_act()
	if(pSeason == HolidayHappyDef.kSeasonOne)then
		local data = festivalAct[pSeason]
		for i=1,3 do
			local dataInfo = string.split(data["mission_"..i], "|")
			table.insert(missionArray,dataInfo)
		end
	else
		for i=1,2 do
			local data = festivalAct[i]
			for i=1,3 do
				local dataInfo = string.split(data["mission_"..i], "|")
				table.insert(missionArray,dataInfo)
			end
		end
	end
	return missionArray
end
--主界面红点
function isRedTipOfMainLayer( ... )
	if not isOpen() then
		--活动未开启
		return false
	end
	if(table.isEmpty(_dataOfAll))then
		return false
	end
	local seasonNum = getSeasonNum()
	if(seasonNum == 0)then
		local rewardData = HolidayHappyData.getDataOfFestival_act()
		seasonNum = #rewardData
	end
	local data = getAllTaskId(seasonNum)
	local redTip = false
	for i=1,table.count(data) do
		local dataInfo = data[i]
		redTip = isRedTipOfLabel(dataInfo)
		if(redTip)then
			break
		end
	end
	local isRedTip = false
	isRedTip = isRedTipOfLabelLast(seasonNum)
	local rechargeRedTip = true
	if isRedTipOfExchange2() then
        if( not isRedTipOfExchange())then
            --在兑换次数未用完，材料用完的情况下
            rechargeRedTip = false
        end
    else
        --兑换次数用完的情况下
        rechargeRedTip = false
    end
	if(isRedTip or redTip or rechargeRedTip)then
		return true
	else
		return false
	end
end

--标签上面红点(前3个页签)后端返回的redtip中只包含任务类型1和4两种的
function isRedTipOfLabel( missionIdTable )
	local isRedTip = false
	for k,v in pairs(missionIdTable) do
		for k1,v1 in pairs(_redTipArray) do
			if(tonumber(v) == tonumber(k1) and tonumber(v1) == HolidayHappyDef.kTaskStausCanGet)then
				isRedTip = true
				break
			end
		end
	end
	return isRedTip
end

--修改redtip信息
-- function changeRedTip( tag )
-- 	for k,v in pairs(_redTipArray) do
-- 		if(tag == tonumber(k))then
-- 			_redTipArray[tostring(k)] = tostring(2)
-- 			break
-- 		end
-- 	end
-- end
--限时折扣页签
function isRedTipOfLabelLast( ... )
	local seasonNum = getSeasonNum()
	if(seasonNum == 0)then
		local rewardData = HolidayHappyData.getDataOfFestival_act()
		seasonNum = #rewardData
	end
	local isRedTip = not HolidayHappyDef.getHolidayHappyEnter( seasonNum )
	return isRedTip

end


--限时兑换的红点
function isRedTipOfExchange( ... )
	
	local redtip = false
	local _data = {}
	local arrayTip = {}
	local taskIdArray = getAllDataOfTypeOfTaskThree()
	for k,v in pairs(taskIdArray) do
		local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(v))
		table.insert(_data,data)
	end
	for k,v in pairs(_data) do
		local datatimes = _dataOfAll.exchange
		for k1,v1 in pairs(taskIdArray) do
			local timesArray = datatimes[tostring(v1)]
			local times = tonumber(timesArray[1])
			if(tonumber(v.exchangetime) > times)then
				local need = string.split(v.need,",")
				local needNum = #need
				if(needNum == 1)then
					local type,id,num = getItemData(need[1])
					local allNum = ItemUtil.getCacheItemNumBy(id)
					if(allNum >= num)then
						redtip =  true
						break
					end
				else
					
					for k2,v2 in pairs(need) do
					local type,id,num = getItemData(v2)
					local allNum = ItemUtil.getCacheItemNumBy(id)
						if(allNum >= num)then
							redtip =  true
						end
						table.insert(arrayTip,redtip)
				    end
				    break
				end
				
			-- else
			-- 	redtip = false	
			-- 	break	
			end	
		end	
	end
	if(not table.isEmpty(arrayTip))then
		if(arrayTip[1] and arrayTip[2])then
			redtip = true
		end
	end
	
	print("redtip=====",redtip)
	return redtip
end

--限时兑换兑换条件判断
function exchangeCondition( tag )
	local redtip = true
	local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(tag))
	local datatimes = _dataOfAll.exchange
	local timesArray = datatimes[tostring(tag)]
	local times = tonumber(timesArray[1])
	if(tonumber(data.exchangetime) >= times)then
		local need = string.split(data.need,",")
		for k2,v2 in pairs(need) do
			local type,id,num = getItemData(v2)
			local allNum = ItemUtil.getCacheItemNumBy(id)
			if(allNum < num)then
				redtip =  false
				break
			end
		end
	else
		redtip = false	
	end	
	return redtip
end
--限时兑换红点
function isRedTipOfExchange2( ... )
	local redtip = false
	local _data = {}
	local taskIdArray = getAllDataOfTypeOfTaskThree()
	for k,v in pairs(taskIdArray) do
		local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(v))
		table.insert(_data,data)
	end
	for k,v in pairs(_data) do
		local num = tonumber(v.exchangetime) - getAlreadyExchangeTimes(v.id)
		if(num > 0)then
			redtip = true
			break
		end
	end
	return redtip
end

--[[
	@des 	: 充值类任务，即任务类型为4的任务，获取可以充值的剩余次数,可以领取奖励的次数，一共的充值次数
	@param 	:
	@return :
--]]
function remainTimesOfRecharge( bigType,taskId ,seasonNum)
	local remainTimes = 0
	local canReceiveTimes = 0
	local allTimes = tonumber(getDataOfFestival_rewardByTaskId(taskId).sihgleTimes)
	local data =_dataOfAll.data[tostring(seasonNum)]
	local dataInfo = data[tostring(bigType)]
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(taskId))then
			remainTimes = allTimes - (tonumber(v[1]) + tonumber(v[2]))
			canReceiveTimes = tonumber(v[2])
			if(remainTimes > 0)then
				if(canReceiveTimes == 0)then
					for k,v in pairs(_redTipArray) do
						if(tonumber(taskId) == tonumber(k))then
							_redTipArray[tostring(k)] = tostring(0)
							break
						end
					end
				end
			else
				if(canReceiveTimes == 0)then
					remainTimes = 0
					for k,v in pairs(_redTipArray) do
						if(tonumber(taskId) == tonumber(k))then
							_redTipArray[tostring(k)] = tostring(2)
							break
						end
					end
				elseif canReceiveTimes > 0 then
					for k,v in pairs(_redTipArray) do
						if(tonumber(taskId) == tonumber(k))then
							_redTipArray[tostring(k)] = tostring(1)
							break
						end
					end
				end
				
			end
				

		end
	end
	return remainTimes,canReceiveTimes,allTimes
end


--[[
	@des 	: 获取任务的总次数,剩余次数
	@param 	:
	@return :
--]]
function getTaskTimes(taskId ,seasonNum)
	local remainTimes = 0
	local canReceiveTimes = 0
	local allTimes = tonumber(getDataOfFestival_rewardByTaskId(tonumber(taskId)).finish)
		local data =_dataOfAll.data[tostring(seasonNum)]
		local dataInfo = data[tostring(1)]
		for k,v in pairs(dataInfo) do
			if(tonumber(k) == tonumber(taskId))then
				remainTimes =  tonumber(v[1])
			end
		end
	return remainTimes,allTimes
	
end

--[[
	@des 	: 获取限时兑换的消耗物品数据
	@param 	:
	@return :
--]]
function getDataOfNeed( ... )
	local _data = {}
	local taskIdArray = getAllDataOfTypeOfTaskThree()
	for k,v in pairs(taskIdArray) do
		local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(v))
		table.insert(_data,data)
	end
	return _data
end

--[[
	@des 	: 充值领取成功后，给可领取次数-1
	@param 	:
	@return :
--]]
function setCanReceiveTimes(taskId,seasonNum)
	if(seasonNum == 0)then
		local rewardData = HolidayHappyData.getDataOfFestival_act()
		seasonNum = #rewardData
	end
	local bigType = getDataOfFestival_rewardByTaskId(taskId).bigtype
	local data = _dataOfAll.data[tostring(seasonNum)]
	local dataInfo = data[tostring(bigType)]
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(taskId))then
			-- v[2] = tonumber(v[2]) -1 
			dataInfo[tostring(k)][2] = tonumber(dataInfo[tostring(k)][2]) - 1
			dataInfo[tostring(k)][1] = tonumber(dataInfo[tostring(k)][1]) + 1
			break
		end
	end
end

--[[
	@des 	: 充值活动的领取了奖励之后，修改redtip中的数据
	@param 	:
	@return :
--]]
function setredtipOfSingleRecharge( taskId )
	
	local data = _redTipArray
	for k,v in pairs(data) do
		if(tonumber(k) == tonumber(taskId))then
			v = tostring(2)
			break
		end
	end
end

--[[
	@des 	: 活动是否开启
	@param 	:
	@return :
--]]
function isOpen( ... )
	if not ActivityConfigUtil.isActivityOpen("festivalAct") then
		return false
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	local endTime = tonumber(ActivityConfigUtil.getDataByKey("festivalAct").end_time)
	return curTime < endTime
end


--[[
	@des 	: 登陆补签(id范围101001~101999)
	@param 	:
	@return :
--]]
function buqianFunc( taskId ,seasonNum)
	--先获取到是登陆的第几天
	local day = getDayOfLog()
	local typeId = getDataOfFestival_rewardByTaskId(tonumber(taskId)).typeId
	if(tonumber(typeId) == 101)then
		local finish = tonumber(getDataOfFestival_rewardByTaskId(tonumber(taskId)).finish)
		if(finish > day)then
			--如果该条数据大于登陆天数，则视为不能领取
			return 0
		elseif finish == day then
			--该条数据为可领取状态
			local statues = getStatusOfButton(1,taskId,seasonNum)
			if(statues == 1 or statues == 0)then
				--1为可领取
				return 1
			elseif statues == 2 then
				return 2
			end
		elseif finish < day then
			local statues = getStatusOfButton(1,taskId,seasonNum)
			if(statues == 0)then
				--还没有被领取 就是要为补签状态
				return 3
			else
				--已领取状态
				return 2
			end
		end
	end
end

--[[
	@des 	: 判断登陆领取奖励的条件是否满足
	@param 	:
	@return :
--]]
-- function isCanReceiveRewardOfLog(taskId )
-- 	local isCanRecive = true
-- 	local day = getDayOfLog()
-- 	local typeId = getDataOfFestival_rewardByTaskId(tonumber(taskId)).typeId
-- 	if(tonumber(typeId) == 101)then
-- 		local finish = tonumber(getDataOfFestival_rewardByTaskId(tonumber(taskId)).finish)
-- 		if(finish > day)then
-- 			--如果该条数据大于登陆天数，则视为不能领取
-- 			isCanRecive = false
-- 			end
-- 	end
-- 	return isCanRecive
-- end


--[[
	@des 	: 点击补签后，修改缓存
	@param 	:
	@return :
--]]
function setredtipOfLog( taskId ,seasonNumOfClick)
	local data = _dataOfAll.data[tostring(seasonNumOfClick)]
	local dataInfo = data[tostring(1)]
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(taskId))then
			v[2] = tostring(2)
			break
		end
	end
end


--[[
	@des 	: 领取奖励后，修改本地数据
	@param 	:
	@return :
--]]
function setDataOfAfterReceive( taskId ,seasonNumOfClick)
	local data = _dataOfAll.data[tostring(seasonNumOfClick)]
	local dataInfo = data[tostring(1)]
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(taskId))then
			dataInfo[tostring(k)][2] = tostring(2)
			break
		end
	end
end

function setRedTip( redtipArray )
	
	if(not table.isEmpty(redtipArray) )then
		table.paste( _redTipArray, redtipArray )
	end
end


--[[
	@des 	: 得到兑换的结束时间
	@param 	: 
	@return :
--]]
function getExchangeEndTime( ... )
	local dbData = ActivityConfigUtil.getDataByKey("festivalAct")
	return tonumber(dbData.end_time)
end

--[[
	@des 	: 是否整个活动结束
	@param 	: 
	@return :
--]]
function isAllActiveEnd( ... )
	if tonumber(TimeUtil.getSvrTimeByOffset(0)) >= getExchangeEndTime() then
		return true
	else
		return false
	end
end

--[[
	@des 	: 修改兑换缓存
	@param 	: pNum 增加次数
	@return :
--]]
function addExchangeNum(pTaskId, pNum)
	local dataInfo = _dataOfAll.exchange
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == tonumber(pTaskId))then
			v[1] = tonumber(v[1])+pNum
			break
		end
	end
end


--[[
	@des 	: 得到已经兑换的次数
	@param 	:
	@return :
--]]
function getAlreadyExchangeTimes( pTaskId )
	local retData = 0
	if( not table.isEmpty(_dataOfAll.exchange) )then
		local data = _dataOfAll.exchange[tostring(pTaskId)]
		if(data ~= nil)then
			retData = data[1] or 0
		end
	end 
	return retData
end
