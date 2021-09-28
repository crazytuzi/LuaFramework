--处理任务系统表现层的相关逻辑（比如开关之类的）
TaskView =BaseClass()

function TaskView:__init()
	self:Config()
	self:LayoutUI()
end

function TaskView:Config()
	self:InitData()
end

function TaskView:InitData()
	self.model = TaskModel:GetInstance()
	self.taskPanel = nil
	self.taskEffect = nil
end


function TaskView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("Task")
	self.isInited = true
end


function TaskView:OpenTaskPanel()
	if not self.taskPanel or (not self.taskPanel.isInited) then
		self.taskPanel = TaskPanel.New()
	end

	if self.taskPanel == nil then return end
	self.taskPanel:Open()
end

function TaskView:OpenTaskEffect()
	if self.taskEffect == nil then
		self.taskEffect = TaskEffect.New()
	end
	return self.taskEffect
end

function TaskView:__delete()
	if self.taskPanel ~= nil then
		self.taskPanel:Destroy()
	end
	self.taskPanel = nil
	if self.taskEffect ~= nil then
		self.taskEffect:Destroy()
	end
	self.taskEffect = nil
	
	self.isInited = false
end
