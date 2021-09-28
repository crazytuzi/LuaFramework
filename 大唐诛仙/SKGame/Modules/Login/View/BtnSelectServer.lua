BtnSelectServer = BaseClass(LuaUI)
function BtnSelectServer:__init(...)
	self.URL = "ui://0qk3a0fjgkfb15";
	self:__property(...)
	self:Config()
end

function BtnSelectServer:SetProperty(...)
	
end

function BtnSelectServer:Config()
	
end

function BtnSelectServer:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Login","BtnSelectServer")
	self.bg = self.ui:GetChild("bg")
	self.loaderState = self.ui:GetChild("loaderState")
	self.labelServerName = self.ui:GetChild("labelServerName")
	self.imgSelectServer = self.ui:GetChild("imgSelectServer")
end

function BtnSelectServer.Create(ui, ...)
	return BtnSelectServer.New(ui, "#", {...})
end

function BtnSelectServer:__delete()
end

function BtnSelectServer:SetServerState(url)
	self.loaderState.url = url or ""
end

function BtnSelectServer:SetServerName(name)
	self.labelServerName.text = name or ""
end

function BtnSelectServer:GetServerName()
	return self.labelServerName.text
end

function BtnSelectServer:SetGrayed(bl)
	self.loaderState.grayed = bl
end