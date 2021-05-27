ZsTaskData = ZsTaskData or BaseClass()

ZsTaskData.REWARD_STATE = "reward_state"

function ZsTaskData:__init()
	if ZsTaskData.Instance then
		ErrorLog("[ZsTaskData] Attemp to create a singleton twice !")
	end
	
	ZsTaskData.Instance = self

	self.rew_data = {
		big_index = 1,
		gift_list = {}
	}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	
	-- GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.IsZsTaskAllGet, BindTool.Bind(self.CheckIsZsTaskAllGet, self))
end

function ZsTaskData:__delete()
	ZsTaskData.Instance = nil
end

-- 钻石任务奖励是否全部领取
function ZsTaskData:ZsTaskRewrdIsAllget()
	local is_rew = self.rew_data.big_index > #TaskGoodGiftConfig.task

	return is_rew
end

function ZsTaskData:CheckIsZsTaskAllGet()
	return self:ZsTaskRewrdIsAllget()
end

function ZsTaskData:SetTaskGiftData(protocol)
	self.rew_data.big_index = protocol.big_task
	self.rew_data.gift_list = protocol.task_list

	GameCondMgr.Instance:CheckCondType(GameCondType.IsZsTaskAllGet)
	GlobalEventSystem:Fire(MainUIEventType.UPDATE_ZSTASK_ICON)
	self:DispatchEvent(ZsTaskData.REWARD_STATE)
end

-- 获取开启大任务
function ZsTaskData:GetBigTaskIndex()
	if self.rew_data.big_index > #TaskGoodGiftConfig.task then
		return 1
	else
		return self.rew_data.big_index
	end
end

-- 获取当前任务数据
function ZsTaskData:GetNowTaskData()
	local data = {}
	local cfg = TaskGoodGiftConfig.task[self.rew_data.big_index]
	if cfg then
		for k, v in pairs(self.rew_data.gift_list) do
			local item = cfg.list
			local vo = {}
			vo.index = k
			vo.com_time = v.complete_num
			vo.state = v.rew_state
			vo.task_title = item[vo.index].title
			vo.task_desc = item[vo.index].desc
			vo.view_def = item[vo.index].view_def
			vo.npcid = item[vo.index].npcid
			vo.all_time = item[vo.index].targetTimes
			vo.award = item[vo.index].award[1]
			table.insert(data, vo)
		end
	end

	return data
end

-- 获取两边数据
function ZsTaskData:GetNewTaskList()
	local left_item = {}
	local right_item = {}
	local data = self:GetNowTaskData()
	for k, v in pairs(data) do
		if v.index % 2 == 0 then
			table.insert(right_item, v)
		else
			table.insert(left_item, v)
		end
	end

	return left_item, right_item
end

-- 获取当前任务显示特效
function ZsTaskData:GetShowEffId()
	local effid 
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(TaskGoodGiftConfig.task[self.rew_data.big_index].awards) do
		if sex == v.sex then
			effid = v.id
		end
	end
	return effid
end

-- 判断当前小任务是否领取完毕
function ZsTaskData:GetSmallTaskRew()
	local remind = true
	for k, v in pairs(self.rew_data.gift_list) do
		if v.rew_state == 0 then
			remind = false 
			break
		end
	end
	return remind
end

-- 当前阶段领取了几个小任务
function ZsTaskData:GetSmallTaskNum()
	local index = 0
	local cfg = TaskGoodGiftConfig.task[self.rew_data.big_index]
	if cfg then
		for k, v in pairs(self.rew_data.gift_list) do
			local item = cfg.list
			if v.complete_num >= item[k].targetTimes then
				index = index + 1
			end
		end
	end
	return index
end

-- 判断是否有奖励领取
function ZsTaskData:GetRemindIcon()
	local remind = false
	local data = self:GetNowTaskData()
	if self:GetSmallTaskRew() then
		remind = true
	else
		for k, v in pairs(data) do
			if v.com_time >= v.all_time and v.state == 0 then
				remind = true
				break
			end
		end
	end
	return remind and 1 or 0
end