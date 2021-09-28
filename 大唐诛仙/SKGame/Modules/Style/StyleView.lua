	
StyleView =BaseClass()

function StyleView:__init()
	if self.isInited then return end
	resMgr:AddUIAB("Style")
	self.isInited = true
end

function StyleView:GetStylePanel()
	if not self.stylePanel or not self.isInited then
		self.stylePanel = StylePanel.New()
	end
	return self.stylePanel
end
function StyleView:Close()
	if self.stylePanel then
		self.stylePanel:Close()
	end
end

function StyleView:__delete()
	if self.stylePanel then
		self.stylePanel:Destroy()
	end
	self.stylePanel = nil
	self.isInited = false
end