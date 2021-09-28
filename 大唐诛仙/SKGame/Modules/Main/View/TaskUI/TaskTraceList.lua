TaskTraceList =BaseClass(LuaUI)

function TaskTraceList:__init( ... )
	self.URL = "ui://0042gnito6dhbk"
	self:__property(...)
	self:Config()
end

function TaskTraceList:SetProperty( ... )
end

function TaskTraceList:Config()
	self.TaskItemURL = "ui://0042gnituujrbl"
	self.items = {}
	self:InitEvent()
end

function TaskTraceList:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","TaskTraceList")
	self.list = self.ui:GetChild("list")
end

function TaskTraceList:InitEvent()
end

function TaskTraceList.Create( ui, ...)
	return TaskTraceList.New(ui, "#", {...})
end

function TaskTraceList:SetUI(taskDataList)
	self:DisposeUIItemList()
	if taskDataList ~= nil then
		for index = 1, #taskDataList do
			local itemData = taskDataList[index]
			local taskItem = TaskTraceItem.New()
			taskItem:SetUI(itemData)
			taskItem:AddTo(self.list)
			table.insert(self.items, taskItem)
		end
	end
end
function TaskTraceList:GetItem( idx )
	return self.items[idx]
end

function TaskTraceList:UpdateTaskState(playTaskMsg)
	if not TableIsEmpty(playTaskMsg) then
		for index = 1, #self.items do
			local curItem = self.items[index]
			if curItem:GetTaskId() == playTaskMsg.taskId then
				local curItemData = TaskModel:GetInstance():GetTaskDataByID(playTaskMsg.taskId)
				if not TableIsEmpty(curItemData) then
					curItem:SetData(curItemData)
					curItem:SetTaskStateUI()
				end
				return
			end
		end
	end
end

function TaskTraceList:SyncCycleTaskNum()
	for index = 1, #self.items do
		local curItem = self.items[index]
		if curItem then
			local curTaskDataObj = curItem:GetData()
			if not TableIsEmpty(curTaskDataObj) then
				if	curTaskDataObj:IsCycleTask() == true then
					curItem:SetTaskNameUI()
					return
				end
			end
		end
	end
end

function TaskTraceList:DisposeUIItemList()
	for index = 1, #self.items do
		self.items[index]:Destroy()
		self.items[index] = nil
	end
	self.items = {}
end

function TaskTraceList:__delete()
	self:DisposeUIItemList()
	self.list = nil
end