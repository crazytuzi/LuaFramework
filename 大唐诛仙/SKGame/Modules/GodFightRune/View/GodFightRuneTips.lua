GodFightRuneTips = BaseClass(LuaUI)
function GodFightRuneTips:__init( ... )
	self.URL = "ui://s210esy7k3tlo";
	self:__property(...)
	self:Config()
end
-- Set self property
function GodFightRuneTips:SetProperty( ... )
end
-- start
function GodFightRuneTips:Config()
	
end
-- wrap UI to lua
function GodFightRuneTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("GodFightRune","GodFightRuneTips");

	self.labelSkillName = self.ui:GetChild("labelSkillName")
	self.labelDesc = self.ui:GetChild("labelDesc")

end
-- Combining existing UI generates a class
function GodFightRuneTips.Create( ui, ...)
	return GodFightRuneTips.New(ui, "#", {...})
end

function GodFightRuneTips:__delete()
end

function GodFightRuneTips:SetContent(strName , strDesc)
	self.labelSkillName.text = strName or ""
	self.labelDesc.text = strDesc or ""
end