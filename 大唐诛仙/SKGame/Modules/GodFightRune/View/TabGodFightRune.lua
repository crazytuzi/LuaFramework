TabGodFightRune = BaseClass(LuaUI)

function TabGodFightRune:__init(...)
	self.URL = "ui://s210esy7iug37";
	self:__property(...)
	self:Config()
end

function TabGodFightRune:SetProperty(...)
	
end

function TabGodFightRune:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function TabGodFightRune:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("GodFightRune","TabGodFightRune")
	self.c1 = self.ui:GetController("c1")
	self.btnAll = self.ui:GetChild("btnAll")
	self.btnLv1 = self.ui:GetChild("btnLv1")
	self.btnLv2 = self.ui:GetChild("btnLv2")
	self.btnLv3 = self.ui:GetChild("btnLv3")
end

function TabGodFightRune.Create(ui, ...)
	return TabGodFightRune.New(ui, "#", {...})
end

function TabGodFightRune:__delete()
end

function TabGodFightRune:InitData()
	self.model = GodFightRuneModel:GetInstance()
end

function TabGodFightRune:InitUI()
end

function TabGodFightRune:InitEvent()
	self.c1.onChanged:Add(function ()
		self:OnControllerChanged()
	end)
end

function TabGodFightRune:OnControllerChanged()
	self.model:DispatchEvent(GodFightRuneConst.OnTypeSelect , self.c1.selectedIndex)
end