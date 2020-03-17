--[[
法宝：常量
2015年1月28日10:40:38
haohu
]]

_G.LingQiConsts = {};

-- 法宝等级上限
local lingQiMaxLvl
function LingQiConsts:GetMaxLevel()
	local maxLvl = 0
	if not lingQiMaxLvl then
		for level, cfg in pairs(_G.t_lingqi) do
			maxLvl = math.max(level, maxLvl)
		end
		lingQiMaxLvl = maxLvl
	end
	return lingQiMaxLvl
end

-- 熟练度等级上限
--LingQiConsts.MaxLvlProficiency = 5;
LingQiConsts.MaxLvlProficiency = 0;

-- 法宝属性
LingQiConsts.Attrs = { "att", "def", "hp", "hit", "dodge", "absatt" };

LingQiConsts.HunAttrs = { "att", "def", "hp", "dodge", "hit", "cri", "defcri" };

LingQiConsts.GroupAttrs = { "dodge", "hit", "cri", "defcri" };

--兵魂背包数量
LingQiConsts.SlotTotalNum = 50;

local l_proficiencyItemDic
function LingQiConsts:GetProficiencyItemDic()
	if not l_proficiencyItemDic then
		l_proficiencyItemDic = {
			[140621056] = true,
			[140621057] = true,
			[140621058] = true
		}
	end
	return l_proficiencyItemDic
end

------------ 音效-------------
LingQiConsts.SfxProficiencyAdd = 2040
LingQiConsts.SfxProficiencyLevelUp = 2039
LingQiConsts.SfxLevelUp = 2040
LingQiConsts.SfxNewWeaponShow = 2030