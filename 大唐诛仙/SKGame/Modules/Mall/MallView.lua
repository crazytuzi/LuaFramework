
MallView =BaseClass()

function MallView:__init()
	MallView.LoadAB()
end

MallView.isInited = false
function MallView.LoadAB()
	if MallView.isInited then return end
	resMgr:AddUIAB("Mall")
	MallView.isInited = true
end

function MallView:GetInstance()
	if MallView.inst == nil then
		MallView.inst = MallView.New()
	end
	return MallView.inst 
end

function MallView:OpenMallPanel(marketId, index, mallTabId, closeCallBack)
	if not self.mainPane or not self.mainPane.isInited then
		self.mainPane = MallCommonPanel.New(marketId, mallTabId)
	end
	self.mainPane:Refresh()

	if marketId then
		self.mainPane:LocationItem(marketId)
	else
		if mallTabId then
			self.mainPane:LocationTab(mallTabId)
		end
	end
	self.mainPane:SetCloseCallBack(closeCallBack)
	self.mainPane:Open(index)
end 

function MallView:Close()
	if self.mainPane and self.mainPane.isInited then
		self.mainPane:Close()
	end
end 

function MallView:__delete()
	if self.mainPane and self.mainPane.isInited then
		self.mainPane:Destroy()
	end
	self.mainPane= nil
	MallView.inst = nil
	self.isInited = false
end