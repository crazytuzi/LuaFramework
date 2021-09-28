require "Core.Info.BaseAttrInfo";
BaseAdvanceAttrInfo = class("BaseAdvanceAttrInfo", BaseAttrInfo);

function BaseAdvanceAttrInfo:New()
	self = {};
	setmetatable(self, {__index = BaseAdvanceAttrInfo});
	self:_InitProperty()
	return self
end

local property = {
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
	'direct_dmg',
	'cd_rdc',
	'phy_pen',
	-- 'mag_pen',
	'phy_bld',
	-- 'mag_bld',
	'phy_bns_rate',
	'phy_bns_per',
	-- 'mag_bns_rate',
	-- 'mag_bns_per',
	'att_dmg_rate',
	'dmg_rate',
	'crit_bonus',
	'fatal_bonus',
	'stun_resist',
	'silent_resist',	
	'still_resist',
	"exp_per"
}

function BaseAdvanceAttrInfo:GetProperty()
	return property
end 