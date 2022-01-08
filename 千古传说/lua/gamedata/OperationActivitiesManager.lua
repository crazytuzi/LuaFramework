-- 运营活动管理器
-- Author: david.dai
-- Date: 2014-09-01 14:37:08
--

local OperationActivitiesManager = class('OperationActivitiesManager')


OperationActivitiesManager.MSG_SYCEE_EXPEND 	  = "OperationActivitiesManager.MSG_SYCEE_EXPEND"	-- 元宝消耗
OperationActivitiesManager.MSG_SYCEE_SUPPLY 	  = "OperationActivitiesManager.MSG_SYCEE_SUPPLY"	-- 元宝充值
OperationActivitiesManager.MSG_ACTIVITY_UPDATE 	  = "OperationActivitiesManager.MSG_ACTIVITY_UPDATE"	-- 
OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD 	 = "OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD"	-- 

function OperationActivitiesManager:ctor()
	--注册网络事件
	TFDirector:addProto(s2c.OPEN_SERVICE_ACTIVITY_STATUS, self, self.acitivityStatusSingleCallback)
	TFDirector:addProto(s2c.OPEN_SERVICE_ACTIVITY_STATUS_LIST, self, self.acitivityStatusListCallback)
	TFDirector:addProto(s2c.OPEN_SERVICE_ACTIVITY_REWARD_RECORD, self, self.activityRewardRecordCallback)
    TFDirector:addProto(s2c.ALL_ACTIVITY_RANK_LIST, self, self.activityRankListForAllCallback)
    TFDirector:addProto(s2c.ACTIVITY_RANK_LIST, self, self.activityRankListForSingleCallback)
    TFDirector:addProto(s2c.GET_ACTIVITY_REWARD_SUCCESS, self, self.getActivityRewardSuccessCallback)


    -- 
    TFDirector:addProto(s2c.ACTIVITY_INFO, self, self.updateActivityInfoEvent)
    TFDirector:addProto(s2c.ACTIVITY_INFO_LIST, self, self.getActivityInfoListEvent)
    -- 领奖回调
    TFDirector:addProto(s2c.GOT_ACTIVITY_REWARD_RESULT, self, self.getActivityRewardResultEvent)
    TFDirector:addProto(s2c.ACTIVITY_PROGRESS_LIST, self, self.getActivityProgressListEvent)
    TFDirector:addProto(s2c.ACTIVITY_PROGRESS, self, self.updateActivityProgressEvent)

    self.value = {} -- 活动对应的progress
    self.ChargeItemList = {} -- 单笔充值
    -- 在线奖励
  	self.OnlineRewardData = {}  
  	self.OnlineRewardData.bOnlineRewardOnTime = false  		-- 倒计时奖励是否可领取
  	self.OnlineRewardData.timeCount = 0 					-- 倒计时
  	self.OnlineRewardData.onlineRewardRemainingTimes = 0 	-- 倒计时
  	self.OnlineRewardData.onlineRewardCount          = 0    -- 已领奖的次数

    self.queryCount = 0
    self.compQueryMark = false

    -- 倒计时奖励是否可领取
    self.bOnlineRewardOnTime = false
    self.timeCount = 0

    -- self:testActivity()
end

--[[
查询活动状态
]]
function OperationActivitiesManager:queryActivityStatus(type,callback)
	local msg = nil
	if not type then
		msg = {0}
	else
		msg = {type}
	end

	if callback then
		self.appLoadingCompleteCallback = callback
	end

	showLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount + 1
	end
	TFDirector:send(c2s.QUERY_OPEN_SERVICE_ACTIVITY_STATUS,msg)
end

--[[
活动状态列表更新网络回调函数
]]
function OperationActivitiesManager:acitivityStatusListCallback(event)
	self.statusList = event.data.statusList
	print("acitivityStatusListCallback : ",self.statusList)
	hideLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount - 1
	end
	self:tryLoadingComplete()
end

--[[
单个活动状态更新网络回调函数
]]
function OperationActivitiesManager:acitivityStatusSingleCallback(event)
	local statusData = event.data
	if self.statusList == nil then
		self.statusList={statusData}
	else
		for _k,_v in pairs(self.statusList) do
			if _v and _v.type and _v.type == type then
				self.statusList[_k] = statusData
				break
				--_v.status = statusData.status
				--_v.startTime = statusData.startTime
				--_v.endTime = statusData.endTime
			end
		end
	end
	--print("acitivityStatusSingleCallback : ",self.statusList)
	hideLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount - 1
	end
	self:tryLoadingComplete()
end

--[[
获取活动状态
]]
function OperationActivitiesManager:getActivityStatus(type)
	if self.statusList == nil then
		return nil
	end

	for _k,_v in pairs(self.statusList) do
		if _v and _v.type and _v.type == type then
			return _v
		end
	end

	return nil
end

--[[
获取活动状态
]]
function OperationActivitiesManager:getActivityStatusAsInteger(type)
	if self.statusList == nil then
		return 1
	end

	for _k,_v in pairs(self.statusList) do
		if _v and _v.type and _v.type == type then
			return _v.status
		end
	end

	return 1
end

--[[
查询活动奖励领取记录
]]
function OperationActivitiesManager:queryActivityRewardRecord(callback)
	if self.rewardRecord then
		self:tryLoadingComplete()
		return
	end
	if callback then
		self.appLoadingCompleteCallback = callback
		--self.queryActivityRewardCompleteCallback = callback -- add by king
	end
	showLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount + 1
	end
	TFDirector:send(c2s.QUERY_OPEN_SERVICE_ACTIVITY_REWARD_RECORD,{})
end

OperationActivitiesManager.ACITIVTY_REWARD_RECORD = "OperationActivitiesManager.ACITIVTY_REWARD_RECORD"

--[[
活动奖励记录网络回调函数
]]
function OperationActivitiesManager:activityRewardRecordCallback(event)

	print("event.data = ", event.data)
	local table = {}
	table.logonDayCount = tonumber(event.data.logonDayCount)
	table.logonReward = tonumber(event.data.logonReward)
	table.onlineRewardCount = tonumber(event.data.onlineRewardCount)
	table.onlineRewardLastGetTime = event.data.onlineRewardLastGetTime
	table.onlineRewardRemainingTimes = tonumber(event.data.onlineRewardRemainingTimes) / 1000
	table.teamLevelReward = tonumber(event.data.teamLevelReward)
	self.rewardRecord = table

	hideLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount - 1
	end
	self:tryLoadingComplete()

	--if self.queryActivityRewardCompleteCallback then
	--	self.queryActivityRewardCompleteCallback(table)
	--	self.queryActivityRewardCompleteCallback = nil
	--end
	--print("activityRewardRecordCallback : ",self.rewardRecord)

	-- 在线倒数
	-- self.timeCount = nil

	self.rewardRecord.onlineRewardRemainingTimes = math.floor(self.rewardRecord.onlineRewardRemainingTimes)
	self.timeCount = self.rewardRecord.onlineRewardRemainingTimes
	-- self.rewardRecord.onlineRewardRemainingTimes = 0
	TFDirector:dispatchGlobalEventWith(OperationActivitiesManager.ACITIVTY_REWARD_RECORD, table)
end

--[[
计算奖励状态
@return 0、可以领取；1、未开始；2、进行中；3、活动已经结束；4、今日已经领取完毕；5、已经领取过；6、尚未能够领取；7、找不到配置数据;8、尚未达到领取条件
]]
function OperationActivitiesManager:calculateRewardState(type,id)
	--print("calculateRewardState : ",type,id)
	local activityStatus = self:getActivityStatus(type)
	if activityStatus.status ~= 2 then
		return activityStatus.status
	end

	if type == EnumActivitiesType.LOGON_REWARD then
		local configure =  LogonReward:objectByID(id)
		if not configure then
			return 7
		end
		if self.rewardRecord.logonDayCount < id then
			return 8
		end

		local offset = id - 1
		local seed = 1
		if offset > 0 then
			seed = bit_lshift(1,offset)
		end
		local alreadyGet = bit_and(self.rewardRecord.logonReward,seed)
		if alreadyGet ~=0 then
			return 5
		end
		return 0
	elseif type == EnumActivitiesType.ONLINE_REWARD then
		-- print("self.rewardRecord.onlineRewardRemainingTimes = ", self.rewardRecord.onlineRewardRemainingTimes)
		-- print("OnlineReward:length() = ", OnlineReward:length())
		-- print("self.rewardRecord.onlineRewardCount = ", self.rewardRecord.onlineRewardCount)
		-- print("id = ", id)
		if self.rewardRecord.onlineRewardCount >= OnlineReward:length() then
			return 4
		end
		local rewardInfo = OnlineReward:objectByID(id)
		if rewardInfo == nil then
			return 7
		end
		local index = OnlineReward:indexOf(rewardInfo) - 1 
		if self.rewardRecord.onlineRewardCount < index then
			return 8
		end
		if self.rewardRecord.onlineRewardCount > index then
			return 5
		end
		if self.rewardRecord.onlineRewardRemainingTimes ~= 0 then
			return 6
		end
		return 0
	elseif type == EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
		local rewardInfo = TeamLevelUpReward:objectByID(id)
		if rewardInfo == nil then
			return 7
		end
		if rewardInfo.team_level > MainPlayer:getLevel() then
			return 8
		end

		local offset = id - 1
		local seed = 1
		if offset > 0 then
			seed = bit_lshift(1,offset)
		end
		local alreadyGet = bit_and(self.rewardRecord.teamLevelReward,seed)
		if alreadyGet ~=0 then
			return 5
		end
		return 0
	end
end

--[[
查询活动排行榜信息
]]
function OperationActivitiesManager:queryActivityRankList(type,callback)
	local msg = nil
	if not type then
		msg = {0}
	else
		msg = {type}
	end

	if callback then
		self.appLoadingCompleteCallback 	= callback
		--self.queryActivityRankListCallback  = callback -- add by king
	end

	showLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount + 1
	end
	TFDirector:send(c2s.QUERY_ACTIVITY_RANK_LIST,msg)
end

--[[
单个活动排行榜网络回调函数
]]
function OperationActivitiesManager:activityRankListForSingleCallback(event)
	local rankList = event.data
	if self.allRankList == nil then
		self.allRankList={rankList}
	else
		for _k,_v in pairs(self.allRankList) do
			if _v and _v.type and _v.type == type then
				self.allRankList[_k] = rankList
				break
			end
		end
	end
	hideLoading()
	if self.compQueryMark then
		self.queryCount = self.queryCount - 1
	end
	self:tryLoadingComplete()
	print("activityRankListForSingleCallback : ",self.allRankList)
end

--[[
所有活动排行榜网络回调函数
]]
function OperationActivitiesManager:activityRankListForAllCallback(event)
	self.allRankList = event.data.rankList

	print("activityRankListForAllCallback : ",self.allRankList)

	hideLoading()

	if self.compQueryMark then
		self.queryCount = self.queryCount - 1
	end
	self:tryLoadingComplete()

	--modify by king 直接回调查询排行榜的回调
	--if self.queryActivityRankListCallback then
	--	self.queryActivityRankListCallback()
	--	self.queryActivityRankListCallback = nil
	--end
end

--[[
获取活动排行榜
]]
function OperationActivitiesManager:getActivityRankList(type)
	if self.allRankList == nil then
		return nil
	end

	for _k,_v in pairs(self.allRankList) do
		if _v and _v.type and _v.type == type then
			return _v
		end
	end

	return nil
end

--[[
打开活动主界面
]]
-- function OperationActivitiesManager:openHomeLayer(callback)
-- 	if callback then
-- 		self.appLoadingCompleteCallback = callback
-- 	else
-- 		self.appLoadingCompleteCallback = function () self:defaultLoadingLayerCloseCallback() end
-- 	end

-- 	self.compQueryMark = true
-- 	showLoading()
-- 	self.queryCount = self.queryCount + 1

-- 	self:queryActivityStatus()
-- 	self:queryActivityRewardRecord()

-- 	hideLoading()
-- 	self.queryCount = self.queryCount - 1
-- 	self:tryLoadingComplete()
-- end

-- 打开排行榜
function OperationActivitiesManager:openleaderBoard(leaderBoardtype)
	local type = EnumActivitiesType.DXCCC
	if leaderBoardtype then
		type = leaderBoardtype
	end 

	--quanhuan change
	--local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.LeaderboardLayer.lua")
	--layer:setIndex(1)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.Leaderboard.lua")
	layer:setIndex(1)
    AlertManager:show();
end

--[[
尝试加载成功
]]
function OperationActivitiesManager:tryLoadingComplete()
	--print("tryLoadingComplete : ",self.queryCount,self.compQueryMark,self.appLoadingCompleteCallback)
	if self.compQueryMark then
		if self.queryCount ~=0 then
			return
		end
		self.compQueryMark = false
	end

	--print("tryLoadingComplete1111111111")
	if self.appLoadingCompleteCallback then
		local callback = self.appLoadingCompleteCallback
		self.appLoadingCompleteCallback = nil
		callback()
	--else
	--	self:defaultLoadingLayerCloseCallback()
	end
end

--[[
默认加载界面关闭回调
]]
function OperationActivitiesManager:defaultLoadingLayerCloseCallback()
	if not self.statusList then
		return
	end
	-- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activity.operation.OpenServiceHomeLayer", AlertManager.BLOCK_AND_GRAY)
 --    layer:select(1)  
 --    AlertManager:show()
end

--[[
领取奖励
]]
function OperationActivitiesManager:getReward(type,rewardId,callback)
	local msg = {type,rewardId}

	if callback then
		self.rewardCallback = callback
	end
	showLoading()
	TFDirector:send(c2s.GET_ACTIVITY_REWARD,msg)
end

OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS = "OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS"

--[[
领取奖励网络回调函数
]]
function OperationActivitiesManager:getActivityRewardSuccessCallback(event)
	hideLoading()
	if self.rewardCallback then
		local callback = self.rewardCallback
		self.rewardCallback = nil
		callback()
	end
	TFDirector:dispatchGlobalEventWith(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,event.data)
end

--[[
获取活动状态 true 开启  false 关闭
]]
function OperationActivitiesManager:checkActivityIsOpen(type)
	local ActivityStatus = self:getActivityStatus(type)

	if ActivityStatus == nil then
		return false
	end

    local startTime = getTimeByDate(ActivityStatus.startTime)
    local endTime 	= getTimeByDate(ActivityStatus.endTime)
    local nowTime = MainPlayer:getNowtime()
    print("type = ", type)
    print("startTime = ", startTime)
    print("endTime	 = ", endTime)
    print("nowTime	 = ", nowTime)

    -- local date 		= os.date("*t", nowTime)
    -- print("date0 = ", date)


    -- local startTimedate 		= os.date("*t", startTime)
    -- print("date1 = ", startTimedate)

    -- local endTimedate 		= os.date("*t", endTime)
    -- print("date2 = ", endTimedate)

    --活动进行中
    if nowTime > startTime and nowTime < endTime then
    	return true
    end
    
    -- 活动未开启 ，未开始， 已结束
    return false
end


function OperationActivitiesManager:parseTime(timeString)
	--endTime="2014-10-02 09:00:00",
	local timeData  = string.split(timeString, " ")
    local date 		= timeData[1]
    local time 		= timeData[2]

    local dateArray = string.split(date, "-")
    local timeArray = string.split(time, ":")

    local month = dateArray[2]
    local day 	= dateArray[3] 
    local hour 	= timeArray[1] 
    local min 	= timeArray[2]

    --local desc 	= month.."月"..day.."日"..hour..":"..min
    local desc = stringUtils.format(localizable.common_time_6, month, day, hour, min)

    return desc
end


-- 时间转换
function OperationActivitiesManager:TimeConvertString(time)
	if time <= 0 then
		return "00:00:00"
	end

	local hour = math.floor(time/3600)
	local min  = math.floor((time-hour * 3600)/60)
	local sec  = math.mod(time, 60)
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

-- 是否领取了所有的在线奖励
function  OperationActivitiesManager:isGetAllOnlineReward()
	if self.rewardRecord.onlineRewardCount >= OnlineReward:length() then
		return true
	end

	return false
end

-- 领取在线奖励
function  OperationActivitiesManager:getOnlineReward()
	if self.rewardRecord.onlineRewardCount >= OnlineReward:length() then
		--toastMessage("今日在线奖励已领完")
		toastMessage(localizable.GameActivitiesManager_online_yiwan)
		return
	-- elseif self.bOnlineRewardOnTime == false then
	elseif not self.timeCount or self.timeCount > 0 then
		--toastMessage("倒计时未到") --..self.timeCount
		toastMessage(localizable.GameActivitiesManager_online_shijianweidao)
		return
	end

	local OnlineRewardId = self.rewardRecord.onlineRewardCount + 1
	print("OnlineRewardId = ", OnlineRewardId)
	self:getReward(EnumActivitiesType.ONLINE_REWARD, OnlineRewardId, nil)

end

-- 倒计时奖励是否可领取
function OperationActivitiesManager:onlineRewardOnTime()
	return self.bOnlineRewardOnTime
end


-- 设置在线奖励回调
function OperationActivitiesManager:setOnlineRewardTimer(logic, id, callback)
	-- 在线奖励功能关闭
	if QiyuManager:ActivityFuctionOnlineReward() == false then
		self:stopAllOnlineRewardTimer()
		return
	end

	-- 判断在线奖励是否过期
	local ActivityIsOpen = self:checkActivityIsOpen(EnumActivitiesType.ONLINE_REWARD)
	if ActivityIsOpen == false then
		self:stopAllOnlineRewardTimer()
		return
	end

	if self.rewardRecord.onlineRewardCount >= OnlineReward:length() then
		-- toastMessage("今日在线奖励已领完")
		self:stopAllOnlineRewardTimer()
		return
	end

	if self.onlineRewardCallBackList == nil then
		self.onlineRewardCallBackList = TFMapArray:new()
		self.onlineRewardCallBackList:clear()
	end

	if  self.onlineRewardTimerId == nil then
		print("---- start timer")
		self.onlineRewardTimerId = TFDirector:addTimer(1000, -1, nil, 
			function() 
				self:OnlineRewardUpdate()
			end)
	end

	local obj = self.onlineRewardCallBackList:objectByID(id)
	-- print("self.onlineRewardCallBackList = ", self.onlineRewardCallBackList)
	
	if obj then
		obj.handler 			= callback
		obj.logic				= logic
		-- self.onlineRewardCallBackList:push(obj)
		print("---- 1 setOnlineRewardTimer = ".."id = "..id)
	else
		local timer = {}

		timer.id 				= id
		timer.logic 			= logic
		timer.handler 			= callback
		self.onlineRewardCallBackList:push(timer)
		print("---- 2 setOnlineRewardTimer = ".."id = "..id)
	end
end

-- 停止在线奖励定时器
function OperationActivitiesManager:stopOnlineRewardTimer(id)
	print("OperationActivitiesManager:stopOnlineRewardTimer-------------")

	if self.onlineRewardCallBackList == nil then
		return
	end
	print("self.onlineRewardCallBackList:length()1 = ", self.onlineRewardCallBackList:length())
	local obj = self.onlineRewardCallBackList:objectByID(id)
	if obj then
		print("removeObject = ", obj)
		-- self.onlineRewardCallBackList:removeObject(obj)
		self.onlineRewardCallBackList:removeInMapList(obj)

	end

	if self.onlineRewardCallBackList:length() <= 0 and self.onlineRewardTimerId then
		-- me.Director:getScheduler():unscheduleScriptEntry(self.onlineRewardTimerId)
		-- self.onlineRewardTimerId = nil
		print("------------------stop all timer")
		self:stopAllOnlineRewardTimer()
	end

	print("self.onlineRewardCallBackList:length()2 = ", self.onlineRewardCallBackList:length())
end

-- 
function OperationActivitiesManager:OnlineRewardUpdate()

	if self.onlineRewardCallBackList == nil or self.rewardRecord == nil then
		return
	end

	self.timeCount = self.timeCount - 1
	if self.timeCount < 0 then
		self.timeCount = 0
	end

	local timedesc = self:TimeConvertString(self.timeCount)

	-- 倒计时奖励可领
	if self.timeCount <= 0 then
		self.bOnlineRewardOnTime = true
		self.rewardRecord.onlineRewardRemainingTimes = 0
	end

	-- local ActivityIsOpen = self:checkActivityIsOpen(EnumActivitiesType.ONLINE_REWARD)

	--今日奖励已领完
	if self.rewardRecord.onlineRewardCount >= OnlineReward:length() then
		self.bOnlineRewardOnTime = false
		-- 停掉在线奖励定时器
		self:stopAllOnlineRewardTimer()
	end

	for v in self.onlineRewardCallBackList:iterator() do
		-- print("---v = ", v)
		v.desc 		= timedesc
		v.timeCount	= self.timeCount
		v.bPrize	= self.bOnlineRewardOnTime  --当前的在线奖励是否可领
		if v.handler then
			v.handler(v)
		end
	end
end

-- 停掉在线奖励
function OperationActivitiesManager:stopAllOnlineRewardTimer()

	-- 清空倒计时奖励
	if self.onlineRewardCallBackList then
		self.onlineRewardCallBackList:clear()
	end


	if self.onlineRewardTimerId then
		-- me.Director:getScheduler():unscheduleScriptEntry(self.onlineRewardTimerId)
		TFDirector:removeTimer(self.onlineRewardTimerId)
		self.onlineRewardTimerId = nil
	end

end

-- 重新清除数据
function OperationActivitiesManager:reset()
	-- self:stopResetTimer()
end

-- 重新清除数据
function OperationActivitiesManager:restart()

	print("------------OperationActivitiesManager:restart ----")

    -- 倒计时奖励是否可领取
    self.bOnlineRewardOnTime = false

	-- 老倒计时
	self:stopAllOnlineRewardTimer()

	-- 新倒计时
	self:stopTimerAndRemoveListener()


	-- 重置活动
	self.ActivityList = nil

	self.activityData = {}
	    -- 在线奖励
  	self.OnlineRewardData = {}  
  	self.OnlineRewardData.bOnlineRewardOnTime = false  		-- 倒计时奖励是否可领取
  	self.OnlineRewardData.timeCount = 0 					-- 倒计时
  	self.OnlineRewardData.onlineRewardRemainingTimes = 0 	-- 倒计时
  	self.OnlineRewardData.onlineRewardCount          = 0    -- 已领奖的次数


    self:startResetTimer()

end

-- function OperationActivitiesManager:isHaveRewardCanGet()
-- 	local typeList = {
-- 		EnumActivitiesType.LOGON_REWARD,
-- 		EnumActivitiesType.ONLINE_REWARD,
-- 		EnumActivitiesType.TEAM_LEVEL_UP_REWARD
-- 	}

-- 	for i=1,3 do
-- 		local Rewardtype = typeList[i]

-- 		for index=1,10 do
-- 			local isReward = self:calculateRewardState(Rewardtype,index)

-- 			if isReward ~= nil and isReward == 0 then
-- 				return true
-- 			end
-- 		end
-- 	end
	
-- 	return false
-- end



function OperationActivitiesManager:isHaveRewardCanGetByType(_type)
	if _type ~= EnumActivitiesType.LOGON_REWARD and _type ~= EnumActivitiesType.ONLINE_REWARD and _type ~= EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
		return false
	end
	for index=1,10 do
		local isReward = self:calculateRewardState(_type,index)
		if isReward ~= nil and isReward == 0 then
			return true
		end
	end
	return false
end

 -- 初始化其中一个运营活动项
function OperationActivitiesManager:intitActivityRewardData(activityInfo)
		
	 -- ├┄┄icon="",
	 -- ├┄┄id=1,
	 -- ├┄┄status=2,
	 -- ├┄┄history=false,
	 -- ├┄┄endTime="",
	 -- ├┄┄resetType=0,
	 -- ├┄┄title="登录奖励",
	 -- ├┄┄beginTime="",
	 -- ├┄┄type=1,
	 -- ├┄┄details="登录奖励活动",
	 -- ├┄┄name="登录奖励",
	 -- ├┄┄reward="1|1,1,100&1,2,100&1,3,100|1;2|1,3,100&1,3,100&1,3,100|1;3|1,3,100&1,3,100|1;4|1,3,100&1,3,100|1;5|1,3,100&1,3,100|1"

	
	-- if activityInfo.id == EnumActivitiesType.ONLINE_REWARD_NEW then
	-- if activityInfo.id == EnumActivitiesType.DANBICHONGZHI then
	-- -- if 1 then
	-- 	-- print("activityInfo = ", activityInfo)
	-- end

	local activityType 	= activityInfo.id
	local startTime 	= activityInfo.beginTime
	local endTime 		= activityInfo.endTime
	local details   	= activityInfo.details   	--"版权声明：本文为博主原创文章，未经博主允许不得转载。"
	local status   		= activityInfo.status 			-- or 1 --0关闭 1开启, 2 到时关闭
	-- local reward_details = "200|1,1,100&1,2,100&1,3,100|1;400|1,3,100&1,3,100&1,3,100|3;700|1,3,100&1,3,100|0;1000|1,3,100&1,3,100|0;15000|1,3,100&1,3,100|0"
	local reward_details = activityInfo.reward

	local resetCron 	= activityInfo.resetCron

	-- print("解析活动 activityType = ", activityType)

	-- 是否为自动重置
	local autoReset = false
	if resetCron ~= nil and resetCron ~= "" then
		autoReset = true
	end

	-- if autoReset then
	-- 	__G__TRACKBACK__("12314")
	-- end
	
	if startTime == "" then
		startTime = nil
	else
		startTime = getTimeByDate(startTime)
	end

	if endTime == "" then
		endTime = nil
	else
		endTime = getTimeByDate(endTime)
	end

	-- 
		-- local nextTime 	= getTimeByDate(date)

	-- resType,resId,resNum
	-- value:resType,resId,resNum|
	-- 200|1,1,100&1,2,100&1,3,100|0
	if self.activityData == nil then
		self.activityData = {} 
	end

	-- if self.activityData[activityType] == nil then
		self.activityData[activityType] = {}
		self.activityData[activityType].rewardList = MEMapArray:new()
	-- end

		-- 赌场
	if reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.DUCHANG then

		local activityList = MEArray:new()
		local temptbl = string.split(reward_details,';')
		for k,v in pairs(temptbl) do
			local activity 		= string.split(v,'|')
			local inputNum 		= tonumber(activity[1])
			local inputType 	= tonumber(activity[3])


			local activityRewardData = {
				Num 	 = inputNum,
				resType  = inputType
			}

			self.activityData[activityType].rewardList:pushbyid(inputNum,activityRewardData)
		end
	
	-- 兑换EXCHANGE
	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.EXCHANGE then
		-- print("11111111111reward_details = ", reward_details)
		-- 2,2,1&3,0,200000|1,2000,30&3,0,100000|10|1
		-- 2,2,1 & 3,0,200000| --兑换的东西 & 隔开 可多换N
		-- 1,2000,30&3,0,100000| 。。。。
		-- 10  兑换的次数
		-- |1  折扣 （0不打折 1-八折 2--）
		local temptbl = string.split(reward_details,';')
		local count = 1
		for k,v in pairs(temptbl) do
			local goodsInfo 		= string.split(v,'|')
			local inputGoodsList 	= goodsInfo[1]
			local outGoodsList    	= goodsInfo[2]
			local totalChangeTime 	= tonumber(goodsInfo[3])
			local discount_ 	 	= tonumber(goodsInfo[4])

			local exchangeData =
			{
				id 			= count,
				status 		= totalChangeTime,
				input   	= inputGoodsList,
				out     	= outGoodsList,
				discount    = discount_,
				changeTime 	= 0;
			}
			self.activityData[activityType].rewardList:pushbyid(count, exchangeData)
			count = count + 1
		end
		-- print("self.activityData[activityType].rewardList = ", self.activityData[activityType].rewardList)
		-- da = a + 1
		-- 兑换EXCHANGE
	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.HAPPY_TOGETHER then

	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.PAY_FOR_REDBAG then
		
	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.TEN_CARD then

	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id == EnumActivitiesType.V8_PRIZE then

		
	elseif reward_details ~= nil and reward_details ~= "" and activityInfo.id ~= EnumActivitiesType.DUCHANG then
		local activityList = MEArray:new()
		local temptbl = string.split(reward_details,';')
		for k,v in pairs(temptbl) do
			local activity 		= string.split(v,'|')
			local rewardid 		= tonumber(activity[1])
			local rewardStatus 	= tonumber(activity[3])
			local tempRewardtbl = string.split(activity[2],'&')

			local maxTimeRange = 0
			-- 单笔充值 状态默认为0
			if activityType == EnumActivitiesType.DANBICHONGZHI then
				maxTimeRange = rewardStatus
				rewardStatus = 0
			end


			-- -- 服务器下发的是已领奖的次数   客户端转化一下 0 已领 1 未领
			-- if rewardStatus > 0 then
			-- 	rewardStatus = 0
			-- else
			-- 	rewardStatus = 1
			-- end

			local rewardList = MEArray:new()
			for k2,v2 in pairs(tempRewardtbl) do

				local reward = string.split(v2,',')

				-- print("reward =", reward)
				if reward then
					local commonReward = {}
					commonReward.type 	= tonumber(reward[1])
					commonReward.itemId = tonumber(reward[2])
					commonReward.number = tonumber(reward[3])
					rewardList:push(BaseDataManager:getReward(commonReward))
				end
			end

			local activityRewardData = {
				id 			= rewardid,
				status 		= rewardStatus,
				reward  	= rewardList,
				maxtime		= maxTimeRange, --限制最大的领取次数
				gottime		= 0, 			--当前领取的次数
				nowPayTimes = 0 			--当前档次的充值记录 只用于单笔充值
			}

			self.activityData[activityType].rewardList:pushbyid(rewardid,activityRewardData)
		end



	end

	
	-- 重置时间
	self.activityData[activityType].resetSec  = 0
	self.activityData[activityType].autoReset = autoReset

	self.activityData[activityType].startTime = startTime
	self.activityData[activityType].endTime   = endTime
	self.activityData[activityType].details   = details
	self.activityData[activityType].status    = status
	-- print("self.activityData[activityId] = ", self.activityData[activityType])
end


-- 获取获取活动中， 指定一个奖项的奖品
function OperationActivitiesManager:getActivityRewardData(activityType, rewardId)


	if self.activityData and self.activityData[activityType] then
		return self.activityData[activityType].rewardList:objectByID(rewardId) --.reward
	end
	
	return  MEArray:new()
end

--[[
计算奖励状态
@return 0、可以领取；1、未开始；2、进行中；3、活动已经结束；4、今日已经领取完毕；5、已经领取过；6、尚未能够领取；7、找不到配置数据;8、尚未达到领取条件
]]
function OperationActivitiesManager:getActivityRewardStatus(activityType, rewardId)

	local activity = self:getActivityData(activityType)

	if activity and rewardId then

		if activityType == EnumActivitiesType.ONLINE_REWARD_NEW then
			if self.OnlineRewardData.onlineRewardCount >= self:getOnlineRewardCount() then
				return 4
			end

			local rewardInfo = activity.rewardList:objectByID(rewardId)
			if rewardInfo == nil then
				return 7
			end

			local index = activity.rewardList:indexOf(rewardInfo) - 1 
			if self.OnlineRewardData.onlineRewardCount < index then
				return 8
			end
			if self.OnlineRewardData.onlineRewardCount > index then
				return 5
			end
			if self.OnlineRewardData.onlineRewardRemainingTimes ~= 0 then
				return 6
			end
			return 0
		end

		local nowTime = MainPlayer:getNowtime()

		if activity.startTime and nowTime < activity.startTime then
			-- print("111")
			return 1

		-- 过期了
		elseif activity.endTime and nowTime > activity.endTime then
			-- print("2222")
			-- 活动虽结束 但是领取了
			local rewardStatus = activity.rewardList:objectByID(rewardId).status 
			if  rewardStatus == 0 then
				if  activityType == EnumActivitiesType.DANBICHONGZHI then
					return 8
				else
					return 5
				end
			end

			return 3
		end

		local rewardStatus = activity.rewardList:objectByID(rewardId).status 

		-- 单笔充值
		if  activityType == EnumActivitiesType.DANBICHONGZHI then

			-- 判断是否到达最大的次数
			local danbiData = activity.rewardList:objectByID(rewardId)
			if danbiData ~= nil then
				if  danbiData.gottime >= danbiData.maxtime then
					return 8
				end
			end

			if  rewardStatus == 0 then
				return 8
			else 
				return 0
			end
		end

		-- 领奖次数为0
		if  rewardStatus == 0 then
			return 5
		end

		-- 领奖次数>0   然后判断其他条件
		local canBeGot = self:getRewardCondition(activityType, rewardId)
		if canBeGot then
			return 0
		else
			return 8
		end
	end


	return 8
end


-- 获取活动里面的奖品列表
function OperationActivitiesManager:getActivityRewardList(activityType)

	-- print("self.activityData = ", self.activityData)
	if self.activityData and self.activityData[activityType] then
		return self.activityData[activityType].rewardList
	end
	
	
	return  MEArray:new()
end

-- 获取活动具体数据
function OperationActivitiesManager:getActivityData(activityType)

	if self.activityData and self.activityData[activityType] then
		return self.activityData[activityType]
	end
	
	return  nil
end

-- 领奖, 和网络交互
function OperationActivitiesManager:onclickActivityReward(activityType, rewardId)

	return 0
end

-- 获取奖项的达到条件
function OperationActivitiesManager:getRewardCondition(activityType, rewardId)
	local reward 	= self.activityData[activityType].rewardList:objectByID(rewardId)

	-- print(reward.id  .. " ----------- ".. self.value[activityType])
	if self.value[activityType] == nil then
		self.value[activityType] = 0
	end

	if reward.id <= self.value[activityType] then
		return true
	end

	return false
end

	-- LEIJICHONGZHI			= 11,			--累计充值
	-- DANGRICHONGZHI			= 12,			--当日充值
	-- DANBICHONGZHI			= 13,			--单笔充值
	-- LEIJIXIAOFEI				= 14,			--累计消费
	-- DANGRIXIAOFEI			= 15,			--当日消费
	-- LIANXUDENGLU				= 16,			--连续登陆
function OperationActivitiesManager:getRewardItemDesc(activityType)
	local desc1 = ""
	local desc2 = ""
	local path  = "ui_new/operatingactivities/new/"

	-- LEIJICHONGZHI				= ,			--累计充值
	-- 累冲好礼
	if activityType == EnumActivitiesType.LEIJICHONGZHI then
    	desc1  = "累计充值"
    	desc2  = "元宝"
    	path   = path .. "lchl.png"

    -- 充值回馈
    elseif activityType == EnumActivitiesType.DANBICHONGZHI then
    	desc1  = "单笔充值"
    	desc2  = "元宝"
    	path   = path .. "czfk.png"


    -- 当日充值
    elseif activityType == EnumActivitiesType.DANGRICHONGZHI then
    	desc1  = "当日充值"
    	desc2  = "元宝"
    	path   = path .. "mrhl.png"


	-- LEIJIXIAOFEI				= ,			--累计消费
    -- 消费返礼
   	elseif activityType == EnumActivitiesType.LEIJIXIAOFEI then
    	desc1  = "累计消费"
    	desc2  = "元宝"
    	path   = path .. "xffl.png"


	-- LIANXUDENGLU				= ,			--连续登陆
    -- 连续登陆
   	elseif activityType == EnumActivitiesType.LIANXUDENGLU then
    	desc1  = "连续天数"
    	desc2  = ""
    	path   = path .. "lxdl.png"

    elseif activityType == EnumActivitiesType.QIRIDENGLU then
    	desc1  = "第"
    	desc2  = "天"
    	path   = "ui_new/operatingactivities/yy_0011.png"


	-- DANGRIXIAOFEI				= ,			--当日消费
   	elseif activityType == EnumActivitiesType.DANGRIXIAOFEI then
    	desc1  = "单日累计"
    	desc2  = "元宝"
    	path   = path .. "xffl.png"

	-- DANGRICHONGZHI				= ,			--当日充值
    -- 每日回礼
   	elseif activityType == EnumActivitiesType.DANGRICHONGZHI then
    	desc1  = "当日充值"
    	desc2  = "元宝"
    	path   = path .. "ygdc.png"

    elseif activityType == EnumActivitiesType.TUANDUIDENGJI then
    	desc1  = "等级达到"
    	desc2  = ""
    	path   = "ui_new/operatingactivities/yy_0061.png"

    elseif activityType == EnumActivitiesType.ONLINE_REWARD_NEW then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "zxjl.png"
    	

    	-- ZHAOBUG						= 20,			--找bug
    elseif activityType == EnumActivitiesType.ZHAOBUG then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "zhaobug.png"
    	

    	-- YAOHAOYOU					= 21			--邀请好友
    elseif activityType == EnumActivitiesType.YAOHAOYOU then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "yaohaoyou.png"
    	
    elseif activityType == EnumActivitiesType.DUCHANG then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "ygdc.png"
    	
    
    elseif activityType == EnumActivitiesType.TEN_CARD then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "slc.png"

    elseif activityType == EnumActivitiesType.HAPPY_TOGETHER then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "pttqqhb.png"


    elseif activityType == EnumActivitiesType.PAY_FOR_REDBAG then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "czfhl.png"


    elseif activityType == EnumActivitiesType.EXCHANGE then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "yy_00104.png"

    elseif activityType ==  EnumActivitiesType.V8_PRIZE then
    	desc1  = ""
    	desc2  = ""
    	-- path   = "ui_new/operatingactivities/yy_0051.png"
    	path   = path .. "czdhk.png"
	end

	return desc1, desc2, path
end

-- 运营活动是否开启, 控制显示的 true为开启  反之则
function OperationActivitiesManager:ActivitgIsOpen(activityType)
	
	if activityType <= 10 then
		return true
	end
 

	local open = false
	local activity = self:getActivityData(activityType)

	if activity then
		local status  = activity.status


		open = true

		-- 活动强制关闭
		if status == 0 then
			return false

		elseif status == 2 then
			local nowTime = MainPlayer:getNowtime()
			-- 判断时间是否结束
			-- print("----------activityType-----------", activityType)
			-- print("nowTime = ", nowTime)
			-- print("activity.endTime = ", activity.endTime)
			-- 活动已结束
			if activity.endTime and nowTime > activity.endTime then
				-- print("---------close-----------")
				return false

			-- 活动尚未开启
			elseif activity.startTime and nowTime < activity.startTime then
				return false
			end

				-- print("---------open-----------")
		end

		-- status == 1 自动检测

	end

	return open
end

--更新一个奖励项
function OperationActivitiesManager:UpdateActityDanbiChongzhiRewaerd(sycee)
	local activityType = EnumActivitiesType.DANBICHONGZHI

	if self.activityData and self.activityData[activityType] then
		local reward = self.activityData[activityType].rewardList:objectByID(sycee) --.reward
		if reward then
			-- nowPayTimes
			if reward.nowPayTimes >= reward.maxtime then
				print("================"..sycee.."档单笔充值已达到最大限制:"..reward.maxtime)
				return
			end
			reward.nowPayTimes = reward.nowPayTimes + 1

			reward.status = reward.status or 0
			reward.status = reward.status + 1
		end
	end

end

--更新一个奖励项
function OperationActivitiesManager:UpdateActityRewaerd(activityType, index)

	print("更新奖励 activityType = "..activityType.."            index = ", index)

	if self.activityData and self.activityData[activityType] then
		local reward = self.activityData[activityType].rewardList:getObjectAt(index) --.reward

		if reward.status > 0 then
			reward.status 	= reward.status - 1

			print("更新成功")
		end
	end

end

-- 获取是否过期 false 为 没有过期
function OperationActivitiesManager:ActivityIsExpired(type)
	local Expired = true

	local activity = self:getActivityData(activityType)

	if activity then
		Expired = false

		local nowTime = MainPlayer:getNowtime()

		if activity.startTime and nowTime < activity.startTime then
			Expired = true

		-- 过期了
		elseif activity.endTime and nowTime > activity.endTime then
			Expired = true
		end
	end

	return false
end

-- 消耗了多少元宝
function OperationActivitiesManager:SysceeExpend(num)
	print("-------------消耗了"..num.."元宝------------")

	print("self.value = ",self.value)

	--如果某个操作跳过元宝消耗累计
	if self.skipSyceeExpendMark then
		return
	end

	local typeTotalCost = EnumActivitiesType.LEIJIXIAOFEI
	-- 累计消耗
	if not self:ActivityIsExpired(typeTotalCost) then
		self.value[typeTotalCost] = self.value[typeTotalCost] or 0
		self.value[typeTotalCost] = self.value[typeTotalCost] + num
	end


	local typeDailyCost = EnumActivitiesType.DANGRIXIAOFEI
	-- 单日消耗
	if not self:ActivityIsExpired(typeDailyCost) then

		if self.DailyCostDate == nil then
			self.DailyCostDate = MainPlayer:getNowtime()
		end

		local nowTime = MainPlayer:getNowtime()

		local secInOneDay 	= 24 * 3600
		local dayNow 		= math.floor(nowTime/secInOneDay)
    	local dayLast 		= math.floor(self.DailyCostDate/secInOneDay)

    	-- 当天直接累加
    	if dayLast == dayNow then
    		self.value[typeDailyCost] = self.value[typeDailyCost] or 0
			self.value[typeDailyCost] = self.value[typeDailyCost] + num

		-- 不是同一天则从新开始 
		else
			self.DailyCostDate = nowTime
			self.value[typeDailyCost] = num
		end
	end

end

-- 具体每个奖项对应的值 ，如累计充值的铜币，消耗的总铜币等
function OperationActivitiesManager:getActivityVaule(type)
	if self.value and self.value[type] then
		return self.value[type]
	end

	return 0
end

-- 充值元宝
function OperationActivitiesManager:SysceeSupply(rechargeId, rechargeItem)


	print("--------------一笔新充值，充值id = "..rechargeId)
	local sycee = rechargeItem.sycee

	if sycee == 0 then
		sycee = rechargeItem.price * 10
	end

	print("--------- 元宝数 = " .. sycee .. "-----------------")
	
	-- 单笔充值
	local typeDanbiCharge = EnumActivitiesType.DANBICHONGZHI
	if not self:ActivityIsExpired(typeDanbiCharge) then
		-- self.ChargeItemList[sycee] = self.ChargeItemList[sycee] or 0
		-- self.ChargeItemList[sycee] = self.ChargeItemList[sycee] + 1

		self:UpdateActityDanbiChongzhiRewaerd(sycee)

	end


	local typeTotalCharge = EnumActivitiesType.LEIJICHONGZHI
	-- 累计充值
	if not self:ActivityIsExpired(typeTotalCharge) then
		self.value[typeTotalCharge] = self.value[typeTotalCharge] or 0
		self.value[typeTotalCharge] = self.value[typeTotalCharge] + sycee
	end


	local typeDailyCharge = EnumActivitiesType.DANGRICHONGZHI
	-- 单日充值
	if not self:ActivityIsExpired(typeDailyCharge) then

		if self.DailyChargeDate == nil then
			self.DailyChargeDate = MainPlayer:getNowtime()
		end

		local nowTime = MainPlayer:getNowtime()

		local secInOneDay 	= 24 * 3600
		local dayNow 		= math.floor(nowTime/secInOneDay)
    	local dayLast 		= math.floor(self.DailyChargeDate/secInOneDay)


		self.value[typeDailyCharge] = self.value[typeDailyCharge] or 0

    	-- 当天直接累加
    	if dayLast == dayNow then
			self.value[typeDailyCharge] = self.value[typeDailyCharge] + sycee

		-- 不是同一天则从新开始 
		else
			self.DailyChargeDate = nowTime
			self.value[typeDailyCharge] = sycee
		end
	end
end


function OperationActivitiesManager:levelChanged(level)
	
	local typeEnum = EnumActivitiesType.TUANDUIDENGJI
	
	if not self:ActivityIsExpired(typeEnum) then
		self.value[typeEnum] = level
	end
end

function OperationActivitiesManager:updateActivityInfoEvent(event)
	-- required int32 id = 1;				//活动ID
	-- required string name = 2;			//名称
	-- required string title = 3;			//标题
	-- required int32 type	= 4; 			//活动类型:0、未知；1、登录；2、连续登录；3、在线奖励，持续在线时长；4、VIP等级；5、团队等级；6、累计充值金额；7、单笔充值金额；8、累计消耗，针对元宝
	-- required string resetCron = 5;		//重置表达式，CronExpression表达
	-- required int32 status = 6;			//活动状态：0、活动强制无效，不显示该活动；；1、长期显示该活动 2、自动检测，过期则不显示
	-- required bool history = 7;			//是否把历史记录也有效，默认无效。如果设置为true，那么历史记录会马上更新活动状态，例如：充值累计
	-- required string icon = 8;			//活动图标
	-- required string details = 9;		//活动详情，客户端支持的符文本格式表达式
	-- required string reward = 10;		//奖励表达式，直接数据格式，根据不同的活动类型表达式可能不一样。如：200|1,1,100&1,2,100&1,3,100|1;400|1,3,100&1,3,100&1,3,100|3
	-- optional string beginTime = 11;		//开始日期，没有期限设置为null
	-- optional string endTime = 12;		//结束日期，没有期限设置为null
	if event.data then

		self:intitActivityRewardData(event.data)

		local bIsHaveBefore = false
		for i,v in pairs(self.ActivityList) do
			if event.data.id == v then
				bIsHaveBefore = true
			end
		end

		if bIsHaveBefore == false then
			table.insert(self.ActivityList, event.data.id)
		end


		TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE, {})
	end
end

function OperationActivitiesManager:getActivityInfoListEvent(event)

	-- print("------- OperationActivitiesManager:getActivityInfoList -------")

	print("event.data = ", event.data)

	if event.data == nil or event.data.info == nil then
		return
	end

	if self.ActivityList == nil then
		self.ActivityList = {}
	end

	for i,v in pairs(event.data.info) do

		-- if (v.id >= 11 and v.id <= 22) or v.id == 26 or v.id == EnumActivitiesType.TEN_CARD or v.id == EnumActivitiesType.HAPPY_TOGETHER then
		if (v.id >= 11 and v.id <= 26) or v.id == EnumActivitiesType.V8_PRIZE then
			self:intitActivityRewardData(v)

			table.insert(self.ActivityList, v.id)

			-- if v.id == EnumActivitiesType.ONLINE_REWARD_NEW then
			-- 	print("=============================v = ", v)
			-- end
		end
		-- self.ActivityList.insert(v.id)
	end


	-- __G__TRACKBACK__("12314")
end


function OperationActivitiesManager:getActivityRewardResultEvent(event)
	local data = event.data

	hideLoading()

	-- if data then
	local id 	= data.id					--活动ID

	--银钩坊（小宝赌场）不计算元宝消耗逻辑添加
	if id == EnumActivitiesType.DUCHANG then
		self.skipSyceeExpendMark = false
	end

	local index = data.index			--奖励索引，从1开始，第几个奖励

	
	local activityType = id

	if id == EnumActivitiesType.ONLINE_REWARD_NEW then
		local onlineRewardIndex = self.OnlineRewardData.onlineRewardCount + 1
		local reward 	= self.activityData[activityType].rewardList:getObjectAt(onlineRewardIndex + 1)

		self.OnlineRewardData.onlineRewardCount          = onlineRewardIndex

		if reward then
			local onlineRewardRemainingTimes = reward.id

		  	self.OnlineRewardData.timeCount 				 = onlineRewardRemainingTimes or 0 		-- 倒计时
		  	self.OnlineRewardData.onlineRewardRemainingTimes = onlineRewardRemainingTimes or 0  	-- 倒计时
		  	-- self.OnlineRewardData.onlineRewardCount          = onlineRewardIndex or 0    			-- 已领奖的次数
		end


	elseif id == EnumActivitiesType.DUCHANG then
		local rewardIndex = self.value[activityType] or 0
		self.value[activityType] = rewardIndex + 1

	elseif id == EnumActivitiesType.EXCHANGE then
		local reward = self.activityData[id].rewardList:getObjectAt(index) --.reward

		
		reward.changeTime 	= reward.changeTime + 1

	elseif id == EnumActivitiesType.DANBICHONGZHI then
		local reward = self.activityData[activityType].rewardList:getObjectAt(index) 
		
		reward.gottime = reward.gottime + 1
		if reward.status > 0 then
			reward.status 	= reward.status - 1
		end
	else
		self:UpdateActityRewaerd(id, index)
	end



	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_GET_REWARD, {})
end

function OperationActivitiesManager:updateOneActivityProgress(v)
	-- required int32 id = 1;			//活动ID
		-- required int32 progress = 2;		//进度
		-- required string extend = 3;		//进度扩展字段，单笔充值等复杂的进度记录
		-- required string got =4 ;			//已经领取的奖励表达式,与reward对应。 表示领取的次数 。如：1,0,1,2,0
		-- required string lastUpdate = 5;	//最后更新时间

		if v == nil then
			return
		end

		local activityType 	= v.id
		local progress 		= v.progress
		local extend 		= v.extend
		local got 			= v.got

		local resetRemaining = v.resetRemaining

		if (v.id >= 11 and v.id <= 22) or v.id  == EnumActivitiesType.EXCHANGE then

			self.value[activityType] = v.progress


			if self.activityData and self.activityData[activityType] then
				local activityInfo = self.activityData[activityType]

				local rewardNum = 0
				local gottbl = string.split(got,',')
				local gotList = {}


				-- 重置时间
				-- activityInfo.resetSec = 

				for k1, v1 in pairs(gottbl) do
					rewardNum = rewardNum + 1

					gotList[rewardNum] = tonumber(v1)
				end


				-- 单笔充值
				if activityType == EnumActivitiesType.DANBICHONGZHI then
					local extendtbl = string.split(extend,'|')
					
					-- extend="30,1|60,2"
					-- 转换成剩余的
					local index = 0
					for k2, v2 in pairs(extendtbl) do

						local chargeInfo = string.split(v2,',')

						local id 	= tonumber(chargeInfo[1])
						local num 	= tonumber(chargeInfo[2])

						-- index = index + 1

						local reward 	= self.activityData[activityType].rewardList:objectByID(id) 
						-- local sycee     = reward.id
						if reward then

							if num > reward.maxtime then
								num = reward.maxtime
							end

							index = self.activityData[activityType].rewardList:indexOf(reward)
							gotList[index] = gotList[index] or 0
							reward.status  = num - gotList[index]

							-- add by king 20151022
							-- reward.maxtime = maxTimeRange --限制最大的领取次数
							reward.gottime 		= gotList[index] --当前领取的次数
							reward.nowPayTimes  = num --当前档次充值的次数
						end
						-- 记录当前的单笔充值次数
						-- self.ChargeItemList[sycee] = reward.status
					end

				elseif activityType == EnumActivitiesType.ONLINE_REWARD_NEW then

					self.value[activityType] = v.progress --/ 1000

					local extendtbl = string.split(extend, ',')
					local onlineRewardIndex 			= tonumber(extendtbl[1]) or 0 --领到了第几个
					-- local onlineRewardRemainingTimes 	= tonumber(extendtbl[2]) --剩余时间

					-- 记录当前领取次数
					self.OnlineRewardData.onlineRewardCount          = onlineRewardIndex or 0 

					local reward 	= self.activityData[activityType].rewardList:getObjectAt(onlineRewardIndex + 1)
					if reward then
						local onlineRewardRemainingTimes = reward.id - self.value[activityType]

						if onlineRewardRemainingTimes < 0 then
							onlineRewardRemainingTimes = 0
						end

					  	self.OnlineRewardData.timeCount 				 = onlineRewardRemainingTimes or 0 		-- 倒计时
					  	self.OnlineRewardData.onlineRewardRemainingTimes = onlineRewardRemainingTimes or 0  	-- 倒计时
					  	self.OnlineRewardData.onlineRewardCount          = onlineRewardIndex or 0    			-- 已领奖的次数
					end
					-- print("self.reward = ", reward)
					-- print("self.OnlineRewardData = ", self.OnlineRewardData)

				elseif activityType == EnumActivitiesType.DUCHANG then
					local extendtbl = string.split(extend, ',')
					local index = tonumber(extendtbl[1]) or 0 --领到了第几个
					self.value[activityType] = index

				elseif activityType == EnumActivitiesType.EXCHANGE then
					for i=1, rewardNum do

						gotList[i] = gotList[i] or 0

						local reward 	= self.activityData[activityType].rewardList:getObjectAt(i)
						if reward then 
							reward.changeTime  = gotList[i]
							-- if reward.status < 1 then
							-- 	reward.status = 0
							-- end
						end
					end

				else
					for i=1, rewardNum do

						gotList[i] = gotList[i] or 0

						local reward 	= self.activityData[activityType].rewardList:getObjectAt(i)
						if reward then 
							if gotList[i] >= 1 then
								reward.status = 0
							else
								reward.status = 1
							end
						end
					end
				end

			end
		end
end

function OperationActivitiesManager:updateActivityProgressEvent(event)
	if event.data == nil then
		return
	end

	self:updateOneActivityProgress(event.data)

	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE, {})
end

function OperationActivitiesManager:getActivityProgressListEvent(event)

	if event.data == nil or event.data.progress == nil then
		return
	end


	-- print("---------- OperationActivitiesManager:getActivityProgressList-------")
	-- print("---------- event.data.progress -------", event.data.progress)


	for i,v in pairs(event.data.progress) do
		self:updateOneActivityProgress(v)
	end

	-- print("self.activityData[activityType].rewardList = ", self.activityData)
	TFDirector:dispatchGlobalEventWith(self.MSG_ACTIVITY_UPDATE, {})
end

function OperationActivitiesManager:sendMsgToGetActivityReward(activityType, rewardIndex,skipSyceeExpend)
	showLoading()
	if skipSyceeExpend then
		self.skipSyceeExpendMark = true
	end
	TFDirector:send(c2s.GOT_ACTIVITY_REWARD, {activityType, rewardIndex})
end

-- 所有的奖励都被领完了
function  OperationActivitiesManager:AllOnlineRewardIsReceived()
	local AllOnlineRewardNum = self:getOnlineRewardCount()

	-- print("AllOnlineRewardNum 						= ", AllOnlineRewardNum)
	-- print("self.OnlineRewardData.onlineRewardCount  = ", self.OnlineRewardData.onlineRewardCount)

	if self.OnlineRewardData.onlineRewardCount >= AllOnlineRewardNum then
		return true
	end

	return false
end

-- 领取在线奖励
function  OperationActivitiesManager:requestReceiveOnlineReward()
	if self.OnlineRewardData.onlineRewardCount >= self:getOnlineRewardCount() then
		--toastMessage("今日在线奖励已领完")
		toastMessage(localizable.GameActivitiesManager_online_yiwan)
		return
	

	elseif not self.OnlineRewardData.timeCount or self.OnlineRewardData.timeCount > 0 then
		--toastMessage("倒计时未到") --..self.OnlineRewardData.timeCount
		toastMessage(localizable.GameActivitiesManager_online_shijianweidao)
		return
	end

	local OnlineRewardId = self.OnlineRewardData.onlineRewardCount + 1
	
	self:sendMsgToGetActivityReward(EnumActivitiesType.ONLINE_REWARD_NEW, OnlineRewardId)
end


-- 设置在线奖励回调
function OperationActivitiesManager:addOnlineRewardListener(logic, id, callback)


	-- 在线奖励功能关闭
	local ActivityIsOpen = self:ActivitgIsOpen(EnumActivitiesType.ONLINE_REWARD_NEW)
	if ActivityIsOpen == false then
		print("在线奖励功能关闭")
		self:stopTimerAndRemoveListener()
		return
	end

	-- 判断在线奖励是否过期
	if OperationActivitiesManager:ActivityIsExpired(EnumActivitiesType.ONLINE_REWARD_NEW) == true then
		print("在线奖励是否过期")
		self:stopTimerAndRemoveListener()
		return
	end

	-- print("self.OnlineRewardData.onlineRewardCount = ", self.OnlineRewardData.onlineRewardCount)
	-- print("self:getOnlineRewardCount() = ", self:getOnlineRewardCount())
	if self.OnlineRewardData.onlineRewardCount >= self:getOnlineRewardCount() then
		-- toastMessage("今日在线奖励已领完")
		self:stopTimerAndRemoveListener()
		return
	end

	if self.onlineRewardPrizeListener == nil then
		self.onlineRewardPrizeListener = TFMapArray:new()
		self.onlineRewardPrizeListener:clear()
	end

	if  self.OnlineRewardData.onlineRewardTimer == nil then
		
		self.OnlineRewardData.onlineRewardTimer = TFDirector:addTimer(1000, -1, nil, 
			function() 
				self:onlineRewardTimerUpdate()
			end)
	end

	local obj = self.onlineRewardPrizeListener:objectByID(id)
	
	if obj then
		obj.handler 			= callback
		obj.logic				= logic
		-- self.onlineRewardPrizeListener:push(obj)
		print("---- 1 addOnlineRewardListener add = ".."id = "..id)
	else
		local timer = {}

		timer.id 				= id
		timer.logic 			= logic
		timer.handler 			= callback
		self.onlineRewardPrizeListener:push(timer)
		print("---- 2 addOnlineRewardListener modify = ".."id = "..id)
	end
end

-- 停止在线奖励定时器
function OperationActivitiesManager:removeOnlineRewardTimer(id)
	if self.onlineRewardPrizeListener == nil then
		return
	end

	local obj = self.onlineRewardPrizeListener:objectByID(id)
	if obj then
		self.onlineRewardPrizeListener:removeInMapList(obj)
	end

	if self.onlineRewardPrizeListener:length() <= 0 and self.OnlineRewardData.onlineRewardTimer then

		self:stopTimerAndRemoveListener()
	end
end

-- 
function OperationActivitiesManager:onlineRewardTimerUpdate()

	-- print("---------OperationActivitiesManager:onlineRewardTimerUpdate-------------")
	if self.onlineRewardPrizeListener == nil or self.OnlineRewardData == nil then
		return
	end

	self.OnlineRewardData.timeCount = self.OnlineRewardData.timeCount - 1
	if self.OnlineRewardData.timeCount < 0 then
		self.OnlineRewardData.timeCount = 0
	end

	local timedesc = self:TimeConvertString(self.OnlineRewardData.timeCount)

	-- 倒计时奖励可领
	if self.OnlineRewardData.timeCount <= 0 then
		self.bOnlineRewardOnTime = true
		self.OnlineRewardData.onlineRewardRemainingTimes = 0
	end

	--今日奖励已领完
	if self.OnlineRewardData.onlineRewardCount >= self:getOnlineRewardCount() then
		self.bOnlineRewardOnTime = false
		-- 停掉在线奖励定时器
		self:stopTimerAndRemoveListener()
	end

	for v in self.onlineRewardPrizeListener:iterator() do
		-- print("---v = ", v)
		v.desc 		= timedesc
		v.timeCount	= self.OnlineRewardData.timeCount
		v.bPrize	= self.bOnlineRewardOnTime  --当前的在线奖励是否可领
		if v.handler then
			v.handler(v)
		end
	end
end

-- 停掉在线奖励
function OperationActivitiesManager:stopTimerAndRemoveListener()
	if self.OnlineRewardData.onlineRewardTimer then
		TFDirector:removeTimer(self.OnlineRewardData.onlineRewardTimer)
		self.OnlineRewardData.onlineRewardTimer = nil
	end

			-- 清空倒计时奖励
	if self.onlineRewardPrizeListener then
		self.onlineRewardPrizeListener:clear()
	end
	
end

-- 在线奖励相关
function OperationActivitiesManager:getOnlineRewardCount()

	local rewardList        = self:getActivityRewardList(EnumActivitiesType.ONLINE_REWARD_NEW)

	-- print("EnumActivitiesType.ONLINE_REWARD_NEW = ", EnumActivitiesType.ONLINE_REWARD_NEW)
	return rewardList:length()
end



function OperationActivitiesManager:isHaveRewardCanGetByType_New(_type)
	if _type == EnumActivitiesType.ZHAOBUG or _type == EnumActivitiesType.YAOHAOYOU then
		return false
	end

	-- 活动未开启 
	local bOpen = self:ActivitgIsOpen(_type)
	if bOpen == false then
		return false
	end

	local rewardList    = self:getActivityRewardList(_type)
	local rewardCount 	= rewardList:length()

    for i=1,rewardCount do
    	local rewardData = rewardList:objectAt(i)

        local status = self:getActivityRewardStatus(_type, rewardData.id )

        if status ~= nil and status == 0 then
        	print("tyep = ".._type.."  红点开启")
        	return true
        end
    end

	return false
end

function OperationActivitiesManager:isHaveRewardCanGet()
	-- local typeList = {
	-- 	EnumActivitiesType.LOGON_REWARD,
	-- 	EnumActivitiesType.ONLINE_REWARD,
	-- 	EnumActivitiesType.TEAM_LEVEL_UP_REWARD
	-- }

	-- print("self.ActivityList ", self.ActivityList)

	if self.ActivityList == nil then
		return false
	end

	local num = #self.ActivityList
	for i=1, num do
		local Rewardtype = self.ActivityList[i]
		-- print("Rewardtype = ", Rewardtype)
		if self:isHaveRewardCanGetByType_New(Rewardtype) == true then
			return true
		end
	end
	return false
end


function OperationActivitiesManager:openHomeLayer()


	print("-------------OperationActivitiesManager:openHomeLayer---------------")
	if self.ActivityList == nil then
		--toastMessage("还没有开启的活动")
		toastMessage(localizable.GameActivitiesManager_not_open_activity)
		return
	end

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.activity.operation.OpenServiceHomeLayer", AlertManager.BLOCK_AND_GRAY)
    print("-------------OperationActivitiesManager:openHomeLayer1111---------------")
    layer:select(1)
    print("-------------OperationActivitiesManager:openHomeLayer222---------------")
    AlertManager:show()

end

function OperationActivitiesManager:startResetTimer()

	-- if  self.resetTimer == nil then
	-- 	-- 20s 检测一次
	-- 	self.resetTimer = TFDirector:addTimer(1000 * 10, -1, nil, 
	-- 		function() 
	-- 			local nowTime 	= MainPlayer:getNowtime()
	-- 			local loginTime = MainPlayer:getLogintime()


	-- 			local day1 = os.date("%d", nowTime)
	-- 			local day2 = os.date("%d", loginTime)


	-- 			print("nowTime = " .. nowTime .. "         , loginTime = " .. loginTime)
	-- 			print("day1 = " .. day1 .. "         , day2 = " .. day2)

	-- 			if day1 ~= day2 then
	-- 				self:restart()
	-- 				MainPlayer:setLogintime(nowTime)
	-- 				TFDirector:send(c2s.REQUEST_ALL_ACTIVITY_INFO, {})
	-- 			end

	-- 			-- self:restart()
	-- 			-- TFDirector:send(c2s.REQUEST_ALL_ACTIVITY_INFO, {})

	-- 		end)
	-- end

end

function OperationActivitiesManager:stopResetTimer()
	-- -- 
	-- if  self.resetTimer then
	-- 	TFDirector:removeTimer(self.resetTimer)
	-- 	self.resetTimer = nil
	-- end
end



function OperationActivitiesManager:getActivityList()
	return self.ActivityList
end

-- 2,2,1&3,0,200000|1,2000,30&3,0,100000|10|1
-- 2,2,1 & 3,0,200000| --兑换的东西 & 隔开 可多换N
-- 1,2000,30&3,0,100000| 。。。。
-- 10  兑换的次数
-- |1  折扣 （0不打折 1-八折 2--）
return OperationActivitiesManager:new()
