
RankView =BaseClass()

function RankView:__init()
	if self.isInited then return end
	resMgr:AddUIAB("Rank")
	self.isInited = true
end

function RankView:OpenRankPanel()
	if not self.rankPanel or not self.rankPanel.isInited then
		self.rankPanel = RankPanel.New()
	end
	self.rankPanel:Open()
end 

function RankView:Close()
	if self.rankPanel and self.rankPanel.isInited then
		self.rankPanel:Close()
	end
end 

function RankView:__delete()
	if self.rankPanel and self.rankPanel.isInited then
		self.rankPanel:Destroy()
	end
	self.rankPanel = nil
	self.MallPanel = nil
	self.isInited = false
end