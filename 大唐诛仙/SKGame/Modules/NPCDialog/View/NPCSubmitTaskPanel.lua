NPCSubmitTaskPanel =BaseClass(BaseView)

function NPCSubmitTaskPanel:__init( ... )
	self.URL = "ui://y1al0f5qtjjeb"
	local ui = UIPackage.CreateObject("NPCDialog","NPCSubmitTaskPanel")
	self.ui = ui
	self.id = "NPCSubmitTaskPanel"
	self.group_bg = ui:GetChild("group_bg")
	self.label_task_name = ui:GetChild("label_task_name")
	self.label_task_desc = ui:GetChild("label_task_desc")
	self.label_task_process = ui:GetChild("label_task_process")
	self.group_task_info = ui:GetChild("group_task_info")
	self.label_first_reward_title = ui:GetChild("label_first_reward_title")
	self.label_first_reward_count = ui:GetChild("label_first_reward_count")
	self.loader_first_reward_icon = ui:GetChild("loader_first_reward_icon")
	self.group_first_reward = ui:GetChild("group_first_reward")
	self.label_second_reward_title = ui:GetChild("label_second_reward_title")
	self.label_second_reward_count = ui:GetChild("label_second_reward_count")
	self.loader_second_reward_icon = ui:GetChild("loader_second_reward_icon")
	self.group_reward_exp = ui:GetChild("group_reward_exp")
	self.button_complete = ui:GetChild("button_complete")
	self.list_rewards = ui:GetChild("list_rewards")

	self:InitEvent()
	self:InitData()
	self:InitUI()
	self:SetUI()
end
function NPCSubmitTaskPanel:InitEvent()
	self.closeCallback = function () end
	self.openCallback  = function () 
		self.isHasSubmit = false
	end
	--self.button_complete.onClick:Add(self.OnBtnCompleteClick, self)
	ButtonToDelayClick(self.button_complete , function() self:OnBtnCompleteClick() end , 2 , nil)
end

function NPCSubmitTaskPanel:InitUI()
	
	self.list_rewards = ListNPCTaskReward.Create(self.list_rewards)
	self.label_task_name.text = ""
	self.label_task_desc.text = ""

	self.label_task_process.text = ""

	self.label_first_reward_title.text = ""
	self.label_first_reward_count.text = ""
	self.label_second_reward_title.text = ""
	self.label_second_reward_count.text = ""

	self.label_first_reward_title.visible = false
	self.label_first_reward_count.visible = false
	self.label_second_reward_title.visible = false
	self.label_second_reward_count.visible = false

	self.loader_first_reward_icon.url = ""
	self.loader_second_reward_icon.url = ""
	
	local titleButtonComp = self.button_complete:GetChild("title")
	if titleButtonComp then
		titleButtonComp.text = "完成任务"
	end
	
end

function NPCSubmitTaskPanel:InitData()
	self.model = NPCDialogModel:GetInstance()
	self.controller = NPCDialogController:GetInstance()
	self.taskDataObj = self.model:GetTaskData() or {}
	self.isHasSubmit = false

	self.coinURL = UIPackage.GetItemURL("NPCDialog", "coin")
	self.expURL = UIPackage.GetItemURL("NPCDialog", "exp")

end

function NPCSubmitTaskPanel:OnBtnCompleteClick()
	
	if self.taskDataObj and not TableIsEmpty(self.taskDataObj) and (not self.isHasSubmit) then
		self.isHasSubmit = true
		self.controller:SubmitDialogTask()
		self:Close()
	end
end

function NPCSubmitTaskPanel:SetDataAndUI()
	self.taskDataObj = self.model:GetTaskData() or {}
	self:SetUI()
end

function NPCSubmitTaskPanel:SetUI()
	if not TableIsEmpty(self.taskDataObj) then
		local taskData = self.taskDataObj:GetTaskData()
		local strTaskName = ""
		if string.find(taskData.taskName , "(完成)") ~= nil then
			strTaskName = string.sub(taskData.taskName , 1, -32) --"[COLOR=#00ff00](完成)[/COLOR]" --和策划约定包含ubb字符串的完成共31个字符		
		else
			strTaskName = taskData.taskName
		end
		self.label_task_name.text = strTaskName --分割字符串
		self.label_task_desc.text = taskData.description or ""
		self:SetTaskProcessUI()

		--如果奖励中，金币和经验值都有的话，先显示金币后显示经验值，反之只有一个的话，就都显示到第一个
		local isHasCoin , coinRewardInfo = self:IsHasCoinReward()
		local isHasExp, expRewardInfo = self:IsHasExpReward()

		if self:IsHasCoinExpReward() == true then
			self:SetFirstRewardUI(coinRewardInfo)
			self:SetSecondRewardUI(expRewardInfo)
		else
			if isHasCoin then
				self:SetFirstRewardUI(coinRewardInfo)
			end
			if isHasExp then
				self:SetFirstRewardUI(expRewardInfo)
			end
		end

		local rewardList = 	self.taskDataObj:GetRewardList()
		if not TableIsEmpty(rewardList) then
			self:SetRewardUI(rewardList)
		end
	end
end

function NPCSubmitTaskPanel:SetFirstRewardUI(rewardInfo)
	if not TableIsEmpty(rewardInfo) then
		if rewardInfo.itemType == TaskConst.RewardItemType.Coin then
			self.label_first_reward_title.text = "金币"
			self.loader_first_reward_icon.url = self.coinURL
		elseif rewardInfo.itemType == TaskConst.RewardItemType.Experience then
			self.label_first_reward_title.text = "经验"
			self.loader_first_reward_icon.url = self.expURL
		end
		
		self.label_first_reward_count.text = NumberGetString(rewardInfo.itemCnt)
		self.label_first_reward_title.visible = true
		self.label_first_reward_count.visible = true
	end
end

function NPCSubmitTaskPanel:SetSecondRewardUI(rewardInfo)
	if not TableIsEmpty(rewardInfo) then
		if rewardInfo.itemType == TaskConst.RewardItemType.Coin then
			self.label_second_reward_title.text = "金币"
			self.loader_second_reward_icon.url = self.coinURL
		elseif rewardInfo.itemType == TaskConst.RewardItemType.Experience then
			self.label_second_reward_title.text = "经验"
			self.loader_second_reward_icon.url = self.expURL
		end

		self.label_second_reward_count.text = NumberGetString(rewardInfo.itemCnt)
		self.label_second_reward_title.visible = true
		self.label_second_reward_count.visible = true
	end
end


function NPCSubmitTaskPanel:IsHasCoinReward()
	local rtnIsHas = false
	local rtnRewardInfo = {}
	if not TableIsEmpty(self.taskDataObj)  then
		local rewardList = self.taskDataObj:GetRewardList()
		for index = 1, #rewardList do
			local curRewardInfo = rewardList[index]
			if not TableIsEmpty(curRewardInfo) and curRewardInfo.itemType then
				if curRewardInfo.itemType == TaskConst.RewardItemType.Coin then
					rtnIsHas = true
					rtnRewardInfo = curRewardInfo
					break
				end
			end
		end
	end
	return rtnIsHas, rtnRewardInfo
end

function NPCSubmitTaskPanel:IsHasExpReward()
	local rtnIsHas = false
	local rtnRewardInfo = {}

	if not TableIsEmpty(self.taskDataObj)  then
		local rewardList = self.taskDataObj:GetRewardList()
		for index = 1, #rewardList do
			local curRewardInfo = rewardList[index]
			if not TableIsEmpty(curRewardInfo) and curRewardInfo.itemType then
				if curRewardInfo.itemType == TaskConst.RewardItemType.Experience then
					rtnIsHas = true
					rtnRewardInfo = curRewardInfo
				end
			end
		end
	end
	return rtnIsHas, rtnRewardInfo
end

function NPCSubmitTaskPanel:IsHasCoinExpReward()
	local rtnIsHas = false
	if self:IsHasCoinReward() == true and self:IsHasExpReward() == true then
		rtnIsHas = true
	end
	return rtnIsHas
end



function NPCSubmitTaskPanel:SetRewardUI(rewardList)
	self.list_rewards:SetUI(rewardList)

end

function NPCSubmitTaskPanel:SetTaskProcessUI()
	if TableIsEmpty(self.taskDataObj) then return end

	local curTaskState = self.taskDataObj:GetTaskState() or -1
	local taskTargetTab = self.taskDataObj:GetTaskTarget()
	local allCnt = 0
	local hasFinish = false
	local TTT = TaskConst.TaskTargetType
	local tt = taskTargetTab.targetType
	if tt == TTT.KillMonster then
		allCnt = taskTargetTab.targetParam[3] --{mapID，怪物ID，数量}
	elseif tt == TTT.CollectItem then
		--allCnt = taskTargetTab.targetParam[2] --{transferID,数量} --走配置
	elseif tt == TTT.CopyPass  then
		--allCnt = 1 --- {需要通关的副本id,通关次数}（暂时未定）
	elseif tt == TTT.GetItem then
		allCnt = taskTargetTab.targetParam[3]
	else 
		allCnt = 0
	end

	if curTaskState == TaskConst.TaskState.Finish then
		hasFinish = true
	elseif curTaskState == TaskConst.TaskState.NotFinish then
		hasFinish = false
	end
	

	local str = self.taskDataObj:GetTaskContent()
	if allCnt ~= 0 then
		if hasFinish == true then
			self.label_task_process.text = string.format(str, self.taskDataObj:GetTaskProcess())
			
		else
			self.label_task_process.text = string.format(str, self.taskDataObj:GetTaskProcess())
		end
	else
		if hasFinish == true then
			self.label_task_process.text = str
		else
			self.label_task_process.text = string.format("%s", str)
		end
	end

end


-- Dispose use NPCSubmitTaskPanel obj:Destroy()
function NPCSubmitTaskPanel:__delete()
	self.isHasSubmit = false
	if self.list_rewards then
		self.list_rewards:Destroy()
	end
	self.list_rewards = nil

end