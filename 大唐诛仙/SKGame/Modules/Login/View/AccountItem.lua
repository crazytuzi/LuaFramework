AccountItem = BaseClass(LuaUI)

function AccountItem:__init(...)
	self.URL = "ui://0qk3a0fjj2mzt";
	self:__property(...)
	self:Config()
end

function AccountItem:SetProperty(...)
	
end

function AccountItem:Config()
	self:InitUI()
	self:InitData()
	self:InitEvent()
end

function AccountItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Login","AccountItem")
	self.button = self.ui:GetController("button")
	self.bg = self.ui:GetChild("bg")
	self.bgSelected = self.ui:GetChild("bgSelected")
	self.title = self.ui:GetChild("title")
	self.btnDelete = self.ui:GetChild("btnDelete")
end

function AccountItem.Create(ui, ...)
	return AccountItem.New(ui, "#", {...})
end

function AccountItem:__delete()
end

function AccountItem:InitUI()

end

function AccountItem:InitData()
	--临时测试
	self.accountData = {}
	self.model = LoginModel:GetInstance()
end

function AccountItem:InitEvent()
	self.btnDelete.onClick:Add(function ()
		self.model:DeleteAccount(self.accountData)
	end)
end

function AccountItem:CleanEvent()
	self.btnDelete.onClick:Clear()
end

function AccountItem:SetData(data)
	self.accountData = data or {}
end

function AccountItem:GetData()
	return self.accountData
end

function AccountItem:SetUI()
	if not TableIsEmpty(self.accountData) then
		local userName = ""
		if self.accountData.isVisitor == true then
			userName = StringFormat("{0} {1}" , "游客" , self.accountData.userName)
		else
			userName = self.accountData.userName
		end
		self.title.text = userName
	end
end