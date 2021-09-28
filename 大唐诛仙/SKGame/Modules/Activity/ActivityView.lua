	
ActivityView =BaseClass()

function ActivityView:__init()
	if self.isInited then return end
	resMgr:AddUIAB("Activity")
	self.isInited = true
end

function ActivityView:OpenDayActivity()
	if not self.dayActivityPanel or not self.dayActivityPanel.isInited then
		self.dayActivityPanel = DayActivityPanel.New()
	end
	self.dayActivityPanel:Refresh()
	self.dayActivityPanel:Open()
end 

function ActivityView:CloseDayActivity()
	if self.dayActivityPanel and self.dayActivityPanel.isInited then
		self.dayActivityPanel:Close()
	end
end

function ActivityView:Close()
	self:CloseDayActivity()
end

function ActivityView:__delete()
	if self.dayActivityPanel then
		self.dayActivityPanel:Destroy()
		self.dayActivityPanel = nil
	end

	self.isInited = false
end