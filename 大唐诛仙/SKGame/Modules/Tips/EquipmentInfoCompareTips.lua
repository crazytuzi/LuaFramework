EquipmentInfoCompareTips =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function EquipmentInfoCompareTips:__init( ... )
	self.URL = "ui://ixdopynlfqe0c";
	self:__property(...)
	self:Config()
end

-- Set self property
function EquipmentInfoCompareTips:SetProperty( ... )
	
end

-- Logic Starting
function EquipmentInfoCompareTips:Config()
	
end

-- Register UI classes to lua
function EquipmentInfoCompareTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","EquipmentInfoCompareTips");

	self.SkepEquip = self.ui:GetChild("SkepEquip")
	self.PlayerEquip = self.ui:GetChild("PlayerEquip")
end

-- Combining existing UI generates a class
function EquipmentInfoCompareTips.Create( ui, ...)
	return EquipmentInfoCompareTips.New(ui, "#", {...})
end

-- Dispose use EquipmentInfoCompareTips obj:Destroy()
function EquipmentInfoCompareTips:__delete()
	
	self.SkepEquip = nil
	self.PlayerEquip = nil
end