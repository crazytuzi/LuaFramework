ProgressBarCollect =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ProgressBarCollect:__init( ... )
	self.URL = "ui://2bw6ypvmj4usa";
	self:__property(...)
	self:Config()
end

-- Set self property
function ProgressBarCollect:SetProperty( ... )
	
end

-- Logic Starting
function ProgressBarCollect:Config()
	
end

-- Register UI classes to lua
function ProgressBarCollect:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Collect","ProgressBarCollect");

	self.n1 = self.ui:GetChild("n1")
	self.bar = self.ui:GetChild("bar")
end

-- Combining existing UI generates a class
function ProgressBarCollect.Create( ui, ...)
	return ProgressBarCollect.New(ui, "#", {...})
end

-- Dispose use ProgressBarCollect obj:Destroy()
function ProgressBarCollect:__delete()
	
	self.n1 = nil
	self.bar = nil
end