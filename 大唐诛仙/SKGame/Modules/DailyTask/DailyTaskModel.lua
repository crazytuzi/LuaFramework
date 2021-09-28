DailyTaskModel =BaseClass(LuaModel)

function DailyTaskModel:__init()
	self:InitData()
	self:InitEvent()
end

function DailyTaskModel:__delete()
	GlobalDispatcher:RemoveEventListener(self.eventHandler0)
	GlobalDispatcher:RemoveEventListener(self.eventHandler1)
	DailyTaskModel.inst = nil
end

function DailyTaskModel:GetInstance()
	if DailyTaskModel.inst == nil then
		DailyTaskModel.inst = DailyTaskModel.New()
	end
	return DailyTaskModel.inst
end

function DailyTaskModel:InitData()
	self.dailyTaskData = {}
	self.getDailyListFlag = false --仅第一次打开界面，请求日常任务
end

function DailyTaskModel:InitEvent()
	self.eventHandler0 = GlobalDispatcher:AddEventListener(EventName.AbandonDailyTask, function()
		self:HandleAbandonDailyTask()
	end)
	self.eventHandler1 = GlobalDispatcher:AddEventListener(EventName.SubmitDailyTask, function()
		self:HandleSubmitDailyTask()
	end)
end

--同步每日任务列表
function DailyTaskModel:SyncDailyTaskList(data)
	if data then
		self.dailyTaskData = {}
		self.dailyTaskData.dailyTaskNum = data.dailyTaskNum --已接取每日任务次数
		self.dailyTaskData.dailyRefNum = data.dailyRefNum --剩余刷新次数
		self.dailyTaskData.taskIds = {} --面板三条任务数据
		for index = 1, #data.taskIds do
			table.insert(self.dailyTaskData.taskIds, data.taskIds[index])
		end
	end
end

--获取当前已经接取的每日任务次数
function DailyTaskModel:GetHasGetNum()
	return TaskModel:GetInstance():GetDailyTaskNum()
end

--获取剩余刷新次数
function DailyTaskModel:GetHasRefershNum()
	local rtnNum = 0
	if not TableIsEmpty(self.dailyTaskData) and self.dailyTaskData.dailyRefNum then
		rtnNum = self.dailyTaskData.dailyRefNum
	end
	return rtnNum
end

--

--获取当前的展示的任务id列表
function DailyTaskModel:GetTaskIdList()
	local rtnList = {}
	if not TableIsEmpty(self.dailyTaskData) and self.dailyTaskData.taskIds then
		rtnList = self.dailyTaskData.taskIds
	end
	return rtnList
end

function DailyTaskModel:GetTaskDifficulty(taskId)
	local rtnDiffculty = DailyTaskConst.DifficultyLevel.None
	if taskId then
		local curTaskCfg = GetCfgData("task"):Get(taskId)
		if not TableIsEmpty(curTaskCfg) then
			taskDifficultyVal = curTaskCfg.taskMode
			if taskDifficultyVal == DailyTaskConst.DifficultyLevel.Easy then
				rtnDiffculty = DailyTaskConst.DifficultyLevel.Easy
			elseif taskDifficultyVal == DailyTaskConst.DifficultyLevel.Normal then
				rtnDiffculty = DailyTaskConst.DifficultyLevel.Normal
			elseif taskDifficultyVal == DailyTaskConst.DifficultyLevel.Difficulty then
				rtnDiffculty = DailyTaskConst.DifficultyLevel.Difficulty
			elseif taskDifficultyVal == DailyTaskConst.DifficultyLevel.DifficultyII then
				rtnDiffculty = DailyTaskConst.DifficultyLevel.DifficultyII
			end
		end
	end
	return rtnDiffculty
end

function DailyTaskModel:SetGetDailyListFlag(bl)
	if type(bl) == "boolean" then
		self.getDailyListFlag = bl
	end
end

function DailyTaskModel:GetDailyListFlag()
	return self.getDailyListFlag
end

function DailyTaskModel:HandleAbandonDailyTask()
	self:SetGetDailyListFlag(false)
end

function DailyTaskModel:HandleSubmitDailyTask()
	self:SetGetDailyListFlag(false)
end

--是否达到已接每日任务数量上限
function DailyTaskModel:IsMaxHasGetCnt()
	maxCycleNum = self:GetMaxCnt()
	return (self:GetHasGetNum() >= maxCycleNum )
end

--获取悬赏任务最大次数
function DailyTaskModel:GetMaxCnt()
	local vipLev = VipModel:GetInstance():GetPlayerVipLV()
	local maxCycleNum = DailyTaskConst.MaxCycleNum
	if vipLev ~= nil and  vipLev > 0 then
		local vipPrivilegeCfg = GetCfgData("vipPrivilege")
		local dailyTaskKey = 16
		local dailyTaskVal = vipPrivilegeCfg[dailyTaskKey]
		local vipAddCnt = 0
		if dailyTaskVal then
			vipKey = StringFormat("vip{0}" , vipLev)
			vipAddCnt = dailyTaskVal[vipKey] or 0
		end
		maxCycleNum = maxCycleNum + vipAddCnt
	end
	return maxCycleNum
end

function DailyTaskModel:Reset()
	self.dailyTaskData = {}
	self.getDailyListFlag = false --仅第一次打开界面，请求日常任务
	DailyTaskConst.FreeRefershNum = 3
end

--获取用元宝刷新一次悬赏任务的元宝消耗量
function DailyTaskModel:GetRefershByDiamondCnt()
	local rtnCnt = 0
		local cfg = GetCfgData("constant"):Get(52)
		if cfg then
			rtnCnt = cfg.value  or 0
		end
	return rtnCnt
end