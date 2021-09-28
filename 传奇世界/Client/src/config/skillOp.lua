local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------------
-- 技能等级表
local tSkillLevel = getConfigItemByKey("SkillLevelCfg", "skillID")
local tSkill = getConfigItemByKey("SkillCfg", "skillID")
-- 获取一个特定等级的技能的所有信息
local skillLvItem = function(id, lv)
	--cclog("技能等级id " .. id)
	return tSkillLevel[id * 1000 + lv]
end
-----------------------------------------------------------------------------------
-- 技能加成攻击力值
additionalAttack = function(self, id, lv)
	local item = skillLvItem(id, lv)
	return (item and item.addAtk) or 0
end

-- 技能加伤万分比
attackGain = function(self, id, lv)
	local item = skillLvItem(id, lv)
	local gain = item and item.addHurtPre
	return gain or 0
end

-- 技能增加的战斗力
incCombatPower = function(self, id, lv)
	local item = skillLvItem(id, lv)
	return item and item.jnzdl
end


-- 技能升级消耗真气值
upgradeVital = function(self, id, lv)
	local item = skillLvItem(id, lv)
	return (item and item.needVital) or 0
end

-- 技能冷却值
skillCoolTime = function(self, id, lv)
	local item = skillLvItem(id, lv)
	return (item and item.coolTime) or 0
end

--------------------------------------------------------------------------------------
local tCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(self, id, lv)
		-- 默认值[0, 0]
		local record = skillLvItem(id, lv)
		if record then
			return (record.wg2 or 0), (record.wg21 or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(self, id, lv)
		-- 默认值[0, 0]
		local record = skillLvItem(id, lv)
		if record then
			return (record.ml2 or 0), (record.ml21 or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(self, id, lv)
		-- 默认值[0, 0]
		local record = skillLvItem(id, lv)
		if record then
			return (record.ds2 or 0), (record.ds21 or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(self, id, lv)
		-- 默认值[0, 0]
		local record = skillLvItem(id, lv)
		if record then
			return (record.wf2 or 0), (record.wf21 or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(self, id, lv)
		-- 默认值[0, 0]
		local record = skillLvItem(id, lv)
		if record then
			return (record.mf2 or 0), (record.mf21 or 0)
		else
			return 0, 0
		end
	end,
}

-- 基础战斗属性值
combatAttr = function(self, id, lv, name)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tCombatAttrAction[name](self, id, lv)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tCombatAttrAction[v](self, id, lv)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end
-------------------------------------------------------------
-- 最大HP
maxHP = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.sms2) or 0
end

-- 增加MP上限
maxMP = function(self, id, lv)
	-- 默认值为0
	return 0
end

-- 增加幸运值
luck = function(self, id, lv)
	return 0
end

-- 命中值
hit = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.mz2) or 0
end

-- 闪避值
dodge = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.sb2) or 0
end

-- 增加暴击
strike = function(self, id, lv)
	return 0
end

-- 增加韧性
tenacity = function(self, id, lv)
	return 0
end

-- 护身穿透
huShenRift = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.hs21) or 0
end

-- 护身
huShen = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.hs2) or 0
end

-- 冰冻
freeze = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.mb2) or 0
end

-- 冰冻抵抗
freezeOppose = function(self, id, lv)
	-- 默认值为0
	local record = skillLvItem(id, lv)
	return (record and record.mb21) or 0
end

--当前职业所有职业技能
allSkills = function(self)
	local skills = {}
	for k,v in pairs(tSkill) do
		if v.job and v.useType and v.jnfenlie and v.job == G_ROLE_MAIN.school and 1 == v.useType and 1 == v.jnfenlie then --and 1 == v.q_jieduan then
			table.insert(skills,{v.skillID,v.q_order})
		end
	end
	return skills
end

--当前职业所有光翼技能
allWingSkills = function(self)
	local wingSkills = {}
	for k,v in pairs(tSkill) do
		if v.job and v.jnfenlie and (v.job == 0 or v.job == G_ROLE_MAIN.school ) and 7 == v.jnfenlie then
			table.insert(wingSkills,{v.skillID,v.learnLv})
		end
	end
	return wingSkills
end

--------------------------------------------------------------------------------------


