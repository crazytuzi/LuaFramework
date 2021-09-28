require "Core.Info.BaseAttrInfo";


RideBaseInfo = class("RideBaseInfo", BaseAttrInfo);
local property = {
	'hp_max', 
	'phy_att',
	-- 'mag_att',
	'phy_def',
	-- 'mag_def',
	'hit',
	'eva',
	'crit',
	'tough',
	'fatal',
	'block',
	'exp_per',
	'dmg_rate'
} 

function RideBaseInfo:New()
	self = {};
	setmetatable(self, {__index = RideBaseInfo});
	self:_InitProperty()
	return self;
end

function RideBaseInfo:GetProperty()
	return property
end 