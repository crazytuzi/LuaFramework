MainUIView = BaseClass()

function MainUIView:__init()
	self:Config()
	self:InitEvent()
end
--配置
function MainUIView:Config()
	self.model = MainUIModel:GetInstance()
	self.mainPanel = nil
	if self.isInited  then return end
	resMgr:AddUIAB("Main")
	resMgr:AddUIAB("Pkg")
	self.isInited = true
end
--事件监听
function MainUIView:InitEvent()

end
--打开主界面
function MainUIView:OpenMainCityUI()
	if self.mainPanel == nil then
		self.mainPanel =  MainCityUI.New()
		layerMgr:GetUILayer():AddChild(self.mainPanel.ui)
	end
	self.mainPanel:Open()
end
--关闭主界面
function MainUIView:CloseMainCityUI()
	if self.mainPanel then
		self.mainPanel:Close()
	end
end

function MainUIView:GetPanelUI()
	if self:GetPanel() then
		return self:GetPanel().ui
	end
	return nil
end
function MainUIView:GetPanel()
	if self.mainPanel then
		return self.mainPanel
	end
	return nil
end

function MainUIView:__delete()
	if self.mainPanel then
		self.mainPanel:Destroy()
	end
	self.mainPanel = nil
	self.isInited = false
end

function MainUIView:Reset()
	
	if self.mainPanel then
		self.mainPanel:Reset()
	end
end