WelfareView =BaseClass()

function WelfareView:__init()
	self:InitData()
	self:InitEvent()
	self:LayoutUI()
end

function WelfareView:__delete()
	if self.welfarePanel and self.welfarePanel.isInited then
		self.welfarePanel:Destroy()
	end
	self.welfarePanel = nil
end

function WelfareView:InitData()
	self.welfarePanel = nil
end

function WelfareView:InitEvent()

end

function WelfareView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("Welfare")
	self.isInited = true
end

function WelfareView:OpenWelfarePanel(tabIdx)
	if not self.welfarePanel or not self.welfarePanel.isInited then
		self.welfarePanel = WelfarePanel.New()
	end
	self.welfarePanel:Open(tabIdx)
end

function WelfareView:GetWelfarePanel()
	return self.welfarePanel
end
