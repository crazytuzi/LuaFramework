RoleSkillTips =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function RoleSkillTips:__init( ... )
	self.URL = "ui://ixdopynlvl9cy";
	self:__property(...)
	self:Config()
end

-- Set self property
function RoleSkillTips:SetProperty( ... )
	
end

-- Logic Starting
function RoleSkillTips:Config()
	
end

-- Register UI classes to lua
function RoleSkillTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","RoleSkillTips");

	self.img_bg = self.ui:GetChild("img_bg")
	self.label_skill_name = self.ui:GetChild("label_skill_name")
	self.label_skill_desc = self.ui:GetChild("label_skill_desc")
end

-- Combining existing UI generates a class
function RoleSkillTips.Create( ui, ...)
	return RoleSkillTips.New(ui, "#", {...})
end

function RoleSkillTips:SetData(name, desc)
	self.name = name or ""
	self.desc = desc or ""
end

function RoleSkillTips:SetUI()
	self.label_skill_name.text = self.name
	self.label_skill_desc.text = self.desc
end

-- Dispose use RoleSkillTips obj:Destroy()
function RoleSkillTips:__delete()
	
	self.img_bg = nil
	self.label_skill_name = nil
	self.label_skill_desc = nil
end