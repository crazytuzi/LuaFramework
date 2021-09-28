RegistModules("EquipmentStoreTips/EquipmentStoreTipsModel")
RegistModules("EquipmentStoreTips/EquipmentStoreTipsView")
RegistModules("EquipmentStoreTips/View/EquipmentStoreTips")
RegistModules("EquipmentStoreTips/EquipmentStoreTipsConst")

EquipmentStoreTipsController = BaseClass(LuaController)

function EquipmentStoreTipsController:__init()
	self:Config()
	self:InitEvent()
end

function EquipmentStoreTipsController:__delete()
	self:CleanEvent()
	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	if self.view then
		self.view:Destroy()
		self.view = nil
	end
	
end

function EquipmentStoreTipsController:GetInstance()
	if EquipmentStoreTipsController.inst == nil then
		EquipmentStoreTipsController.inst = EquipmentStoreTipsController.New()
	end
	return EquipmentStoreTipsController.inst
end

function EquipmentStoreTipsController:Config()
	self.model = EquipmentStoreTipsModel:GetInstance()
	self.view = EquipmentStoreTipsView.New()
end

function EquipmentStoreTipsController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
			self:CheckPopup()
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end

		if self.handler0 == nil then
			self.handler0 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
				self:CheckPopup()
			end)
		end
	end)
end

function EquipmentStoreTipsController:CleanEvent()
	if self.handler0 then
		GlobalDispatcher:RemoveEventListener(self.handler0)
	end
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function EquipmentStoreTipsController:PopupEquipmentStoreTips()
	if self.view then
		self.view:PopupEquipmentStoreTips()
		GlobalDispatcher:RemoveEventListener(self.handler0)
		self.handler0 = nil
	end
end

function EquipmentStoreTipsController:CheckPopup()
	local isCan = self.model:IsCanPopup()
	if isCan then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.EquipmentStoreTips, show = true, openCb = self.PopupEquipmentStoreTips, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.EquipmentStoreTips, show = false, isClose = false})
	end
end