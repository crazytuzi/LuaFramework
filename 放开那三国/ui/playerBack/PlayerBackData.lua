-- FileName: PlayerBackData.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动Data

module("PlayerBackData",package.seeall)
require "script/ui/playerBack/PlayerBackDef"
require "db/DB_Return"
require "db/DB_Return_reward"

--接收getInfo接口内容
local _activityInfo 
--接收getOpen接口内容
local _isOpenData


--获取后端接口返回的内容
function setActivityInfo( pData )
	_activityInfo = pData
end

function getActivityInfo( ... )
	return _activityInfo
end

--获取活动的数据
function getAllInfo( ... )
	return DB_Return.getDataById(1)
end

--获取奖励内容
function getRewardInfo( pId )
	return DB_Return_reward.getDataById(tonumber(pId))
end

--总次数
function allTimes( pId )
	local number = 0
	local data = getRewardInfo(pId)
	if(tonumber(data.type) == PlayerBackDef.kTypeOfTaskTwo )then
		--任务
		number = data.finish
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskThree then
		--单笔充值
		number = data.rechargetimes
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskFour then
		--折扣商品
		number = data.bugtimes
	end
	return number
end

--剩余次数
function remainTimes( pId )
	local data = getRewardInfo(pId)
	local dataInfo = nil
	local remainNum = 0
	local allTimes = allTimes( pId)
	if(tonumber(data.type) == PlayerBackDef.kTypeOfTaskThree)then
		 dataInfo = _activityInfo.recharge
		for k,v in pairs( dataInfo) do
			if(pId == tonumber(k))then
				remainNum = allTimes - (tonumber(v.hadRewardTimes) + tonumber(v.toRewardTimes))
				break
			end
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskFour then
		 dataInfo = _activityInfo.shop
		for k,v in pairs( dataInfo) do
			if(pId == tonumber(k))then
				remainNum = allTimes - tonumber(v) 
				break
			end
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskTwo then
		 dataInfo = _activityInfo.task
		for k,v in pairs( dataInfo) do
			if(pId == tonumber(k))then
				remainNum =  tonumber(v.finishedTimes) 
				break
			end
		end
	end
	return remainNum
end

--按钮状态(0未完成任务，1为未领取，2为已领取)
function getButtonStatues( pId )  
	local statues = 0
	local data = getRewardInfo(pId)
	if(tonumber(data.type) == PlayerBackDef.kTypeOfTaskOne)then
		local dataInfo = _activityInfo.gift
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				statues = tonumber(v)
				break
			end
			
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskTwo then
		local dataInfo = _activityInfo.task
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				statues = tonumber(v.status)
				break
			end
			
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskThree then
		local allNum = allTimes(pId)
		local remainNum = remainTimes(pId)
		local dataInfo = _activityInfo.recharge
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				if(allNum == tonumber(v.hadRewardTimes))then
					--如果总次数与已领奖励次数相等，奖励领取完
					statues = 2
				elseif remainNum ~=0 and tonumber(v.toRewardTimes) == 0 then
					--剩余充值次数不为0而且可以领奖次数为0时，去充值
					statues = 0
				elseif tonumber(v.toRewardTimes) ~= 0 then
					--如果待领奖次数不为0，领取按钮
					statues = 1
				end
				break
			end
			
		end

	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskFour then
		local remainNum = remainTimes(pId)
		if(remainNum == 0)then
			statues = 2
		else
			statues = 1
		end
	end
	return statues
end

--改变按钮状态
function setButtonStatues( pId )
	local data = getRewardInfo(pId)
	if(tonumber(data.type) == PlayerBackDef.kTypeOfTaskOne)then
		local dataInfo = _activityInfo.gift
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				_activityInfo.gift[tostring(pId)] = 2
				break
			end
			
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskTwo then
		local dataInfo = _activityInfo.task
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				_activityInfo.task[tostring(pId)].status = 2
				break
			end
			
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskThree then
		local allNum = allTimes(pId)
		local dataInfo = _activityInfo.recharge
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				_activityInfo.recharge[tostring(pId)].hadRewardTimes = tonumber(v.hadRewardTimes) +1
				_activityInfo.recharge[tostring(pId)].toRewardTimes = tonumber(v.toRewardTimes) - 1
				break
			end
			
		end
	end
end

--购买商品后修改信息
function setInfoOfGoods( pId,pNum )
  	for k,v in pairs(_activityInfo.shop) do
  		if(pId == tonumber(k))then
  			_activityInfo.shop[tostring(k)] = tonumber(v) + pNum
  			break
  		end
  		
  	end
 end 

-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end

--解析价格
function getMoneyCost( pCost )
	return string.split(pCost,"|")
end


--批量兑换里面用到的，获取已经兑换了几次
function getInfoOfGoods(pId )
	local allReadyNum = 0
	local data = _activityInfo.shop
	for k,v in pairs(data) do
		if(pId == tonumber(k))then
			allReadyNum =  v 
			break
		end
		
	end
	return allReadyNum
end

--主界面红点提示
function isRedTip( ... )
	if not isOpen() then
		--活动未开启
		return false
	end

	local data = getAllInfo()
	for i=1,3 do

		local dataExit = PlayerBackData.getActivityInfo()
	    local dataInfoa = dataExit.gift
	    if(i == 2)then
	        dataInfoa = dataExit.task
	    elseif i == 3 then
	         dataInfoa = dataExit.recharge
	    elseif i == 4 then
	        dataInfoa = dataExit.shop
	    end
	    local dataInfo = {}
	    for k,v in pairs(dataInfoa) do
	       table.insert(dataInfo,tonumber(k))
	    end

		-- local dataArray = string.split(data["task_"..i],"|")
		if(isRedTipOfForeThree(dataInfo))then
			return true
		end
	end
	
	if (isRedTipOfLimitBuy())then
		return true
	else
		return false
	end
end


--获取离线天数
function getDayOfLeaf( ... )
	local day = tonumber(_activityInfo.day)
	if(day == 0)then
		day = 1
	end
	return day 
end

--前三个标签红点(都是有可以领取的显示红点提示)
function isRedTipOfForeThree( missionIdTable )
	local isRedTip = false
	-- print("")
	-- print_t(missionIdTable)
	for i=1,#missionIdTable do
		local statue = getButtonStatues(tonumber(missionIdTable[i]))
		if(statue == 1)then
			isRedTip = true
			break
		end	
	end
	return isRedTip
end

--限时折扣红点
function isRedTipOfLimitBuy( ... )
	local isRedTip = not PlayerBackDef.getPlayerBackEnter(1 )
	return isRedTip
end

--剩余时间
function countDownTime( ... )
	local endTime = _isOpenData.endTime
	return TimeUtil.getRemainTime(endTime)
end

function countDownTimestr( ... )
	return _isOpenData.endTime
end
--获取是否开启
function setOpen( pData )
	_isOpenData = pData
end

function getOpen( ... )
	return tonumber(_isOpenData.isOpen)
end
--老玩家回归活动开启条件
function isOpen( ... )
	-- 'open' => 1或0 功能图标是否开启(0未开启 1开启)
	local isOpen = false
	local getIsOpen = getOpen()
	if (getIsOpen == PlayerBackDef.kIsOpen)then
		isOpen = true
	end
	
	return isOpen
end

--判断活动是否结束了
function isPlayerBackOver( ... )
	if tonumber(TimeUtil.getSvrTimeByOffset()) >= tonumber(countDownTimestr()) or tonumber(countDownTimestr()) == 0 then
		return true
	else
		return false
	end
end


--接收后端传送过来的任务Id(任务完成 状态改为1)
function pushTaskId( pId )
	-- print("pId~~~~~~~~~~~~--------",pId)
	local data = getRewardInfo(pId)
	-- print_t(data)
	if tonumber(data.type) == PlayerBackDef.kTypeOfTaskTwo then
		--任务
		local dataInfo = _activityInfo.task
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				_activityInfo.task[tostring(k)].status = 1	
				break
			end
			
		end
	elseif tonumber(data.type) == PlayerBackDef.kTypeOfTaskThree then
		local dataInfo = _activityInfo.recharge
		for k,v in pairs(dataInfo) do
			if(pId == tonumber(k))then
				_activityInfo.recharge[tostring(pId)].toRewardTimes = tonumber(v.toRewardTimes) + 1
				break
			end
			
		end
	end
end