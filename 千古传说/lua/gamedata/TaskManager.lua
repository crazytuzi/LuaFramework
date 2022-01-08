--
-- Author: Zippo
-- Date: 2014-01-08 18:28:29
--

local TaskManager = class("TaskManager")

function TaskManager:ctor()
	self:RegisterEvents()
	self.taskList = TFArray:new()
	self:restart()
end

function TaskManager:restart()
	self.taskList:clear()
end

function TaskManager:RegisterEvents()
	TFDirector:addProto(s2c.TASK_LIST, self, self.TaskListMsgHandle)
	TFDirector:addProto(s2c.GET_TASK_REWARD_RESULT, self, self.GetTaskRewardMsgHandle)
	TFDirector:addProto(s2c.NOTIFY_TASK_FINISH, self, self.NotifyTaskFinishMsgHandle)
	TFDirector:addProto(s2c.NOTIFY_NEW_TASK, self, self.NotifyNewTaskMsgHandle)
	TFDirector:addProto(s2c.NOTIFY_TASK_STEP, self, self.NotifyTaskStepMsgHandle)
end

function cmp( task1,task2 )
	if task1.state > task2.state then
		return true
	elseif task1.state < task2.state then
		return false
	end
	if task1.show_weight < task2.show_weight then
		return true
	end
	return false
end

function TaskManager:TaskListMsgHandle(event)
	hideAllLoading()
	self.taskList:clear()
	local taskNum = #event.data.tasklist
	for i=1,taskNum do
		self:AddTask(event.data.tasklist[i])
	end
	self:sort()
	if self.showTaskType ~= nil then
		local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.task.TaskLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
		layer:loadData(self.showTaskType)
		layer.name = "lua.logic.task.TaskLayer"
		AlertManager:show()
		self.showTaskType = nil
	end
end


function TaskManager:GetTaskRewardMsgHandle(event)
	hideAllLoading()
	if event.data.taskid == nil then
		return
	end

	for i=1,#event.data.taskid do
		self:RemoveTask(event.data.taskid[i])
	end
	self:RefreshTaskLayer()
end

 function TaskManager:NotifyNewTaskMsgHandle(event)
 	for i=1,#event.data.tasklist do
		self:AddTask(event.data.tasklist[i])
	end
	-- self:sort()
	self:RefreshTaskLayer()
 end

function TaskManager:RemoveTask(taskID)
	for v in self.taskList:iterator() do
		if v and v.taskid == taskID then
			self.taskList:removeObject(v)
			return
		end
	end
	-- self:sort()
end

function TaskManager:AddTask(taskInfo)
	local taskData = TaskData:objectByID(taskInfo.taskid)
	if taskData == nil then
		print("配置表没有此任务 taskid = ",taskInfo.taskid)
		return
	end
	for v in self.taskList:iterator() do
		if v and v.taskid == taskInfo.taskid then
			v = taskInfo
			v.show_weight = taskData.show_weight
			return
		end
	end
	taskInfo.show_weight = taskData.show_weight
	self.taskList:push(taskInfo)
end

function TaskManager:GetTaskNum(taskType)
	local num = 0
	local level = MainPlayer:getLevel()
	for v in self.taskList:iterator() do
		if v then
			local taskData = TaskData:objectByID(v.taskid)
			if nil ~= taskData then
				if taskType == taskData.category and level >= taskData.show_level then
					num = num + 1
				end
			end
		end
	end
	return num
end

function TaskManager:HaveFinishTask()
	for v in self.taskList:iterator() do
		if v and v.state == 1 then
			return true
		end
	end
	return false
end

function TaskManager:GetFirstDailyTask()
	local minTaskID = 100000000
	local teamLev = MainPlayer:getLevel()
	local firstTaskData = nil
	for v in self.taskList:iterator() do
		if v and v.state == 0 and v.taskid < minTaskID then
			local taskData = TaskData:objectByID(v.taskid)
			if taskData ~= nil and taskData.category == 0 and teamLev >= taskData.show_level then
				minTaskID = v.taskid
				firstTaskData = taskData
			end
		end
	end
	return firstTaskData
end

function TaskManager:GetTaskInfo(taskType, taskIndex)
	local currIndex = 1
	local level = MainPlayer:getLevel()
	for v in self.taskList:iterator() do
		if v then
			local taskData = TaskData:objectByID(v.taskid)
			if nil ~= taskData then
				if taskType == taskData.category and level >= taskData.show_level then
					if currIndex == taskIndex then
						return v
					else
						currIndex = currIndex + 1
					end
				end
			end
		end
	end
	return nil
end

function TaskManager:RefreshTaskState(taskid, state)
	for v in self.taskList:iterator() do
		if v and v.taskid == taskid then
			v.state = state
			break
		end
	end
end

function TaskManager:RefreshTaskStep(taskid, step)
	for v in self.taskList:iterator() do
		if v and v.taskid == taskid then
			v.currstep = step
			break
		end
	end
end

function TaskManager:NotifyTaskFinishMsgHandle(event)
	local taskData = TaskData:objectByID(event.data.taskid)
    if taskData ~= nil then
    	self:RefreshTaskState(event.data.taskid, 1)
        -- local text = "已完成:"..taskData.name..",可领取奖励"
        local text = stringUtils.format(localizable.TaskManager_com_task, taskData.name)
		TFDirector:addTimer(2000, 1, nil,
		function()
			toastMessage(text)
		end)
    end
    -- self:sort()
    self:RefreshTaskLayer()
end

function TaskManager:NotifyTaskStepMsgHandle(event)
    self:RefreshTaskStep(event.data.taskid, event.data.currstep)
    self:RefreshTaskLayer()
end

function TaskManager:ShowTaskLayer(taskType)
	showLoading()
	TFDirector:send(c2s.QUERY_TASK, {})
	self.showTaskType = taskType
end

function TaskManager:sort()
	if self.taskList and self.taskList:length() > 1 then
		self.taskList:sort(cmp)
	end
end

function TaskManager:RefreshTaskLayer()
	print("TaskManager:RefreshTaskLayer() : ")
	local taskLayer = AlertManager:getLayerByName("lua.logic.task.TaskLayer")
	if taskLayer ~= nil then
		-- self:sort()
		taskLayer:RefreshUI()
	end
end

function TaskManager:CanGoToLayer(taskData, showLayer)
	if taskData == nil then
		return false
	end

	local taskType = taskData.type
	print("taskType = ", taskType)

    if taskType == 103 or taskType == 105 or taskType == 120 or taskType == 201  or taskType == 901 then
        if showLayer then
            MissionManager:showHomeLayer()
        end
    elseif taskType == 106 or taskType == 108 or taskType == 126 or taskType == 705 then
        if showLayer then
        	local teamLev = MainPlayer:getLevel()
			local openLev = 15
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			if taskType == 126 then
				MissionManager:showHomeToIndexLayer(taskData.target_value)
			else
				MissionManager:showHomeLayer(MissionManager.DIFFICULTY1)
			end
        end
    elseif taskType >= 115 and taskType <= 117 then
        if showLayer then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(401)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			ActivityManager:showLayer(ActivityManager.TAP_Climb)
            -- ClimbManager:showMountainLayer()
        end
    elseif taskType >= 118 and taskType <= 119 then
        if showLayer then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(301)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			ActivityManager:showLayer(ActivityManager.TAP_Arena)
            -- ArenaManager:showArenaLayer()
        end
     elseif taskType == 123 then
		if showLayer then
			--摩诃崖
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(601)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			ActivityManager:showLayer(ActivityManager.TAP_Carbon)
            -- ClimbManager:showCarbonListLayer()
        end
    elseif taskType == 209 or (taskType >= 401 and taskType <= 419) then
		if showLayer then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(101)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			EquipmentManager:OpenSmithyMainLaye()
		end
    elseif taskType >= 501 and taskType <= 515 then
		if showLayer then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(104)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
			EquipmentManager:OpenSmithyMainLaye()
		end
    elseif taskType == 203 or taskType == 240 or taskType == 311 then
        if showLayer then
            CardRoleManager:openRoleList()
        end
    elseif taskType == 314 then
        if showLayer then
            -- QiyuManager:OpenHomeLayer(4)
            local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(904)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
            QiyuManager:OpenHomeLayer(4)
        end
    elseif taskType == 315 then
        if showLayer then
            -- QiyuManager:OpenHomeLayer(3)
            local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(903)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
            QiyuManager:OpenHomeLayer(3)
        end
    elseif taskType == 316 then
        if showLayer then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(901)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
            QiyuManager:OpenHomeLayer(1)
        end
    elseif taskType == 306 or taskType == 805 then
        if showLayer then
            MallManager:openRecruitLayer()
        end
    elseif taskType == 213 or taskType == 319 then
        if showLayer then
        	local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(106)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
            MallManager:openMallLayer(2)
        end
    elseif taskType == 301 then --开宝箱
        if showLayer then
			local box = BagManager:getBox()
			if box then
				local bagLayer = BagManager:ShowBagLayer()
				bagLayer:select(box)
			else
				local teamLev = MainPlayer:getLevel()
				local openLev = FunctionOpenConfigure:getOpenLevel(106)
				if teamLev < openLev then
					-- toastMessage("商城购买需团队等级达到"..openLev.."级开启")
					toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
					return false
				end
				MallManager:openMallLayer(3)
            end
        end
    elseif taskType == 317 then
        if showLayer then
           VipRuleManager:showBuyReplyLayer(EnumRecoverableResType.PUSH_MAP)
        end
    elseif taskType == 318 then
        if showLayer then
           -- CommonManager:showBuyCoinComfirmLayer()
           CommonManager:showBuyCoinLayer()
        end
    elseif taskType == 241 or taskType == 242 or (taskType >= 600 and taskType <= 615) or (taskType >= 902 and taskType <= 909) or taskType == 920 or (taskType >= 930 and taskType <= 935) then  --经脉培养
        if showLayer then
        	local funId = 0
			if taskType == 241 then
				funId = 202
			elseif taskType == 242 or (taskType >= 930 and taskType <= 935) then
				funId = 201
			end
			if funId ~= 0 then
				local teamLev = MainPlayer:getLevel()
				local openLev = FunctionOpenConfigure:getOpenLevel(funId)
				if teamLev < openLev then
					-- toastMessage("团队等级达到"..openLev.."级开启")
					toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
					return false
				end
			end
			if taskType == 602 then
				PlayerGuideManager:setSpecialGuideId( 1000 )
			end
			CardRoleManager:openRoleInfoByIndex(1)
        end
    elseif taskType == 313 then
        if showLayer then
           --QiyuManager:EntryMonthCard()
           MonthCardManager:openMonthCardLayer()
        end

    -- 充值
    elseif taskType == 1000 then
    	if showLayer then
        	PayManager:showPayHomeLayer()
    	end
    elseif taskType == 1001 then
    	if showLayer then
        	PayManager:showPayLayer(nil,nil,true)
    	end
    --七日
	elseif taskType == 1002 then
		SevenDaysManager:enterSevenDaysLayer()
    -- 武学
    elseif taskType == 920 then
    	if showLayer then
			CardRoleManager:openRoleInfoByIndex(1)
		end

	-- 装备 、 技能 、经脉  装备上镶嵌  or 1700  1750 ~ 1753
	elseif taskType == 1100 or taskType == 1300 or (taskType >= 1320 and taskType <= 1326) or (taskType >= 1750 and taskType <= 1753) or taskType == 1700 or (taskType >= 2100 and taskType <= 2130) then
		if showLayer then
		    local funId = 0

			if taskType == 1100 then
				funId = 800

			elseif taskType == 1300 or (taskType >= 1320 and taskType <= 1326) then
				funId = 202
				
			elseif (taskType >= 1750 and taskType <= 1753) or taskType == 1700 then
				funId = 203

			end

			if funId ~= 0 then
				local teamLev = MainPlayer:getLevel()
				local openLev = FunctionOpenConfigure:getOpenLevel(funId)
				if teamLev < openLev then
					-- toastMessage("团队等级达到"..openLev.."级开启")
					toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
					return false
				end
			end
			CardRoleManager:openRoleInfoByIndex(1)
		end

	-- 装备精炼 装备升星
	elseif taskType == 1751 or taskType == 208 or taskType == 1500 or (taskType >= 1520 and taskType <= 1523) or (taskType >= 1150 and taskType <= 1154) then
		if showLayer then
			local funId = 0

			if taskType == 1751 or taskType == 208 then
				funId = 103
			elseif (taskType >= 1150 and taskType <= 1154) then
				funId = 101
			elseif taskType == 1500 or (taskType >= 1520 and taskType <= 1523) then
				funId = 102

			end

			if funId ~= 0 then
				local teamLev = MainPlayer:getLevel()
				local openLev = FunctionOpenConfigure:getOpenLevel(funId)
				if teamLev < openLev then
					-- toastMessage("团队等级达到"..openLev.."级开启")
					toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
					return false
				end
			end
			EquipmentManager:OpenSmithyMainLaye()
		end


--  taskType == 501

	--摩诃崖 
	elseif (taskType >= 1601 and taskType <= 1609) or (taskType >= 1611 and taskType <= 1613) or (taskType >= 1621 and taskType <= 1623) then
		local funId = 601

		if funId ~= 0 then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(funId)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
		end
        ActivityManager:showLayer(ActivityManager.TAP_Carbon)

	-- 雁门关
	elseif taskType == 1400  or (taskType >= 521 and taskType <= 525) then		
		local funId = 501
		if funId ~= 0 then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(funId)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
		end
        ActivityManager:showLayer(ActivityManager.TAP_EverQuest)

	-- 无量山
	elseif taskType == 117 then		
		local funId = 401
		if funId ~= 0 then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(funId)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
		end
        ActivityManager:showLayer(ActivityManager.TAP_Climb)
	-- 无量山
	elseif taskType == 2000 then
		if showLayer then
			local needLevelIndex = ConstantData:getValue("North.Cave.Open.Floor");

		    if ClimbManager:getClimbFloorNum() < needLevelIndex then
		        -- local str = TFLanguageManager:getString(ErrorCodeData.BEIKU_OPEN_NOT_ENOUGH_LEVEL)
		        -- str = string.format(str,needLevelIndex)
		        local str = stringUtils.format(localizable.BEIKU_OPEN_NOT_ENOUGH_LEVEL, needLevelIndex)
		        toastMessage(str)
		        return false;
		    end
	        ActivityManager:showLayer(ActivityManager.TAP_Climb)
	    end
	-- 群豪
	elseif taskType == 1200 then		
		local funId = 301
		if funId ~= 0 then
			local teamLev = MainPlayer:getLevel()
			local openLev = FunctionOpenConfigure:getOpenLevel(funId)
			if teamLev < openLev then
				-- toastMessage("团队等级达到"..openLev.."级开启")
				toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
				return false
			end
		end
        ActivityManager:showLayer(ActivityManager.TAP_Arena)

	-- 宗师
	elseif taskType == 108 then
		MissionManager:showHomeLayer(MissionManager.DIFFICULTY2)
	elseif taskType == 1800 or taskType == 1801 then
		if showLayer then
			FriendManager:openFriendMainLayer()
		end
	elseif taskType == 1900 or taskType == 1902 or (taskType >= 1904 and taskType <= 1910) then
		if showLayer then
			if FactionManager:isJoinFaction() then
				FactionManager:openZhongYiLayer()
			else
				--toastMessage("请大侠尽快加入帮派体验更多内容")
				toastMessage(localizable.TaskManager_ask_join_fation)
			end
		end
	elseif taskType == 1903 then
		if showLayer then
			FactionManager:openFactionFromHomeIcon()
		end
	elseif taskType == 1901 then
		if showLayer then
			if FactionManager:isJoinFaction() then
				FactionManager:openFactinoMemberLayer()
			else
				-- toastMessage("请大侠尽快加入帮派体验更多内容")
				toastMessage(localizable.TaskManager_ask_join_fation)
			end
		end
	elseif taskType == 1911 or taskType == 1912 then
		if showLayer then
			if FactionManager:isJoinFaction() then
				FactionManager:openFactionHomeLayer()
			else
				-- toastMessage("请大侠尽快加入帮派体验更多内容")
				toastMessage(localizable.TaskManager_ask_join_fation)
			end
		end
	elseif (taskType >= 10001 and taskType <= 10006) then
		if showLayer then
			if FactionManager:isJoinFaction() then
				FactionManager:openFactionHomeLayer()
			else
				-- toastMessage("请大侠尽快加入帮派体验更多内容")
				toastMessage(localizable.TaskManager_ask_join_fation)
			end
		end
	elseif taskType == 1802 then
		if showLayer then
			-- AssistFightManager:openAssistWithType(LineUpType.LineUp_Main) 
			AssistFightManager:gotoFriendAssistForTask(LineUpType.LineUp_Main)
		end
	elseif taskType >= 1010 and taskType <= 1013 then
		if showLayer then
			MonthCardManager:openMonthCardLayer()
		end
	elseif taskType == 4000 or taskType == 4004 then
		if showLayer then
			ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_2, true)
		end
	elseif taskType >= 4001 and taskType <= 4003 then
		if showLayer then
			AdventureManager:openHomeLayer()
		end
	elseif taskType == 4005 or taskType == 4006 then
		if showLayer then
			AdventureManager:openAdventureMallLayer()
		end

	elseif taskType == 4007 then
		if showLayer then
			BagManager:ShowBagLayerByButtonIndex(4)  
		end
	elseif taskType == 4008 then
		if showLayer then
			AdventureManager:openHomeLayer()
		end
    else
        return false
    end 

    return true
end

--红点判断逻辑
--是否该任务已完成
function TaskManager:isCanGetReward(taskid)
	for v in self.taskList:iterator() do
		if v and v.taskid == taskid then
			return v.state == 1
		end
	end
	return false
end

--是否有该类型任务已完成
function TaskManager:isCanGetRewardForType(index)
	for v in self.taskList:iterator() do
		if v then
			local taskData = TaskData:objectByID(v.taskid)
			if nil ~= taskData then
				if index == taskData.category then
					if v.state == 1 then
						return true
					end
				end
			end
		end
	end
	return false
end

--是否有任务已完成
function TaskManager:isHaveCanGetReward()
	for v in self.taskList:iterator() do
		if v then
			local taskData = TaskData:objectByID(v.taskid)
			if taskData ~= nil and v.state == 1 and taskData.category == 1 then
				return true
			end
		end
	end
	return false
end

return TaskManager:new()