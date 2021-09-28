ProgressBarBackToCity =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ProgressBarBackToCity:__init( ... )
	self.URL = "ui://2bw6ypvmj4usc";
	self:__property(...)
	self:Config()
end

-- Set self property
function ProgressBarBackToCity:SetProperty( ... )
	
end

-- Logic Starting
function ProgressBarBackToCity:Config()
	
end

-- Register UI classes to lua
function ProgressBarBackToCity:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Collect","ProgressBarBackToCity");

	self.n1 = self.ui:GetChild("n1")
	self.bar = self.ui:GetChild("bar")
end

-- Combining existing UI generates a class
function ProgressBarBackToCity.Create( ui, ...)
	return ProgressBarBackToCity.New(ui, "#", {...})
end

-- Dispose use ProgressBarBackToCity obj:Destroy()
function ProgressBarBackToCity:__delete()
	
	self.n1 = nil
	self.bar = nil
end
