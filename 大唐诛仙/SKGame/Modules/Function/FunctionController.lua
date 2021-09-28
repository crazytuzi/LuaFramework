RegistModules("Function/FunctionConst")
RegistModules("Function/FunctionModel")
RegistModules("Function/FunctionView")


FunctionController =BaseClass(LuaController)

function FunctionController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function FunctionController:__delete()
	FunctionController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

function FunctionController:Config()
	self.model = FunctionModel:GetInstance()
	self.view = FunctionView.New()
end

function FunctionController:InitEvent()

end

function FunctionController:RegistProto()

end

function FunctionController:GetInstance()
	if FunctionController.inst == nil then
		FunctionController.inst = FunctionController.New()
	end
	return FunctionController.inst
end

function FunctionController:OpenModuleUI(data)
	
	if data and self.view then
		self.view:OpenModuleUI(data)
	end
end