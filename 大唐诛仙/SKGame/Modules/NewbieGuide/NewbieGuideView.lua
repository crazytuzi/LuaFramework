NewbieGuideView = BaseClass()

function NewbieGuideView:__init()
	self:LayoutUI()
end

function NewbieGuideView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("NewbieGuide")
	self.isInited = true
end

function NewbieGuideView:__delete()
	self:DestroyNewbieGuidePanel()
	self.isInited = false
	self.model = nil
end

function NewbieGuideView:InitData()
	self.newbieGuidePanel = nil	
	self.model = NewbieGuideModel:GetInstance()
end

function NewbieGuideView:OpenNewbieGuidePanel()
	if not  self:GetNewbieGuidePanel() then
		self.newbieGuidePanel = NewbieGuidePanel.New()
	end
	newGuildLayer:AddChild(self.newbieGuidePanel.ui)
end

function NewbieGuideView:CloseNewbieGuidePanel()
	self:DestroyNewbieGuidePanel()
end

function NewbieGuideView:GetNewbieGuidePanel()
	if self.newbieGuidePanel and self.newbieGuidePanel.isInited then
		return self.newbieGuidePanel
	end
	return nil
end

function NewbieGuideView:DestroyNewbieGuidePanel()
	if self.newbieGuidePanel then
		self.newbieGuidePanel:Destroy()
		self.newbieGuidePanel=nil
	end
end

function NewbieGuideView:StartNewbieGuide()
	self:OpenNewbieGuidePanel()
end

function NewbieGuideView:EndNewbieGuide()
	self:DestroyNewbieGuidePanel()
end
