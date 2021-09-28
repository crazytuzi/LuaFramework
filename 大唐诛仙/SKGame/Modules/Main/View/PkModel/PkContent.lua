PkContent =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function PkContent:__init( ... )
	self.URL = "ui://0042gnitnv56d9";
	self:__property(...)
	self:Config()
end

-- Set self property
function PkContent:SetProperty( ... )
	
end

-- Logic Starting
function PkContent:Config()
	
end

-- Register UI classes to lua
function PkContent:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PkContent");

	self.n1 = self.ui:GetChild("n1")
	self.m1 = self.ui:GetChild("m1")
	self.m2 = self.ui:GetChild("m2")
	self.m3 = self.ui:GetChild("m3")
	self.m4 = self.ui:GetChild("m4")
	self.m5 = self.ui:GetChild("m5")

	self.m1 = PkItem.Create(self.m1)
	self.m2 = PkItem.Create(self.m2)
	self.m3 = PkItem.Create(self.m3)
	self.m4 = PkItem.Create(self.m4)
	self.m5 = PkItem.Create(self.m5)
	
	self.m1:SetType(1)
	self.m2:SetType(2)
	self.m3:SetType(3)
	self.m4:SetType(4)
	self.m5:SetType(5)
end

-- Combining existing UI generates a class
function PkContent.Create( ui, ...)
	return PkContent.New(ui, "#", {...})
end

-- Dispose use PkContent obj:Destroy()
function PkContent:__delete()
	self.m1:Destroy()
	self.m5:Destroy()
	self.m4:Destroy()
	self.m2:Destroy()
	self.m3:Destroy()
	
	self.n1 = nil
	self.m1 = nil
	self.m5 = nil
	self.m4 = nil
	self.m2 = nil
	self.m3 = nil
end