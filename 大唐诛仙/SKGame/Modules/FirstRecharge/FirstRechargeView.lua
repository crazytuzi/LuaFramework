FirstRechargeView = BaseClass()

function FirstRechargeView:__init()
	self.panel = nil
end

function FirstRechargeView:Open()
	-- if not self.panel or not self.panel.isInited then
	if not self:GetPanel() then
		self.panel = FRPanel.New()
	end
	self.panel:Open()
end

function FirstRechargeView:__delete()
	if self.panel and self.panel.isInited then 
		self.panel:Destroy()
	end
	self.panel = nil
end

function FirstRechargeView:ClosePanel()
	if self:GetPanel() then
		self.panel:Close()
	end
end

function FirstRechargeView:GetPanel()
	if self.panel and self.panel.isInited then
		return self.panel
	end
	return nil
end