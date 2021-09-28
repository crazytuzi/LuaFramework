ChatInput = BaseClass(LuaUI)
function ChatInput:__init(...)
	self.URL = "ui://m2d8gld1cdsbk";
	self:__property(...)
	self:Config()
end
function ChatInput:SetProperty(...)
	
end
function ChatInput:Config()
	
end
function ChatInput:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","ChatInput");

	self.n0 = self.ui:GetChild("n0")
	self.input = self.ui:GetChild("input")
end
function ChatInput.Create(ui, ...)
	return ChatInput.New(ui, "#", {...})
end
function ChatInput:__delete()
end