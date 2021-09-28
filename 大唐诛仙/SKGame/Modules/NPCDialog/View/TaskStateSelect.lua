TaskStateSelect = BaseClass(LuaUI)

TaskStateSelect.StateTypeEnum = {
	None = 0,
	Task = 1, --触发任务
	Fun = 2, --触发功能
}

function TaskStateSelect:__init(...)
	
	self.URL = "ui://y1al0f5qtjjep";
	self:__property(...)
	self:Config()
end

function TaskStateSelect:SetProperty(...)
	
end

function TaskStateSelect:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function TaskStateSelect:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("NPCDialog","TaskStateSelect");

	self.img_bg = self.ui:GetChild("img_bg")
	self.list = self.ui:GetChild("list")
end

function TaskStateSelect.Create(ui, ...)
	return TaskStateSelect.New(ui, "#", {...})
end

function TaskStateSelect:__delete()
	self:DisposeButtonStateUIList()
	self:DisposeButtonStateData()
end

function TaskStateSelect:InitData()
	self.buttonStateItemURL = UIPackage.GetItemURL("Common", "ButtonYellow")
	self.stateData = {}
	self.lastSelectedIndex = -1
end

function TaskStateSelect:InitUI()
	self.buttonStateUIList = {}
end

function TaskStateSelect:GetUIList()
	return self.list
end

function TaskStateSelect:CleanData()
	self.stateData = {}
	self.lastSelectedIndex = -1
end

function TaskStateSelect:InitEvent()
	self.list.onClickItem:Add(self.OnButtonStateClick, self)
end

function TaskStateSelect:SetUI(taskDataList, funId)
	self:DisposeButtonStateData()
	self.list:RemoveChildrenToPool()

	if not TableIsEmpty(taskDataList) then
		table.insert(self.stateData, {
			type = TaskStateSelect.StateTypeEnum.Task,
			data = taskDataList
			})
	end

	if funId ~= -1 then
		table.insert(self.stateData, {type = TaskStateSelect.StateTypeEnum.Fun, data = funId})
	end

	if TableIsEmpty(self.stateData) then
		self:SetVisible(false)
	else
		self:SetVisible(true)
	end

	for index = 1, #self.stateData do
		local curStateData = self.stateData[index]
		if curStateData.type == TaskStateSelect.StateTypeEnum.Task then
			for subIndex = 1, #curStateData.data do
				local curItemInfo = curStateData.data[subIndex]
				local item = self.list:AddItemFromPool(self.buttonStateItemURL)
				local stateItem = ButtonYellow.Create(item, curItemInfo)
				local strTaskDesc = curItemInfo:GetTaskNameWithType()
				
				stateItem:SetData(curItemInfo)
				stateItem:SetUI(strTaskDesc)
				table.insert(self.buttonStateUIList, stateItem)
			end
		elseif curStateData.type == TaskStateSelect.StateTypeEnum.Fun then
			
			local funCfg = GetCfgData("Function"):Get(curStateData.data[1])
			
			if not TableIsEmpty(funCfg) then
				
				local curItemInfo = funCfg
				local item = self.list:AddItemFromPool(self.buttonStateItemURL)
				local stateItem = ButtonYellow.Create(item, curItemInfo)
				local strFunName = curItemInfo.desc
				
				stateItem:SetData(curItemInfo)
				stateItem:SetUI(strFunName)
				table.insert(self.buttonStateUIList, stateItem)
			end
		end
	end
end

function TaskStateSelect:DisposeButtonStateUIList()
	for index = 1, #self.buttonStateUIList do
		self.buttonStateUIList[index]:Destroy()
		self.buttonStateUIList[index] = nil
	end
end

function TaskStateSelect:DisposeButtonStateData()
	self.stateData = {}
end

function TaskStateSelect:OnButtonStateClick()
	if self.lastSelectedIndex ~= self.list.selectedIndex then
		self.lastSelectedIndex = self.list.selectedIndex
		local curStateData , curStateType, curStateIndex = self:GetSelectedStateData()
		if not TableIsEmpty(curStateData) and curStateType ~= TaskStateSelect.StateTypeEnum.None then
			if curStateType == TaskStateSelect.StateTypeEnum.Fun then
				if not self:IsCanEnterState(curStateIndex) then
				 	self:ShowTips(curStateData ,curStateType , curStateIndex)
				 	NPCDialogController:GetInstance():CloseNPCDialogPanel()
				else
					NPCDialogController:GetInstance():CloseNPCDialogPanel()
					FunctionController:GetInstance():OpenModuleUI(curStateData[1])
				end
			elseif curStateType == TaskStateSelect.StateTypeEnum.Task then
				NPCDialogController:GetInstance():CloseNPCDialogPanel()
				NPCBehaviorMgr:GetInstance():TaskBehavior(curStateData)
			end
		end
	end
end

function TaskStateSelect:GetSelectedStateData()
	local rtnStateData = {}
	local rtnStateType = TaskStateSelect.StateTypeEnum.None
	local rtnStateIndex = -1
	if self.lastSelectedIndex ~= -1 then
		local itemDataIndex = 0
		for index = 1, #self.stateData do
			local curStateData = self.stateData[index]
			if curStateData.type == TaskStateSelect.StateTypeEnum.Task then
				for subIndex = 1, #curStateData.data do
					itemDataIndex = itemDataIndex + 1
					if itemDataIndex == self.lastSelectedIndex + 1 then

						rtnStateData = curStateData.data[subIndex]
						rtnStateType = TaskStateSelect.StateTypeEnum.Task
						rtnStateIndex = index
						break
					end
				end
			elseif curStateData.type == TaskStateSelect.StateTypeEnum.Fun then
				itemDataIndex = itemDataIndex + 1
				if itemDataIndex == self.lastSelectedIndex + 1 then
					
					rtnStateData = curStateData.data
					rtnStateType = TaskStateSelect.StateTypeEnum.Fun
					rtnStateIndex = index
					break
				end
			end
		end
	end
	
	return rtnStateData, rtnStateType, rtnStateIndex
end

--判断NPC功能是否打开
function TaskStateSelect:IsCanEnterState(targetIndex)
	local rtnIsCan = true
	if targetIndex then
		for index = 1, #self.stateData do
			if index == targetIndex then
				--例外：
				--1.已经领了环任务的话，就不不能显示入口按钮
				local curStateData = self.stateData[index]
				if curStateData.type == TaskStateSelect.StateTypeEnum.Fun then
					if curStateData.data[1] == FunctionConst.FunEnum.cycleTask and TaskModel:GetInstance():IsHasCycleTask() == true then
						rtnIsCan = false
						break
					end
				end

				--2.当前有每日任务的话，就不能显示入口按钮,没有的话，已达每日任务次数上限的话，也不能显示入口按钮
				if curStateData.type == TaskStateSelect.StateTypeEnum.Fun then
					if curStateData.data[1] == FunctionConst.FunEnum.dailyTask and ((TaskModel:GetInstance():IsHasDailyTask() == true) or (DailyTaskModel:GetInstance():IsMaxHasGetCnt() == true)) then
						rtnIsCan = false
						break
					end
				end
			end
		end
	end
	zy("======== 判断NPC功能是否打开: " , tostring(rtnIsCan))
	return rtnIsCan
end

--NPC功能不可打开的提示
function TaskStateSelect:ShowTips(curStateData , curStateType, curStateIndex)
	if curStateIndex ~= nil and not self:IsCanEnterState(curStateIndex) and curStateType ~= nil then
		if not TableIsEmpty(curStateData) then
			if curStateType == TaskStateSelect.StateTypeEnum.Fun and curStateData[1] == FunctionConst.FunEnum.dailyTask then
				if DailyTaskModel:GetInstance():IsMaxHasGetCnt() then
					UIMgr.Win_FloatTip("你已完成今日悬赏任务")
				else
					UIMgr.Win_FloatTip("您已领取悬赏任务")
				end
			end

			if curStateType == TaskStateSelect.StateTypeEnum.Fun and curStateData[1] == FunctionConst.FunEnum.cycleTask then
				UIMgr.Win_FloatTip("您已领取环任务")
			end
		end
	end
end