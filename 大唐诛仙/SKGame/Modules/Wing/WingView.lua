	
WingView =BaseClass()

function WingView:__init()
	if self.isInited then return end
	self.isInited = true
end

function WingView:GetWingPanel(activeIds)
	if not self.wingPanel or not self.isInited then
		self.wingPanel = WingPanel.New(activeIds)
	end
	return self.wingPanel
end 

function WingView:__delete()
	if self.wingPanel then
		self.wingPanel:Destroy()
	end
	self.wingPanel = nil
	self.isInited = false
end