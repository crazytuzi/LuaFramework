ChatInputPrivate = BaseClass(LuaUI)
function ChatInputPrivate:__init(...)
	self.URL = "ui://jn83skxkeykg1u";
	self:__property(...)
	self:Config()
end
function ChatInputPrivate:SetProperty(...)
	
end
function ChatInputPrivate:Config()
	
end
function ChatInputPrivate:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Gay","ChatInputPrivate");

	self.input = self.ui:GetChild("input")
end
function ChatInputPrivate.Create(ui, ...)
	return ChatInputPrivate.New(ui, "#", {...})
end
function ChatInputPrivate:__delete()
end