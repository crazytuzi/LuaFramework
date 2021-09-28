	
AccountView =BaseClass()

function AccountView:__init()
	if self.isInited then return end
	resMgr:AddUIAB("Account")
	self.isInited = true
end

function AccountView:GetAccountPanel()
	if not self.accountPanel or not self.isInited then
		self.accountPanel = AccountPanel.New()
	end
	return self.accountPanel
end 

function AccountView:__delete()
	if self.accountPanel then
		self.accountPanel:Destroy()
	end
	self.accountPanel = nil
	self.isInited = false
end