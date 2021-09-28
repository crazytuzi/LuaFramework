RegistModules("GongGao/view/GgMainPanel")
RegistModules("GongGao/GgModel")
RegistModules("GongGao/GgConst")

RegistModules("GongGao/view/GgOpenServerPanel")
RegistModules("GongGao/view/GgUpadatePanel")
RegistModules("GongGao/view/GgRealNamePanel")


GgController = BaseClass(LuaController)
function GgController:__init()
	self:Config()
	self:InitEvent()
end

function GgController:Config()
	self.model = GgModel:GetInstance()
	self.view = nil
end

function GgController:GetInstance()
	if not GgController.inst  then
		GgController.inst = GgController.New()
	end
	return GgController.inst

end

function GgController:Open()
	resMgr:AddUIAB("GongGao")
	self:GetMainPanel():Open()
end

function GgController:InitEvent()
end

function GgController:GetMainPanel()
	if not self:IsExistView() then
		self.view = GgMainPanel.New()
	end
	return self.view
end

-- 判断主面板是否存在
function GgController:IsExistView()
	return self.view and self.view.isInited
end

function GgController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler)
	if self:IsExistView() then
		self:GetMainPanel():Destroy()
	end
	GgController.inst = nil
	 self.view= nil
	 if self.model then
	 self.model:Destroy()
	 self.model = nil
	end
end