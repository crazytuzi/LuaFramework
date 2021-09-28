TaskEffect = BaseClass(LuaUI)
function TaskEffect:__init(...)
	self.URL = "ui://ioaemb0cv8b1q";
	self:__property(...)
	self:Config()
end

function TaskEffect:SetProperty(...)
	
end

function TaskEffect:Config()
	self:InitData()
	self.effectModel:SetPosition(666 , 232 , 0)
end

function TaskEffect:InitData()
	self.completeEffectObj = nil
end

function TaskEffect:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Task","TaskEffect");
	self.effectModel = self.ui:GetChild("effectModel")
	if self.effectModel then
		layerMgr:GetMSGLayer():AddChild(self.effectModel)
	end
end

function TaskEffect.Create(ui, ...)
	return TaskEffect.New(ui, "#", {...})
end

function TaskEffect:__delete()
	self:DisposeEffect()
	self.effectModel = nil
end

function TaskEffect:ShowCompleteEffect()
	local callback = function (effect)
		if self.completeEffectObj then
			destroyImmediate(self.completeEffectObj)
		end

		local effectObj = GameObject.Instantiate(effect)
		effectObj.transform.localPosition = Vector3.New(1, 1, 1)
		effectObj.transform.localScale = Vector3.New(1, 1, 1)
		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.effectModel:SetNativeObject(GoWrapper.New(effectObj))
		self.completeEffectObj = effectObj
	end

	if self.effectModel then
		LoadEffect("4300" , callback)
	end
end

function TaskEffect:DisposeEffect()
	if self.completeEffectObj ~= nil then
		destroyImmediate(self.completeEffectObj)
	end
	self.completeEffectObj = nil
end

