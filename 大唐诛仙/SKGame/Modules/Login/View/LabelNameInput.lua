LabelNameInput =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function LabelNameInput:__init( ... )
	self.URL = "ui://5gey1uxru2sk11";
	self:__property(...)
	self:Config()
end

-- Set self property
function LabelNameInput:SetProperty(curRoleInfo)
	self:UpdateRoleInfo(curRoleInfo)
end

-- Logic Starting
function LabelNameInput:Config()
	self:InitData()
end

function LabelNameInput:InitData()
	self.curRandomName = self.label_name.text
end

function LabelNameInput:UpdateRoleInfo(curRoleInfo)
	self.curRoleInfo = curRoleInfo or {}
end

-- Register UI classes to lua
function LabelNameInput:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RoleCreateSelect","LabelNameInput")
	self.image_bg = self.ui:GetChild("image_bg")
	self.label_name = self.ui:GetChild("label_name")
end

-- Combining existing UI generates a class
function LabelNameInput.Create( ui, ...)
	return LabelNameInput.New(ui, "#", {...})
end

function LabelNameInput:SetUI()
	self:SetRandomUI()
end

function LabelNameInput:SetRandomUI()
	-- body
	if table.nums(self.curRoleInfo) > 0 then
		self.curRandomName = getRandomName(self.curRoleInfo.sex)
		self.label_name.text = self.curRandomName;
	end
end

function LabelNameInput:GetRandomName()
	return self.label_name.text
end

-- Dispose use LabelNameInput obj:Destroy()
function LabelNameInput:__delete()
	
	self.image_bg = nil
	self.label_name = nil
end