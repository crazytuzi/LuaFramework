DailyTaskItem = BaseClass(LuaUI)
function DailyTaskItem:__init(...)
	self.URL = "ui://1m5molo6kftje";
	self:__property(...)
	self:Config()
end

function DailyTaskItem:SetProperty(...)
	
end

function DailyTaskItem:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function DailyTaskItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","DailyTaskItem")
	self.bg = self.ui:GetChild("bg")
	self.difficultyItem = self.ui:GetChild("difficultyItem")
	self.starItem = self.ui:GetChild("starItem")
	self.buttonStart = self.ui:GetChild("buttonStart")
	self.labelName = self.ui:GetChild("labelName")
	self.labelTitle = self.ui:GetChild("labelTitle")
	self.imgSplitLeft = self.ui:GetChild("imgSplitLeft")
	self.labelTitleGet = self.ui:GetChild("labelTitleGet")
	self.imgSpriteRight = self.ui:GetChild("imgSpriteRight")
	self.groupRewardTip = self.ui:GetChild("groupRewardTip")
end

function DailyTaskItem.Create(ui, ...)
	return DailyTaskItem.New(ui, "#", {...})
end

function DailyTaskItem:__delete()
	if self.difficultyItem then
		self.difficultyItem:Destroy()
	end

	if self.starItem then
		self.starItem:Destroy()
	end

	self:DestroyRewardItemList()
end

function DailyTaskItem:InitData()
	self.taskId = -1
	self.uiRewardUIList = {}
end

function DailyTaskItem:InitUI()
	self.difficultyItem = DifficultyItem.Create(self.difficultyItem)
	self.starItem = StarItem.Create(self.starItem)

end

function DailyTaskItem:InitEvent()
	self.buttonStart.onClick:Add(self.OnStartBtnClick, self)
end

function DailyTaskItem:SetData(data)
	self.taskId = data or -1
end

function DailyTaskItem:SetUI()
	if self.taskId ~= -1 then
		local curTaskCfg = GetCfgData("task"):Get(self.taskId)
		if not TableIsEmpty(curTaskCfg) then
			local curTaskDifficultyLev = DailyTaskModel:GetTaskDifficulty(self.taskId)
			local difficultyBGURL = UIPackage.GetItemURL("DailyTaskUI", DailyTaskConst.DifficultyBG[curTaskDifficultyLev])	or ""
			local difficultyDesc = DailyTaskConst.DifficultyDesc[curTaskDifficultyLev]	or ""
			self.difficultyItem:SetUI(difficultyBGURL, difficultyDesc)
			local starItemURL = UIPackage.GetItemURL("DailyTaskUI", DailyTaskConst.DifficultyStar[curTaskDifficultyLev]) or ""
			local starItemBGURL = UIPackage.GetItemURL("DailyTaskUI", DailyTaskConst.StarItemBGURL)
			self.starItem:SetUI(starItemBGURL or "", starItemURL)
			self.labelName.text = curTaskCfg.taskName
			self:SetTitle(curTaskCfg)

			--任务奖励显示等策划配置新的字段显示
			self:SetRewardUI(curTaskCfg)
		end
	end
end

function DailyTaskItem:SetTitle(taskCfg)
	if not TableIsEmpty(taskCfg) then
		local taskDataObj = TaskModel:GetInstance():GetTaskDataByID(self.taskId)
		local strProcess = ""
		if not TableIsEmpty(taskDataObj) then

		else
			strProcess = "0"
		end
		self.labelTitle.text = string.format(taskCfg.content , strProcess)
	end
end

function DailyTaskItem:OnStartBtnClick()
	if self.taskId ~= -1 then
		DailyTaskController:GetInstance():AcceptDailyTask(self.taskId)
		DailyTaskController:GetInstance():CloseDailyTaskPanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function DailyTaskItem:SetRewardUI(curTaskCfg)

	if not TableIsEmpty(curTaskCfg) then
		local showReward = curTaskCfg.showReward

		for index = 1, #showReward do
			if index <= DailyTaskConst.MaxRewardNum then
				local oldItemObj = self:GetRewardItemByIndex(index)
				local curItemObj = {}
				local curItemData = showReward[index]
				if not TableIsEmpty(oldItemObj) then
					curItemObj = oldItemObj
					self.ui:AddChild(curItemObj.ui)
				else
					curItemObj = PkgCell.New(self.ui)
					table.insert(self.uiRewardUIList, curItemObj)
				end

				curItemObj:SetDataByCfg(curItemData[1], curItemData[2], curItemData[3], curItemData[4])
				curItemObj:SetXY(35 + (index - 1) * 101, 340)
				curItemObj:OpenTips(true, false)
			end
		end	
	end
end

function DailyTaskItem:GetRewardItemByIndex(index)
	return self.uiRewardUIList[index] or {}
end

function DailyTaskItem:DestroyRewardItemList()
	for index = 1, #self.uiRewardUIList do
		self.uiRewardUIList[index]:Destroy()
		self.uiRewardUIList[index] = nil
	end
	self.uiRewardUIList = {}
end