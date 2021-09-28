AccountContent = BaseClass(LuaUI)

function AccountContent:__init(...)
	self.URL = "ui://0qk3a0fjj2mzu";
	self:__property(...)
	self:Config()
end

function AccountContent:SetProperty(...)
	
end

function AccountContent:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function AccountContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Login","AccountContent")
	self.c1 = self.ui:GetController("c1")
	self.content = self.ui:GetChild("content")
end

function AccountContent.Create(ui, ...)
	return AccountContent.New(ui, "#", {...})
end

function AccountContent:__delete()
	self:DisposeAccountItemUIList()
end

function AccountContent:InitUI()

end

function AccountContent:InitData()
	self.accountItemUIList = {}
	self.accountList = {}
	self.model = LoginModel:GetInstance()
end

function AccountContent:InitEvent()
	self.content.onClickItem:Add(function ()
		self:OnAccountItemClick()
	end)
end

function AccountContent:SetData()
	self.accountList = self.model:GetAccountList()
	table.sort(self.accountList , function (a , b)
		return tonumber(a.time) > tonumber(b.time)
	end)
end

function AccountContent:SetUI()
	for index = 1, #self.accountList do
		local oldAccountItem = self:GetAccountItemByIndex(index)						
		local curAccountItem = {}
		local curAccountData = self.accountList[index]
		if not TableIsEmpty(oldAccountItem) then
			curAccountItem = oldAccountItem
		else
			curAccountItem = AccountItem.New()
			table.insert(self.accountItemUIList , curAccountItem)
		end
		self.content:AddChild(curAccountItem.ui)
		curAccountItem:SetData(curAccountData)
		curAccountItem:SetUI()
	end
end

function AccountContent:GetAccountItemByIndex(index)
	return self.accountItemUIList[index] or {}
end

function AccountContent:OnAccountItemClick()
	local curAccountData = self.accountItemUIList[self.content.selectedIndex + 1]:GetData()
	self.model:DispatchEvent(LoginConst.SelectAccountItem , curAccountData)
end

function AccountContent:DisposeAccountItemUIList()
	for index = 1 , #self.accountItemUIList do
		if not TableIsEmpty(self.accountItemUIList[index]) then
			self.accountItemUIList[index]:Destroy()
		end
	end
	self.accountItemUIList = nil
end
