local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------
local tPotency = getConfigItemByKey("PotencyDB", "q_itemID")

-- 获取一条记录
record = function(self, id)
	return tPotency[id]
end
-----------------------------------------------------------------------------
school = function(self, id)
	local item = self:record(id)
	return item and item.q_school
end

kind = function(self, id)
	local item = self:record(id)
	return item and item.q_type
end
-----------------------------------------------------------------------------
local tCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = self:record(id)
		if record then
			return (record.q_attack_min or 0), (record.q_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = self:record(id)
		if record then
			return (record.q_magic_attack_min or 0), (record.q_magic_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = self:record(id)
		if record then
			return (record.q_sc_attack_min or 0), (record.q_sc_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(self, id)
		-- 默认值[0, 0]
		local record = self:record(id)
		if record then
			return (record.q_defence_min or 0), (record.q_defence_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(self, id)
		-- 默认值[0, 0]
		local record = self:record(id)
		if record then
			return (record.q_magic_defence_min or 0), (record.q_magic_defence_max or 0)
		else
			return 0, 0
		end
	end,
}

-- 基础战斗属性值
combatAttr = function(self, id, name)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tCombatAttrAction[name](self, id)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tCombatAttrAction[v](self, id)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end
--------------------------------------------------------
-- 增加HP上限
maxHP = function(self, id)
	-- 默认值为0
	local record = self:record(id)
	return (record and record.q_max_hp) or 0
end

-- 增加幸运值
luck = function(self, id)
	-- 默认值为0
	local record = self:record(id)
	return (record and record.q_luck) or 0
end

-- 增加命中
hit = function(self, id)
	-- 默认值为0
	local record = self:record(id)
	return (record and record.q_hit) or 0
end

-- 增加闪避
dodge = function(self, id)
	-- 默认值为0
	local record = self:record(id)
	return (record and record.q_dodge) or 0
end