StarItem = BaseClass(LuaUI)
function StarItem:__init(...)
	self.URL = "ui://1m5molo6kftji";
	self:__property(...)
	self:Config()
end

function StarItem:SetProperty(...)
	
end

function StarItem:Config()
	
end

function StarItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","StarItem");

	self.loaderBG = self.ui:GetChild("loaderBG")
	self.loaderStar = self.ui:GetChild("loaderStar")
end

function StarItem.Create(ui, ...)
	return StarItem.New(ui, "#", {...})
end

function StarItem:__delete()
end

function StarItem:SetUI(bgURL, starURL)
	if bgURL and starURL then
		self.loaderBG.url = bgURL
		self.loaderStar.url = starURL
	end
end