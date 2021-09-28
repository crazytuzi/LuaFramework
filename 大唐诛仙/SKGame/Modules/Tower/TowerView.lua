TowerView = BaseClass()

function TowerView:__init()
	if self.isInited then return end 
	resMgr:AddUIAB("Tower")
	self.isInited = true
	self.vPanel = nil   --胜利界面
	self.fPanel = nil   --失败界面
end

--打开胜利界面
function TowerView:OpenVictoryPanel()
	if not self.vPanel or not self.vPanel.isInited then 
		self.vPanel = VictorySettlePanel.New()
	end
	self.vPanel:Open()
end

--打开失败界面
function TowerView:OpenFailPanel()
	if not self.fPanel or not self.fPanel.isInited then 
		self.fPanel = FailSettlePanel.New()
	end
	self.fPanel:Open()
end

function TowerView:__delete()
	self.isInited = false 
	if self.vPanel then
		self.vPanel:Destroy()
	end
	self.vPanel = nil

	if self.fPanel then
		self.fPanel:Destroy()
	end
	self.fPanel = nil   --失败界面
end