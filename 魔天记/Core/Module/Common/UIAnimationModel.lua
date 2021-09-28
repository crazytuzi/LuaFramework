require "Core.Role.ModelCreater.PetModelCreater"

UIAnimationModel = class("UIAnimationModel")

function UIAnimationModel:New(data, parent, creater)
	self = {};
	setmetatable(self, {__index = UIAnimationModel});
	self:Init(data, parent, creater);
	return self;
end

function UIAnimationModel:Init(data, parent, creater)
	if(parent == nil) then
		log("parent为空")
	end
	self.creater = creater or PetModelCreater
	self:ChangeModel(data, parent)
end

function UIAnimationModel:Dispose()
	self._roleCreater:Dispose()
	self._roleCreater = nil
end

function UIAnimationModel:ChangeModel(data, parent) 
	if(self._roleCreater ~= nil) then
		if(data.model_id ~= self._roleCreater.model_id) then
			self._roleCreater:Dispose()
			self._roleCreater = nil
		end
	end
	if(self._roleCreater == nil) then		
		self._roleCreater = self.creater:New(data, parent)
		self._roleCreater:SetLayer(Layer.UIModel)	 
		self:SyncParticleSystemScale()
	end
end

function UIAnimationModel:ChangeWing(data)
	if(self._roleCreater) then
		if(self._roleCreater.dress.w ~= data.w) then
			self._roleCreater.dress.w = data.w
			self._roleCreater:ChangeWing()
		end
	end
end


function UIAnimationModel:SyncParticleSystemScale()
	if self._roleCreater then self._roleCreater:SyncParticleSystemScale() end
end

function UIAnimationModel:SetScale(scale)
	if(self._roleCreater) then
		self._roleCreater:SetScale(scale)
	end
end

function UIAnimationModel:SetRotation(rotation)
	if(self._roleCreater) then
		self._roleCreater:SetRotation(rotation)
	end
end

function UIAnimationModel:Play(name)
	if(self._roleCreater) then
		self._roleCreater:Play(name)
	end
end 