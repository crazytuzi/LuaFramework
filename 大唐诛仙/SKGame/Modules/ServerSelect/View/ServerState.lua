ServerState = BaseClass(LuaUI)
function ServerState:__init(...)
	self.URL = "ui://csn9w87suq4w7";
	self:__property(...)
	self:Config()
end
function ServerState:SetProperty(...)
	
end
function ServerState:Config()
	
end
function ServerState:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ServerSelect","ServerState");

	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
end
function ServerState.Create(ui, ...)
	return ServerState.New(ui, "#", {...})
end
function ServerState:__delete()
end