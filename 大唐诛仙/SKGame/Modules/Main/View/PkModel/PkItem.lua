PkItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function PkItem:__init( ... )
	self.URL = "ui://0042gnitnv56db";
	self:__property(...)
	self:Config()
end

-- Set self property
function PkItem:SetProperty( ... )
	
end

-- Logic Starting
function PkItem:Config()
	
end

-- Register UI classes to lua
function PkItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PkItem");

	self.n0 = self.ui:GetChild("n0")
	self.model = self.ui:GetChild("model")
	self.desc = self.ui:GetChild("desc")

	self:InitEvent()
	self.modelType = 0
	self.data = 0
end

function PkItem:InitEvent()
	self.ui.onClick:Add(self.onClickHandler, self)
end

function PkItem:RemoveEvent()
	self.ui.onClick:Remove(self.onClickHandler, self)
end

function PkItem:onClickHandler()
	SceneModel:GetInstance():SetRolePKModel(self.modelType)
	GlobalDispatcher:DispatchEvent(EventName.PkModelChange, {self.modelType})
	if self.modelType == 5 then
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function PkItem:SetType(modelType)
	self.modelType = modelType
 	local data = GetCfgData("pkmodel"):Get(self.modelType)
 	if data then
	 	self.data = data
	 	self.model.color = newColorByString("#"..data.color)
	 	self.model.text = data.name
	 	self.desc.text = data.des
 	end
end

-- Combining existing UI generates a class
function PkItem.Create( ui, ...)
	return PkItem.New(ui, "#", {...})
end

-- Dispose use PkItem obj:Destroy()
function PkItem:__delete()
	self:RemoveEvent()
	
	self.n0 = nil
	self.model = nil
	self.desc = nil
end