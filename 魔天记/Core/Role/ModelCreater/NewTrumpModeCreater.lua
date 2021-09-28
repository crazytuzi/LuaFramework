require "Core.Role.ModelCreater.BaseModelCreater"
NewTrumpModeCreater = class("NewTrumpModeCreater", BaseModelCreater);

function NewTrumpModeCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = NewTrumpModeCreater});
	
	if(asyncLoad ~= nil) then
		self.asyncLoadSource = asyncLoad
	else
		self.asyncLoadSource = true
	end
	self.onLoadedSource = onLoadedSource
	
	self:Init(data, parent);
	
	return self;
end

function NewTrumpModeCreater:_Init(data)
	self.model_id = data.configData.model_id
end

function NewTrumpModeCreater:GetCheckAnimation()
	return false
end


function NewTrumpModeCreater:_GetModern()
	return "Equip/Trump", tostring(self.model_id)
end


function NewTrumpModeCreater:_GetModelDefualt()
	return "trump_htj"
end

function NewTrumpModeCreater:_OnModelLoaded()
	if not IsNil(self._role) then
		self._transform = self._role.transform
		if self.checkAnimation then self:_InitAnimation() end
		self:_SetSelfLayer()	
		self:_UpdateActive();
	end
end

