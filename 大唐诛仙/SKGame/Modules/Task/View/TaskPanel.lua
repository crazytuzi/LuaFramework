TaskPanel =BaseClass(CommonBackGround)

-- (Constructor) use TaskPanel.New(...)
function TaskPanel:__init( ... )
	self.URL = "ui://ioaemb0chudk9";
	self.ui = UIPackage.CreateObject("Task","TaskPanel");
	self.id = "TaskPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1 , 2}
	self.tabBar = {}
	self.bgUrl = "bg_big1"
	self:SetTitle("任务")
	
end

function TaskPanel:Layout()
	
	self.n2 = self.ui:GetChild("n2")
	self.n3 = self.ui:GetChild("n3")
	self.n4 = self.ui:GetChild("n4")
	self.n5 = self.ui:GetChild("n5")
	self.n6 = self.ui:GetChild("n6")
	self.n7 = self.ui:GetChild("n7")
	self.n8 = self.ui:GetChild("n8")
	self.group_bg = self.ui:GetChild("group_bg")
	self.label_title_task_target = self.ui:GetChild("label_title_task_target")
	self.label_task_name = self.ui:GetChild("label_task_name")
	self.group_task_target = self.ui:GetChild("group_task_target")
	self.label_title_task_info = self.ui:GetChild("label_title_task_info")
	self.label_task_info = self.ui:GetChild("label_task_info")
	self.group_task_info = self.ui:GetChild("group_task_info")
	self.label_title_task_awards = self.ui:GetChild("label_title_task_awards")
	self.list_award = self.ui:GetChild("list_award")
	self.group_task_awards = self.ui:GetChild("group_task_awards")
	self.button_goto = self.ui:GetChild("button_goto")
	self.button_abandon = self.ui:GetChild("button_abandon")
	self.list_tree = self.ui:GetChild("list_tree")

	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function TaskPanel:InitEvent()
	
	self.closeCallback = function () 
		self:CleanData()
	end
	self.openCallback  = function () 
		self:Update()
	end
	

	self.button_goto.onClick:Add(self.OnGoToBtnClick, self)
	self.button_abandon.onClick:Add(self.OnAbandonBtnClick, self)

	self.handler2=GlobalDispatcher:AddEventListener(EventName.UpdateTaskList, function ( data )
		self:UpdateTaskList(data)
	end)

	self.handler4=GlobalDispatcher:AddEventListener(EventName.AbandonTask, function ( data )
		self:HandleAbandonTask(data)
	end)

end

function TaskPanel:InitData()
	self.curTaskId = -1
	self.lastTaskId = -1
	self.lastAbandonTaskId = -1

	self.lastTaskDataObj = {}
	
	self.accordionData = TaskModel:GetInstance():GetAccordionData()
end

function TaskPanel:InitUI()
	self:CreateAccordion()
	self.list_award = AwardList.Create(self.list_award)
end

function TaskPanel:Update()
	self:SetData()
	self:SetUI()
end

function TaskPanel:CreateAccordion()
	if self.accordion == nil then
		local accordion = Accordion.New()
		accordion:AddTo(self.list_tree)
		self.accordion = accordion
	end
end

function TaskPanel:SetData()
	
	self.accordionData = TaskModel:GetInstance():GetAccordionData()
end

function TaskPanel:SetUI()

	if self.accordionData then
		self.accordion:SetData(self.accordionData , function(selectData)
			self.curTaskId = selectData[2] or 0
			self:UpdateUI()
		end)

		if self.accordionData[1][1] and self.accordionData[1][3][1][1] then
			self.accordion:SetSelect(self.accordionData[1][1] , self.accordionData[1][3][1][1])
		end
	end
end

--cuinuo
function TaskPanel:UpdateUI()
	local curTaskObj = TaskModel:GetInstance():GetTaskDataByID(self.curTaskId)
	if not TableIsEmpty(curTaskObj) then
		self:SetTaskInfoUI(curTaskObj)
		self:SetListAwardUI()
		self:SetAbandonBtnVisible()
	end
end

function TaskPanel:SetListTreeUI()
	self.list_tree:SetUI()
end

function TaskPanel:SetListAwardUI()
	self.list_award:SetUI(self.curTaskId)
end

function TaskPanel:SetTaskInfoUI(taskDataObj)
	if not TableIsEmpty(taskDataObj) then
		self:SetTaskStateInfo(taskDataObj)
		local taskData = taskDataObj:GetTaskData()
		self.label_task_info.text = taskData.description or ""
		self.curTaskId = taskData.id
	end
end

function TaskPanel:SetTaskStateInfo(taskData)
	if taskData then
		local curTaskState = taskData:GetTaskState() or -1
		local taskTargetTab = taskData:GetTaskTarget()
		local allCnt = 0
		local hasFinish = false
		local TaskTargetType = TaskConst.TaskTargetType
		local tt = taskTargetTab.targetType
		local param = taskTargetTab.targetParam
		if tt == TaskTargetType.KillMonster then
			allCnt = param[3] --{mapID，怪物ID，数量}
		elseif tt == TaskTargetType.CollectItem then
			--allCnt = param[2] --{transferID,数量}
		elseif tt == TaskTargetType.CopyPass  then
			--allCnt = 1 --- {需要通关的副本id,通关次数}（暂时未定）
		elseif tt == TaskTargetType.GetItem then
			allCnt = param[3] --获取多少个物品
		elseif tt == TaskTargetType.CycleTaskCounter then
			allCnt = param[1] --完成n次环任务
		elseif tt == TaskTargetType.DailyTaskCounter then
			allCnt = param[1] --完成n次悬赏任务
		elseif tt == TaskTargetType.RankMatchCounter then
			allCnt = param[1] -- 需要完成的天梯匹配次数
		elseif tt == TaskTargetType.HuntingMonsterCounter then
			allCnt = param[1] --需要完成的猎妖次数
		elseif tt == TaskTargetType.Compose then
			allCnt = param[1] --需要完成的合成次数
		else
			allCnt = 0
		end

		if curTaskState == TaskConst.TaskState.Finish then
			hasFinish = true
		elseif curTaskState == TaskConst.TaskState.NotFinish then
			hasFinish = false
		end

		if allCnt ~= 0 then
			if hasFinish == true then
				local str = taskData:GetTaskContent()
				self.label_task_name.text = string.format(str, taskData:GetTaskProcess())
			else
				self.label_task_name.text = string.format(taskData:GetTaskContent(), taskData:GetTaskProcess())
			end
		else
			if hasFinish == true then
				self.label_task_name.text = string.format("%s",taskData:GetTaskContent())
			else
				self.label_task_name.text = string.format("%s", taskData:GetTaskContent())
			end
		end
	end
end

function TaskPanel:OnGoToBtnClick()
	GlobalDispatcher:DispatchEvent(EventName.AUTO_HPMP, false)
	SceneController:GetInstance():GetScene():StopAutoFight(false) --任务寻路停止自动战斗
	TaskModel:GetInstance():SetShowSubmitDialog(true)
	SceneModel:GetInstance():CleanPathingFlag()
	local taskData = TaskModel:GetInstance():GetTaskDataByID(self.curTaskId)
	if taskData ~= nil and (not TableIsEmpty(taskData)) then
		if self.lastTaskId ~= self.curTaskId then
			self.lastTaskDataObj = TaskBehaviorFactory:GetInstance():Create(taskData)
			self.lastTaskId = self.curTaskId
		end

		if not TableIsEmpty(self.lastTaskDataObj) then
			TaskModel:GetInstance():SetLastSubmitTaskNPCInfo(taskData:GetTaskId() , taskData:GetSubmitNPCId())
			self.lastTaskDataObj:Behavior()
		end
	end
	self:Close()
end


function TaskPanel:OnAbandonBtnClick()
	local taskData = TaskModel:GetInstance():GetTaskDataByID(self.curTaskId)
	if not TableIsEmpty(taskData) then
		if self.lastAbandonTaskId ~= self.curTaskId then
			UIMgr.Win_Confirm("提示" , "是否放弃该任务？" , "确认" , "取消" , 
				function() 
					TaskController:GetInstance():AbandonTask(self.curTaskId)
					self.lastAbandonTaskId = self.curTaskId
				end , 
				function() 
					zy("取消放弃任务") 
			end)
		end
	end
end

function TaskPanel:CleanEvent()
	self.button_goto.onClick:Remove(self.OnGoToBtnClick, self)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler4)
end

function TaskPanel:UpdateTaskList()
	self:CleanAccordion()
	self:CreateAccordion()
	self:Update()
end

function TaskPanel:UpdateTaskListData()
	self.lastTaskSelectedIndex = self.defaultTaskSelectedIndex 
	self.allTaskDataObjs = TaskModel:GetInstance():GetAllTaskData()
end

function TaskPanel:UpdateTaskListUI()
	self:SetUI()
end

function TaskPanel:UpdateTaskState()
end

function TaskPanel:SetAbandonBtnVisible()
	local selectDataObj = TaskModel:GetInstance():GetTaskDataByID(self.curTaskId)
	if not TableIsEmpty(selectDataObj) then
		local isCanAbandon = selectDataObj:IsCanAbandon()
		self.button_abandon.visible = isCanAbandon
	end
end

function TaskPanel:CleanData()
	self.curTaskId = -1
	self.lastTaskId = -1
	self.lastAbandonTaskId = -1
	self.lastTaskDataObj = {}
end

function TaskPanel:HandleAbandonTask(data)
	if data then
		self.lastAbandonTaskId = -1
	end
end

function TaskPanel:CleanAccordion()
	if self.accordion then
		self.accordion:Destroy()
	end
	self.accordion = nil

	self.accordionData = {}
end

function TaskPanel:__delete()
	self:CleanEvent()
	self:CleanData()
	if self.list_award then
		self.list_award:Destroy()
	end
	self.list_award = nil
	self:CleanAccordion()
end

