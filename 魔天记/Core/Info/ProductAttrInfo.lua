require "Core.Info.BaseAttrInfo";


ProductAttrInfo = class("ProductAttrInfo", BaseAttrInfo);
local property =
{
	'hp_max',
	'mp_max',
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
	'phy_pen',
	'direct_dmg',
}

function ProductAttrInfo:New()
	self = {};
	setmetatable(self, {__index = ProductAttrInfo});
	self:_InitProperty()
	return self;
end

function ProductAttrInfo:GetProperty()
	return property
end 