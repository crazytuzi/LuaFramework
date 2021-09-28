local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local Mconvertor = require "src/config/convertor"
-----------------------------------------------------------------------------------
-- 怪物表
local tMonster = getConfigItemByKey("monster", "q_id")
-- 获取一个怪物的所有信息
local monsterItem = function(id)
	--cclog("怪物id " .. id)
	return tMonster[id]
end
--------------------------------------------------------------------------------------
-- 怪物攻击类型
attackType = function(self, id)
	local item = monsterItem(id)
	return item.q_attackType + 1
end

local tCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = monsterItem(id)
		if record then
			return (record.q_attack_min or 0), (record.q_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = monsterItem(id)
		if record then
			return (record.q_magic_attack_min or 0), (record.q_magic_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eTAttack] = function(self, id)
		-- 默认值[0, 0]
		local record = monsterItem(id)
		if record then
			return (record.q_dc_attack_min or 0), (record.q_dc_attack_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.ePDefense] = function(self, id)
		-- 默认值[0, 0]
		local record = monsterItem(id)
		if record then
			return (record.q_defense_min or 0), (record.q_defense_max or 0)
		else
			return 0, 0
		end
	end,
	
	[Mconvertor.eMDefense] = function(self, id)
		-- 默认值[0, 0]
		local record = monsterItem(id)
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
-------------------------------------------------------------
--------------------------------------------------------------------------------------

