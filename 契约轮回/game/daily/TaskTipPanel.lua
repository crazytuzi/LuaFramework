TaskTipPanel = TaskTipPanel or class("TaskTipPanel",BasePanel)
local TaskTipPanel = TaskTipPanel

function TaskTipPanel:ctor()
	self.abName = "daily"
	self.assetName = "TaskTipPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	--self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.table_index = nil
	self.model = DailyModel:GetInstance()
	self.item_list = {}
end

function TaskTipPanel:dctor()
end

function TaskTipPanel:Open( )
	TaskTipPanel.super.Open(self)
end

function TaskTipPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView/Viewport/Content/TaskTipItem",
		"btn_close",
	}
	self:GetChildren(self.nodes)

	self.TaskTipItem_go = self.TaskTipItem.gameObject
	SetVisible(self.TaskTipItem_go, false)
	self:AddEvent()
end

function TaskTipPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btn_close.gameObject,call_back)


end

function TaskTipPanel:OpenCallBack()
	self:UpdateView()
end

function TaskTipPanel:UpdateView( )
	if #self.item_list > 0  then
		return
	end
	local daily_tasks = self.model:GetDailyTaskList()
	local activity_tasks = self.model:GetCurLimitList()
	local tasks = {}
	local last_task
	for i=1, #daily_tasks do
		local task = daily_tasks[i]
		if not task.isLock and Config.db_task_tip[task.conData.id] then
			if Config.db_task_tip[task.conData.id].can_buy == 1 then
				tasks[#tasks+1] = task
			elseif task.conData.id == 9 then
				last_task = task
			else
				local use_count = task.taskInfo and task.taskInfo.progress or 0
				local left_count = task.conData.count - use_count
				if left_count > 0 then
					tasks[#tasks+1] = task
				end
			end
		end
	end
	for i=1, #activity_tasks do
		local task = activity_tasks[i]
		if not task.isLock and Config.db_task_tip[task.conData.id] then
			if task.timeData.state == 1 then
				table.insert(tasks, 1, task)
			else
				tasks[#tasks+1] = task
			end
		end
	end
	if last_task then
		tasks[#tasks+1] = last_task
	end
	for i=1, #tasks do
		local task = tasks[i]
		local item = TaskTipItem(self.TaskTipItem_go, self.Content)
		item:SetData(task)
		self.item_list[i] = item
	end
end

function TaskTipPanel:CloseCallBack()
	if self.item_list then
		for i=1, #self.item_list do
			self.item_list[i]:destroy()
		end
		self.item_list = nil
	end
end
function TaskTipPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
end