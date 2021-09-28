WorldMapView = BaseClass()

function WorldMapView:__init()
	resMgr:AddUIAB("WorldMaps")
	self.isInited = true
end

function WorldMapView:Open(ind)
	--if self.panel == nil or (not self.panel.isInited) then 
		if ind == 0 then
			self.panel = SecondMapPanel.New()                 --WorldMapPanel.New()
		else
			self.panel = WorldMapPanel.New()
		end
	--end
	self.panel:Open()
	if ind == 1 then
		self.panel:Refresh()
	end
end

function WorldMapView:__delete()
	self.isInited = false
	if self.panel then
		self.panel:Destroy()
	end
	self.panel = nil
end