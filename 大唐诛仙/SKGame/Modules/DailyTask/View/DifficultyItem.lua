DifficultyItem = BaseClass(LuaUI)
function DifficultyItem:__init(...)
	self.URL = "ui://1m5molo6kftjh";
	self:__property(...)
	self:Config()
end

function DifficultyItem:SetProperty(...)
	
end

function DifficultyItem:Config()
	
end

function DifficultyItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","DifficultyItem");
	self.loaderBG = self.ui:GetChild("loaderBG")
	self.labelDifficulty = self.ui:GetChild("labelDifficulty")
end

function DifficultyItem.Create(ui, ...)
	return DifficultyItem.New(ui, "#", {...})
end

function DifficultyItem:__delete()

end

function DifficultyItem:SetUI(bgURL, desc)
	if bgURL and desc then
		self.loaderBG.url = bgURL
		self.labelDifficulty.text = desc
	end
end