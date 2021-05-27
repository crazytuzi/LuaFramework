FuMoData = FuMoData or BaseClass()

--0刷星成功 1失败保持 2接受任务 3任务目标达成 4任务完成
FuMoTaskState = 
{
	FreshStartSuccess = 0,
	FreshStartFailed = 1,
	Accept = 2,
	Complete = 3,
	Finish = 4,
}

function FuMoData:__init()
	if FuMoData.Instance ~= nil then
		ErrorLog("[FuMoData] attempt to create singleton twice!")
		return
	end
	FuMoData.Instance = self
	
	self.quest_state = -1 --初始化的任务状态
	self.prev_task_id = -1 --上一个任务id
	self.task_id = -1 --初始化要操作的当前任务id
	
	self.target_index = 0
	self.finish_count = 0
	self.finish_max_count = 0
	self.exp = 0
	self.level = 0
	self:InitFumoDefMaxCount()
end	

function FuMoData:__delete()
end	

function FuMoData:GetRemainTick()
	return self.finish_max_count - self.finish_count
end	

function FuMoData:InitFumoDefMaxCount()
	local cfg = ConfigManager.Instance:GetTaskConfig(8063) --伏魔任务配置
	self.max_def_count = 0
	if cfg then
		self.max_def_count = cfg.maxcount
	end
end

function FuMoData:SetFumoFinishMaxCount()
	local cur_privilege = PrivilegeData.Instance:GetCurPrivilege()
	local privile_add_cnt = PrivilegeData.Instance:GetPrivilegeAddCntByType(cur_privilege, PrivilegeData.AddCntTypeT.FuMoTask)
	self.finish_max_count = self.max_def_count + (privile_add_cnt or 0)
end

function FuMoData:ChangeBaseInfo(data)
	if self.task_id == -1 then
		self.task_id = data.task_id
	elseif 	self.task_id ~= data.task_id then
		self.prev_task_id = self.task_id
		self.task_id = data.task_id
		self.quest_state = -1
	end	

	self.target_index = data.target_index
	self.finish_count = data.finish_count
	--self.finish_max_count = data.finish_max_count
	self.level = data.level
	self.exp = data.exp

	--print(self.task_id,self.target_index,self.finish_count,self.level,self.exp)
end	

function FuMoData:ChangeStateInfo(data)
	if data.quest_state == FuMoTaskState.FreshStartSuccess then
		self.level = data.level
	end
end	


function FuMoData:GetUpLevelConsume()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	
	for _,v in pairs(BookQuestConfig.Levels) do
		if v.min <= level and v.max >= level then
			return  v.flushMoneyType , v.flushMoney
		end	
	end	
	return nil,nil
end	

function FuMoData:GetLijiFinishConsume()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for _,v in pairs(BookQuestConfig.Levels) do
		if v.min <= level and v.max >= level then
			return  v.speedMoneyType , v.speedFinMoney
		end	
	end	
	return nil,nil
end	

function FuMoData:GetDoubleGetConsume()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for _,v in pairs(BookQuestConfig.Levels) do
		if v.min <= level and v.max >= level then
			return  v.awardMoneyType , v.doubleAward
		end	
	end	
	return nil,nil
end	

function FuMoData:GetThreeGetConsume()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for _,v in pairs(BookQuestConfig.Levels) do
		if v.min <= level and v.max >= level then
			return  v.awardMoneyType , v.thriceAward
		end	
	end	
	return nil,nil
end	
