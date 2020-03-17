--[[
宝甲：常量
2015年1月28日10:40:38
haohu
]]

_G.ArmorConsts = {};

-- 宝甲等级上限
local armorMaxLvl
function ArmorConsts:GetMaxLevel()
	local maxLvl = 0
	if not armorMaxLvl then
		for level, cfg in pairs( _G.t_newbaojia ) do
			maxLvl = math.max( level, maxLvl )
		end
		armorMaxLvl = maxLvl
	end
	return armorMaxLvl
end

-- 熟练度等级上限
ArmorConsts.MaxLvlProficiency = 5;

-- 宝甲属性
ArmorConsts.Attrs = {"att", "def", "cri", "hp", "crivalue", "defcri", "subcri"};

ArmorConsts.HunAttrs = {"att","def","hp","dodge","hit","cri","defcri"};

ArmorConsts.GroupAttrs = {"dodge","hit","cri","defcri"};

--兵魂背包数量
ArmorConsts.SlotTotalNum = 50;

local m_proficiencyItemDic
function ArmorConsts:GetProficiencyItemDic()
	if not m_proficiencyItemDic then
		m_proficiencyItemDic = {
				[150300407] = true,
				[150300408] = true,
				[150300409] = true,
				[150300410] = true,
			}
	end
	return m_proficiencyItemDic
end

------------音效-------------
ArmorConsts.SfxProficiencyAdd     = 2040
ArmorConsts.SfxProficiencyLevelUp = 2039
ArmorConsts.SfxLevelUp            = 2040
ArmorConsts.SfxNewWeaponShow      = 2030