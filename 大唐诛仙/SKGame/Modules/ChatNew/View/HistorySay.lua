HistorySay = BaseClass(LuaUI)

function HistorySay:__init(...)
	self.URL = "ui://m2d8gld1rfrr1t";
	self:__property(...)
	self:Config()
end

function HistorySay:SetProperty(...)
	
end

function HistorySay:Config()
	
end

function HistorySay:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","HistorySay");

	self.bg = self.ui:GetChild("bg")
	self.content = self.ui:GetChild("content")
end

function HistorySay.Create(ui, ...)
	return HistorySay.New(ui, "#", {...})
end

function HistorySay:SetData(data)
	self.data = data
	self.content.text = self.data

	self.ui.onClick:Add(self.OnHistoryClick, self)
end

function HistorySay:OnHistoryClick(context)
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.SelectHistory, self.data)
end

function HistorySay:__delete()
	self.data = nil
end