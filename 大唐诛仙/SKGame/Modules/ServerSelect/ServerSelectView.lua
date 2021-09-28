ServerSelectView = BaseClass()

function ServerSelectView:__init()
	self:Config()
end

function ServerSelectView:__delete()
	if self.serverSelectPanel then
		self.serverSelectPanel:Destroy()
	end
	self.serverSelectPanel = nil
end

function ServerSelectView:Config()
	self:Layout()
	self:InitData()	
end

function ServerSelectView:Layout()
	if self.isInited then return end
	resMgr:AddUIAB("ServerSelect")
	self.isInited = true
	self.serverSelectPanel = nil	
end

function ServerSelectView:InitData()
	self.serverSelectPanel = nil
end

function ServerSelectView:OpenServerSelectPanel(accountData)
	if not self.serverSelectPanel or (not self.serverSelectPanel.isInited) then
		self.serverSelectPanel = ServerSelectPanel.New(accountData)
	end
	if self.serverSelectPanel then
		self.serverSelectPanel:Open()
	end
end


