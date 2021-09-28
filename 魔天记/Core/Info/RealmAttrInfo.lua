require "Core.Info.BaseAttrInfo"


local RealmAttrInfo = class("RealmAttrInfo", BaseAttrInfo);
local property = {
	'hp_max',
	'mp_max',
	'phy_att', 
	'phy_def', 
	'hit',
	'eva',
	'crit',
	'tough',
	'fatal',
	'block'
}

function RealmAttrInfo:New()
	self = {};
	setmetatable(self, {__index = RealmAttrInfo});
	self:_InitProperty()
	return self;
end

function RealmAttrInfo:GetProperty()
	return property
end 

return RealmAttrInfo