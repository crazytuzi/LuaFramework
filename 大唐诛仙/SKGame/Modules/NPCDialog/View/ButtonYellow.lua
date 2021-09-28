ButtonYellow = BaseClass(LuaUI)
function ButtonYellow:__init(...)
	self.URL = "ui://0tyncec1tfo1do";
	self:__property(...)
	self:Config()
end
function ButtonYellow:SetProperty(...)
	
end
function ButtonYellow:Config()
	self:InitData()
end
function ButtonYellow:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","ButtonYellow");

	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
end
function ButtonYellow.Create(ui, ...)
	return ButtonYellow.New(ui, "#", {...})
end
function ButtonYellow:__delete()
end

function ButtonYellow:InitData()
	self.data = {}
end

function ButtonYellow:SetData(data)
	self.data = data or {}
end

function ButtonYellow:GetData()
	return self.data
end

function ButtonYellow:SetUI(data)
	self.title.text = data or ""
end