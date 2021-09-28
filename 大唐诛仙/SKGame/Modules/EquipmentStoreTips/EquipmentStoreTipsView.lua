EquipmentStoreTipsView = BaseClass()

function EquipmentStoreTipsView:__init()
	self:LoadFUIRes()
end

function EquipmentStoreTipsView:__delete()
	if self.equipmentStoreTips then
		self.equipmentStoreTips:Destroy()
		self.equipmentStoreTips = nil
	end
	self.isInited = false
end

function EquipmentStoreTipsView:LoadFUIRes()
	if self.isInited then return end
	resMgr:AddUIAB("EquipmentStoreTipsUI")
	self.isInited = true
end

function EquipmentStoreTipsView:PopupEquipmentStoreTips()
	if self.isInited then
		if self.equipmentStoreTips == nil then
			self.equipmentStoreTips = EquipmentStoreTips.New()
		end
		UIMgr.ShowCenterPopup(self.equipmentStoreTips , function() 
			self.equipmentStoreTips = nil
		end , true)
	end
end