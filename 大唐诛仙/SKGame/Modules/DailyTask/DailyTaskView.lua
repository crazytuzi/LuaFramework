DailyTaskView =BaseClass()

function DailyTaskView:__init()
	self:InitData()
	self:InitEvent()
	self:LayoutUI()
end

function DailyTaskView:__delete()
	self.isInited = false
end

function DailyTaskView:InitData()
	if self.dailyTaskPanel and self.dailyTaskPanel.isInited then
		self.dailyTaskPanel:Destroy()
		self.dailyTaskPanel = nil
	end
end

function DailyTaskView:InitEvent()

end

function DailyTaskView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("DailyTaskUI")
	self.isInited = true
end


function DailyTaskView:OpenDailyTaskPanel()
	if (not self.dailyTaskPanel) or (not self.dailyTaskPanel.isInited) then
		self.dailyTaskPanel = DailyTaskPanel.New()
	end
	if self.dailyTaskPanel == nil then return end
	self.dailyTaskPanel:Open()
end

function DailyTaskView:CloseDailyTaskPanel()
	if self.dailyTaskPanel then
		self.dailyTaskPanel:Close()
	end
end