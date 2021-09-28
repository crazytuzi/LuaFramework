ButtonSkillItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ButtonSkillItem:__init( ... )
	self.URL = "ui://5gey1uxru2skx";
	self:__property(...)
	self:Config()
end

-- Set self property
function ButtonSkillItem:SetProperty( iconId )
	self.iconId = iconId or nil
end

-- Logic Starting
function ButtonSkillItem:Config()
	--self:InitEvent()
end

-- Register UI classes to lua
function ButtonSkillItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RoleCreateSelect","ButtonSkillItem");

	self.button = self.ui:GetController("button")
	self.image_skill_border = self.ui:GetChild("image_skill_border")
	self.icon = self.ui:GetChild("icon")
end

function ButtonSkillItem:InitEvent()
	self.icon.onClick:Add(self.OnSkillItemBtnClick, self)
end

function ButtonSkillItem:SetUI()
	if self.iconId ~= nil then
		self.ui.icon = string.format("Icon/Skill/%s", self.iconId or "")
	end
end

function ButtonSkillItem:OnSkillItemBtnClick()
end


-- Combining existing UI generates a class
function ButtonSkillItem.Create( ui, ...)
	return ButtonSkillItem.New(ui, "#", {...})
end

-- Dispose use ButtonSkillItem obj:Destroy()
function ButtonSkillItem:__delete()
	self.icon.onClick:RemoveEvent(self.OnSkillItemBtnClick, self)
	self.button = nil
	self.image_skill_border = nil
end