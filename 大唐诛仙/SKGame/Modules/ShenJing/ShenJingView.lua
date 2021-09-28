ShenJingView = BaseClass()

function ShenJingView:__init()
	if self.isInited then return end 
	resMgr:AddUIAB("ShenJing")
	self.panel = nil   --胜利界面
end

function ShenJingView:OpenShenJingPanel()
	-- if not self.panel or not self.panel.isInited then
	if not self:GetShenjingPanel() then
		self.panel = ShenJingPanel.New()
	end
	self.panel:Open()
end

function ShenJingView:__delete()
	if self.panel and self.panel.isInited then 
		self.panel:Destroy()
	end
	self.panel = nil
end

function ShenJingView:CloseShenJingPanel()
	if self:GetShenjingPanel() then
		self.panel:Close()
	end
end

function ShenJingView:GetShenjingPanel()
	if self.panel and self.panel.isInited then
		return self.panel
	end
	return nil
end