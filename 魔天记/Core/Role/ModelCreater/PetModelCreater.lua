require "Core.Role.ModelCreater.BaseModelCreater"
PetModelCreater = class("PetModelCreater", BaseModelCreater);

function PetModelCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = PetModelCreater});
	
	if(asyncLoad ~= nil) then
		self.asyncLoadSource = asyncLoad
	else
		self.asyncLoadSource = false
	end
	self.onLoadedSource = onLoadedSource
	self.showShadow = true
	
	self:Init(data, parent);
	return self;
end

--
function PetModelCreater:_Init(data)
	self.model_id = data.model_id
    self.model_effect = data.model_effect
end

function PetModelCreater:_GetModern()
	return "Roles", tostring(self.model_id)
end

function PetModelCreater:GetModeEffectId()
    return self.model_effect
end

function PetModelCreater:_GetSourceDir()
	return "Pets"
end

function PetModelCreater:_GetModelDefualt()
	return "n_mgz001";
end

