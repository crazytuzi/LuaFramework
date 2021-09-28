--物品采集相关表现资源的初始化和创建
CollectView  =BaseClass()

function CollectView:__init()
	self:Config()
	self:InitUIRes()
	self:InitEvent()
end

function CollectView:Config()
	self.loadingCollectItemPanel = nil
	self.loadingBackToCityPanel = nil
end

function CollectView:InitUIRes()
	if self.isInited then return end
	resMgr:AddUIAB("Collect")
	self.isInited = true
end

function CollectView:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if CollectView.inst ~= nil then
			self:Reset()
		end
	end)
end

function CollectView:Reset()
	if self.loadingCollectItemPanel ~= nil then
		self.loadingCollectItemPanel:Destroy()
	end
	self.loadingCollectItemPanel = nil

	if self.loadingBackToCityPanel ~= nil then
		self.loadingBackToCityPanel:Destroy()
	end
	self.loadingBackToCityPanel = nil
end

function CollectView:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function CollectView:GetInstance()
	if CollectView.inst == nil then
		CollectView.inst = CollectView.New()
	end

	return CollectView.inst
end

function CollectView:OpenLoadingBackToCityPanel()
	
	if not self.loadingBackToCityPanel or not self.loadingBackToCityPanel.isInited  then
		self.loadingBackToCityPanel = LoadingBackToCityPanel.New()
	end

	if self.loadingBackToCityPanel then
		self.loadingBackToCityPanel:Open()
		self.loadingBackToCityPanel:SetCenter()
		self.loadingBackToCityPanel.ui.y = self.loadingBackToCityPanel.ui.y + 128
		self.loadingBackToCityPanel:SetUI()
	end

end

function CollectView:OpenLoadingCollectItemPanel()
	

	if self.loadingCollectItemPanel then
		self.loadingCollectItemPanel:Destroy()
	end

	self.loadingCollectItemPanel = LoadingCollectItem.New()
	self.loadingCollectItemPanel:AddTo(layerMgr:GetUILayer())
	self.loadingCollectItemPanel:SetCenter()
	self.loadingCollectItemPanel.ui.y = self.loadingCollectItemPanel.ui.y + 64
	self.loadingCollectItemPanel:SetUI()

	return self.loadingCollectItemPanel
end


function CollectView:__delete()
	self:CleanEvent()

	if self.loadingCollectItemPanel ~= nil then
		self.loadingCollectItemPanel:Destroy()
	end
	self.loadingCollectItemPanel = nil

	if self.loadingBackToCityPanel ~= nil then
		self.loadingBackToCityPanel:Destroy()
	end
	self.loadingBackToCityPanel = nil
	self.isInited = false
	CollectView.inst = nil
end