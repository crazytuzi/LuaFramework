-- FileName: EverydayData.lua 
-- Author: Li Cong 
-- Date: 14-3-18 
-- Purpose: function description of module 

module("EverydayData", package.seeall)

require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "db/DB_Daytask"
require "db/DB_Daytask_reward"
require "db/DB_Daytaskopen"

local _totalInfo = nil

-- 设置每日任务数据
function setEverydayInfo( data )
	_totalInfo = data
end

-- 得到每日任务数据
function getEverydayInfo( ... )
	return _totalInfo
end

-- 得到当前积分
function getCurScore( ... )
	local data = getEverydayInfo()
	return tonumber(data.point) or 0
end

-- 得到最大积分 只有三个箱子
function getMaxScore( ... )
	local data = DB_Daytask_reward.getDataById(3)
	return tonumber(data.needScore) or 0
end

-- 得到任务数据
function getTaskInfo( ... )
	local retTab = {}
	local data = getEverydayInfo()
	if(data == nil)then
		return retTab
	end
	-- 得到当前任务id组
	local curTaskIDs = getCurEverydayTaskIds()
	if(curTaskIDs == nil)then
		return retTab
	end

	if(data.va_active.task)then
		for i=1,#curTaskIDs do
			retTab[#retTab+1] = {}
			retTab[#retTab].taskId = curTaskIDs[i]
			retTab[#retTab].dbData = DB_Daytask.getDataById(curTaskIDs[i])
			if(data.va_active.task[tostring(curTaskIDs[i])])then
				retTab[#retTab].curNum = data.va_active.task[tostring(curTaskIDs[i])]
			else
				retTab[#retTab].curNum = 0
			end
		end
	else
		for i=1,#curTaskIDs do
			retTab[#retTab+1] = {}
			retTab[#retTab].taskId = curTaskIDs[i]
			retTab[#retTab].curNum = 0
			retTab[#retTab].dbData = DB_Daytask.getDataById(curTaskIDs[i])
		end
	end
	-- 开服天数
	local openServerTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
	local openDay = math.floor((TimeUtil.getSvrTimeByOffset(0) - openServerTime)/86400)
	-- print("openDay,",openDay)
	-- 过滤可以显示的
    local showTab = {}
    for k,v in pairs(retTab) do
    	local startTime,endTime = getShowTime(v.dbData.id)
    	local curTime = TimeUtil.getSvrTimeByOffset(0)
    	local date = os.date("*t", curTime)
    	local curDay = tonumber(date.wday)-1
    	if( curDay == 0)then
    		curDay = 7
    	end
    	-- print(v.dbData.id,"v.dbData.seropen,",v.dbData.seropen)
    	if( curDay >= tonumber(startTime) and curDay <= tonumber(endTime)
    		and (UserModel.getHeroLevel() >= tonumber(v.dbData.show)) and (openDay >= tonumber(v.dbData.seropen)) )then 
    		table.insert(showTab,v)
    	end
    end

    -- 排序 sortId从大到小
	local function fnSortFun( a, b )
        return tonumber(a.dbData.sortId) < tonumber(b.dbData.sortId)
    end 
    table.sort( showTab, fnSortFun )
  
    -- 已完成的排在最前边
    local arr1 = {}
    local arr2 = {}
    local arr3 = {}
    for k,v in pairs(showTab) do
    	local isHave = isHaveReward( v.dbData.id )
    	if(tonumber(v.curNum) >= tonumber(v.dbData.needNum) and isHave == false)then
    		-- 可领奖
    		table.insert(arr1,v)
    	elseif(isHave)then
    		-- 已完成
    		table.insert(arr3,v)
    	else
    		table.insert(arr2,v)
    	end
    end
    for k,v in pairs(arr2) do
    	table.insert(arr1,v)
    end
    for k,v in pairs(arr3) do
    	table.insert(arr1,v)
    end
	return arr1
end


-- 得到箱子的状态 
-- 1铜  2银  3金
function getBoxStateInfoById( id )
	local retState = 1
	local retNeedScore = 0
	local data = getEverydayInfo()
	if(data == nil)then
		return retState,retNeedScore
	end

	local rewardData,rewardId = getBoxRewardDataByBoxId(id)
	if(rewardData == nil)then
		return retState,retNeedScore
	end

	retNeedScore = tonumber(rewardData.needScore)
	local isGet = isGetThisBoxById( rewardId )
	if(isGet)then
		-- 已领取状态 3
		retState = 3
	else
		local curScore = getCurScore()
		if(curScore >= retNeedScore)then
			-- 可领取状态 2
			retState = 2
		else
			-- 不可领取状态 1
			retState = 1
		end
	end
	return retState,retNeedScore
end


-- 是否已经领取
-- id:奖励id 不是箱子id
function isGetThisBoxById( id )
	local isHave = false
	local data = getEverydayInfo()
	if(data == nil)then
		return isHave
	end
	if(data.va_active.prize)then
		for k,v in pairs(data.va_active.prize) do
			if(tonumber(id) == tonumber(v))then
				isHave = true
				break
			end
		end
	end
	return isHave
end

-- 添加已领取的箱子 
-- id:奖励id
function addGetBoxId( id )
	if(_totalInfo == nil)then
		return
	end
	if(_totalInfo.va_active.prize)then
		local isIn = isGetThisBoxById(id)
		if(isIn == false)then
			table.insert(_totalInfo.va_active.prize,id)
		end
	else
		_totalInfo.va_active.prize = {}
		table.insert(_totalInfo.va_active.prize,id)
	end
end


-- 是否提示红圈
function getIsShowTipSprite( ... )
	local ret = true
	local data = getEverydayInfo()
	if(data == nil)then
		return ret
	end
	if(data.va_active.prize)then
		if(table.count(data.va_active.prize) >= 3)then
			ret = false
		end
	end
	return ret
end


--[[
	@des 	:得到使用每日任务的配置id  
	@param 	:
	@return :num
--]]
function getEverydayUseId()
	return tonumber(_totalInfo.va_active.step)
end

--[[
	@des 	:得到当前任务的id组
	@param 	:
	@return :table
--]]
function getCurEverydayTaskIds()
	local useID = getEverydayUseId()
	local dbData = DB_Daytaskopen.getDataById(useID)
	local retTab = nil
	if(dbData ~= nil)then
		retTab = string.split(dbData.taskid, ",")
	end
	return retTab
end

--[[
	@des 	:得到当前奖励的id组
	@param 	:
	@return :table or nil:没有找到奖励组
--]]
function getCurEverydayRewardIds()
	local useID = getEverydayUseId()
	local dbData = DB_Daytaskopen.getDataById(useID)
	local retTab = nil
	if(dbData ~= nil)then
		retTab = string.split(dbData.rewardid, ",")
	end
	return retTab 
end


--[[
	@des 	:得到箱子的奖励数据 
	@param 	:p_boxId 箱子的id 1 2 3 
	@return :table
--]]
function getBoxRewardDataByBoxId( p_boxId )
	local curRewardIDs = getCurEverydayRewardIds()
	if(curRewardIDs == nil)then
		return nil
	end
	local rewardId = curRewardIDs[p_boxId]
	local retDBdata = DB_Daytask_reward.getDataById(rewardId)
	return retDBdata,rewardId
end


--[[
	@des 	:得到升级需要等级
	@param 	:
	@return :num
--]]
function getEverydayUpgradeNeedLv()
	local useID = getEverydayUseId()
	local dbData = DB_Daytaskopen.getDataById(useID+1)
	local retNum = 0
	if(dbData)then
		retNum = tonumber(dbData.limited_lv)
	end
	return retNum
end


--[[
	@des 	:得到是否需要升级 
	@param 	:
	@return :true or false
--]]
function getEverydayIsNeedUpgrade()
	local useID = getEverydayUseId()
	local dbData = DB_Daytaskopen.getDataById(useID+1)
	local retData = false
	if(dbData)then
		retData = true
	end
	return retData
end



--[[
	@des 	:得到是否能够升级
	@param 	:
	@return :true or false
--]]
function getEverydayIsCanUpgrade()
	local retData = false
	local isNeed = getEverydayIsNeedUpgrade()
	if(isNeed)then
		local needLv = getEverydayUpgradeNeedLv()
		if(needLv)then
			if( UserModel.getHeroLevel() >= needLv )then 
				retData = true
			end
		end
	end
	return retData
end

--[[
	@des 	:是否已领奖
	@param 	:
	@return :true or false
--]]
function isHaveReward( p_taskId )
	local isHave = false
	if(_totalInfo == nil)then
		return isHave
	end
	if( not table.isEmpty(_totalInfo.va_active.taskReward) )then
		for k,v in pairs(_totalInfo.va_active.taskReward) do
			if( tonumber(p_taskId) == tonumber(v) )then
				isHave = true
				break
			end
		end
	end
	return isHave
end


--[[
	@des 	:修改已领奖数据
	@param 	:
	@return :true or false
--]]
function addHaveReward( p_taskId )
	if(_totalInfo == nil)then
		return
	end
	if( not table.isEmpty(_totalInfo.va_active.taskReward) )then
		local isHave = isHaveReward(p_taskId)
		if(isHave == false)then
			table.insert(_totalInfo.va_active.taskReward,p_taskId)
		end
	else
		_totalInfo.va_active.taskReward = {}
		table.insert(_totalInfo.va_active.taskReward,p_taskId)
	end
end

--[[
	@des 	:得到显示完成时间
	@param 	:
	@return :开始时间，结束时间
--]]
function getShowTime( p_taskId )
	require "db/DB_Daytask"
	local dbData = DB_Daytask.getDataById(p_taskId)
	local temTab = string.split(dbData.time,",")
	return temTab[1], temTab[#temTab]
end










