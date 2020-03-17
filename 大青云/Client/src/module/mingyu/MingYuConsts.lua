--[[
玉佩：常量
2015年1月28日10:40:38
haohu
]]

_G.MingYuConsts = {};

-- 玉佩等级上限
local mingYuMaxLvl
function MingYuConsts:GetMaxLevel()
	local maxLvl = 0
	if not mingYuMaxLvl then
		for level, cfg in pairs( _G.t_mingyu ) do
			maxLvl = math.max( level, maxLvl )
		end
		mingYuMaxLvl = maxLvl
	end
	return mingYuMaxLvl
end

-- 熟练度等级上限
--MingYuConsts.MaxLvlProficiency = 5;
MingYuConsts.MaxLvlProficiency = 0;

-- 玉佩属性
MingYuConsts.Attrs = {"att", "def", "cri", "hp", "crivalue", "hit", "dodge", "hpx"};

MingYuConsts.HunAttrs = {"att","def","hp","dodge","hit","cri","defcri"};

MingYuConsts.GroupAttrs = {"dodge","hit","cri","defcri"};

--兵魂背包数量
MingYuConsts.SlotTotalNum = 50;

local m_proficiencyItemDic
function MingYuConsts:GetProficiencyItemDic()
	if not m_proficiencyItemDic then
		m_proficiencyItemDic = {
				[140621056] = true,
				[140621057] = true,
				[140621058] = true
			}
	end
	return m_proficiencyItemDic
end

------------音效-------------
MingYuConsts.SfxProficiencyAdd     = 2040
MingYuConsts.SfxProficiencyLevelUp = 2039
MingYuConsts.SfxLevelUp            = 2040
MingYuConsts.SfxNewWeaponShow      = 2030