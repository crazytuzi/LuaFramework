local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------------
-- 角色属性表
local tRole = getConfigItemByKeys("roleData", {
	"q_zy",
	"q_level",
})

roleItem = function(self, school, level)
	--dump({ school = school, level = level })
	local tSchool = tRole[school]
	return tSchool and tSchool[level]
end
-----------------------------------------------------------------------------------
-- 物理攻击
PAttack = function(self, school, level)
	-- 默认值[0, 0]
	local item = self:roleItem(school, level)
	if item then
		return (item.q_attack_min or 0), (item.q_attack_max or 0)
	else
		return 0, 0
	end
end

-- 物理防御
PDefense = function(self, school, level)
	-- 默认值[0, 0]
	local item = self:roleItem(school, level)
	if item then
		return (item.q_defense_min or 0), (item.q_defense_max or 0)
	else
		return 0, 0
	end
end

-- 魔法攻击
MAttack = function(self, school, level)
	-- 默认值[0, 0]
	local item = self:roleItem(school, level)
	if item then
		return (item.q_magic_attack_min or 0), (item.q_magic_attack_max or 0)
	else
		return 0, 0
	end
end

-- 魔法防御
MDefense = function(self, school, level)
	-- 默认值[0, 0]
	local item = self:roleItem(school, level)
	if item then
		return (item.q_magic_defence_min or 0), (item.q_magic_defence_max or 0)
	else
		return 0, 0
	end
end

-- 道术攻击
TAttack = function(self, school, level)
	-- 默认值[0, 0]
	local item = self:roleItem(school, level)
	if item then
		return (item.q_dc_attack_min or 0), (item.q_dc_attack_max or 0)
	else
		return 0, 0
	end
end
-----------------------------------------------------------------------------------
-- 升级所需经验值
upLevelExpNeed = function(self, school, level)
	-- 占位值为1亿
	local item = self:roleItem(school, level)
	return (item and item.q_exp) or 100000000
end

-- 最大HP
maxHP = function(self, school, level)
	-- 占位值为1亿
	local item = self:roleItem(school, level)
	return (item and item.q_hp) or 100000000
end

-- 最大MP
maxMP = function(self, school, level)
	-- 占位值为1亿
	local item = self:roleItem(school, level)
	return (item and item.q_mp) or 100000000
end

-- 幸运值
luck = function(self, school, level)
	-- 默认值为0
	local item = self:roleItem(school, level)
	return (item and item.q_luck) or 0
end

-- 命中值
hit = function(self, school, level)
	-- 默认值为0
	local item = self:roleItem(school, level)
	return (item and item.q_hit) or 0
end

-- 暴击值
strike = function(self, school, level)
	-- 默认值为0
	local item = self:roleItem(school, level)
	return (item and item.q_crit) or 0
end

-- 闪避值
dodge = function(self, school, level)
	-- 默认值为0
	local item = self:roleItem(school, level)
	return (item and item.q_dodge) or 0
end

-- 移动速度
moveSpeed = function(self, school, level)
	-- 默认值为0
	local item = self:roleItem(school, level)
	return (item and item.q_move_speed) or 0
end

--角色最高等级
highestLv = function(self)
	local a = tRole[1]
	return table.maxn(a)
end