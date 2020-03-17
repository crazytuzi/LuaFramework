--[[
神兵：常量
2015年1月28日10:40:38
haohu
]]

_G.MagicWeaponConsts = {};

-- 神兵等级上限
local magicWeaponMaxLvl
function MagicWeaponConsts:GetMaxLevel()
	local maxLvl = 0
	if not magicWeaponMaxLvl then
		for level, cfg in pairs( _G.t_shenbing ) do
			maxLvl = math.max( level, maxLvl )
		end
		magicWeaponMaxLvl = maxLvl
	end
	return magicWeaponMaxLvl
end

-- 熟练度等级上限
MagicWeaponConsts.MaxLvlProficiency = 5;

-- 神兵属性
MagicWeaponConsts.Attrs = {"att", "def", "cri", "hp", "crivalue"};

MagicWeaponConsts.HunAttrs = {"att","def","hp","dodge","hit","cri","defcri"};

MagicWeaponConsts.GroupAttrs = {"dodge","hit","cri","defcri"};

--兵魂背包数量
MagicWeaponConsts.SlotTotalNum = 50;

local proficiencyItemDic
function MagicWeaponConsts:GetProficiencyItemDic()
	if not proficiencyItemDic then
		proficiencyItemDic = {
				[152005001] = true,
				[152005002] = true,
				[152005003] = true,
				[152005004] = true,
			}
	end
	return proficiencyItemDic
end

------------音效-------------
MagicWeaponConsts.SfxProficiencyAdd     = 2040
MagicWeaponConsts.SfxProficiencyLevelUp = 2039
MagicWeaponConsts.SfxLevelUp            = 2040
MagicWeaponConsts.SfxNewWeaponShow      = 2030