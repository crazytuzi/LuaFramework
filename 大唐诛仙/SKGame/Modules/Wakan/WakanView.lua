WakanView =BaseClass()

function WakanView:__init()
	if self.isInited then return end
	resMgr:AddUIAB("Wakan")
	self.isInited = true
end

function WakanView:GetWakanPanel()
	if not self.wakanPanel or not self.isInited then
		self.wakanPanel = WakanPanel.New()
		self.wakanPanel:ReqUpdate()
	end
	return self.wakanPanel
end 

function WakanView:__delete()
	if self.wakanPanel then
		self.wakanPanel:Destroy()
	end
	self.wakanPanel = nil

	self.isInited = false
end