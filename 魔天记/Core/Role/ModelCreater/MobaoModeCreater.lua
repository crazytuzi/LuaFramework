require "Core.Role.ModelCreater.BaseModelCreater"
MobaoModeCreater = class("MobaoModeCreater", BaseModelCreater);

function MobaoModeCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = MobaoModeCreater});
	
	if(asyncLoad ~= nil) then
		self.asyncLoadSource = asyncLoad
	else
		self.asyncLoadSource = true
	end
	self.onLoadedSource = onLoadedSource
	
	self:Init(data, parent);
	
	return self;
end

function MobaoModeCreater:_Init(data)
	self.model_id = data.model_id
end

function MobaoModeCreater:GetCheckAnimation()
	return false
end


function MobaoModeCreater:_GetModern()
	return "Equip/Trump", tostring(self.model_id)
end


function MobaoModeCreater:_GetModelDefualt()
	return "trump_htj"
end

function MobaoModeCreater:_OnModelLoaded()
	if not IsNil(self._role) then
		self._transform = self._role.transform
		if self.checkAnimation then self:_InitAnimation() end
		self:_SetSelfLayer()	
		self:_UpdateActive();
	end
end

