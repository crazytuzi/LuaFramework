local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local Mconvertor = require "src/config/convertor"
----------------------------------------------------------------------------
-- 属性价值表
local tAttrWorth= getConfigItemByKey("AttrBattleDB", "q_job")
-- 获取一个装备的所有信息
local AttrWorthItem = function(job)
	return tAttrWorth[job]
end

----------------------------------------------------------------------------
-- 幸运法则
isLucky = function(self, luck)
	-- 幸运值默认值为 0
	local luck = luck or 0

	-- 幸运值必定是一个整数, 且取值范围为 [0, 9]
	--assert( (luck % 1 == 0) and (luck >= 0 and luck <= 9) )

	-- 当幸运值为0时
	if luck == 0 then return end

	-- 当幸运值为 [1, 9] 时
	-- 在 [1, 10 - luck] 中生成一个随机值
	return math.random(10 - luck) == 1
end
----------------------------------------------------------------------------
-- 伤害计算方法
--[[
	伤害值 = (基础攻击值 + 附加攻击值) * (1 + 攻击加成值) - 防御值
--]]
calcHurtSingle = function(self, params)
	local ret = nil

	local base = params.base or 0
	local addition = params.addition or 0
	local gain = params.gain or 0
	local defense = params.defense or 0
	
	--dump({base = base, addition = addition, gain = gain, defense = defense,}, "calcHurtSingle")

	ret = (base + addition) * gain - defense
	ret = math.floor( math.max(ret, 0) )

	return ret
end

calcHurtRange = function(self, params)

	--dump(params, "calcHurtRange")

	local base = params.base
	if type(base) == "table" then
		local lower, upper = base["["] or 0, base["]"] or 0
		if lower == upper then
			params.base = lower
		else
			params.base = self:isLucky(params.luck) and upper or math.random(lower, upper)
		end
	end

	local defense = params.defense
	if type(defense) == "table" then
		params.defense = math.random(defense["["] or 0, defense["]"] or 0)
	end

	return self:calcHurtSingle(params)
end
----------------------------------------------------------------------------
-- 战斗力计算方法
--[[
	战斗力 = 攻击属性值 * 攻击属性价值 + 	                -- 1 职业攻击
	         物理防御属性值 * 物理防御属性价值 + 			-- 2 物理防御
			 魔法防御属性值 * 魔法防御属性价值 + 			-- 3 魔法防御
			 生命属性值 * 生命属性价值 + 					-- 4 生命
			 幸运属性值 * 幸运属性价值 + 					-- 5 幸运
			 命中属性值 * 命中属性价值 + 					-- 6 命中
			 闪避属性值 * 闪避属性价值 + 					-- 7 闪避
			 幸运属性值 * 幸运属性价值 +                    -- 8 幸运
			 暴击属性值 * 暴击属性价值 +                    -- 9 暴击
			 韧性属性值 * 韧性属性价值 +                    -- 10 韧性
			 护身穿透属性值 * 护身穿透属性价值 +            -- 11 护身穿透
			 护身属性值 * 护身属性价值 +                    -- 12 护身
			 冰冻属性值 * 冰冻属性价值 +                    -- 13 冰冻
			 冰冻抵抗属性值 * 冰冻抵抗属性价值 +            -- 14 冰冻抵抗
			 技能带来战斗力
	技能带来的战斗力 = 所有技能的战斗力之和
	玩家的技能包括：职业技能，坐骑拥有技能，美人拥有的技能，翅膀拥有的技能。
--]]

calcCombatPowerSingle = function(self, params)
	--dump(params, "params")
	local ret = 0
	-------------------------------------------
	local school = params.school or 0 		-- 职业
	local values = AttrWorthItem(school) 	-- 职业价值
	if not values then return 0 end
	-------------------------------------------
	-- 职业攻击
	local attack = params.attack or 0

	-- 物理防御
	local pDefense = params.pDefense or 0

	-- 魔法防御
	local mDefense = params.mDefense or 0

	-- 生命
	local hp = params.hp or 0
	
	-- 幸运
	local luck = math.max(params.luck or 0, 0)

	-- 命中
	local hit = params.hit or 0

	-- 闪避
	local dodge = params.dodge or 0
	
	-- 暴击
	local strike = params.strike or 0
	
	-- 韧性
	local tenacity = params.tenacity or 0
	
	-- 护身穿透
	local hu_shen_rift = params.hu_shen_rift or 0
	
	-- 护身
	local hu_shen = params.hu_shen or 0
	
	-- 冰冻
	local freeze = params.freeze or 0
	
	-- 冰冻抵抗
	local freeze_oppose = params.freeze_oppose or 0
	--dump({pDefense=pDefense, q_defence=values.q_defence}, "+++++++++++")
	-------------------------------------------
	--[[
	dump(attack * ((tonumber(values.q_attack) or 0)+(tonumber(values.q_magic_attack) or 0)+(tonumber(values.q_sc_attack) or 0)), "attack")
	dump(pDefense * (tonumber(values.q_defence) or 0), "pDefense")
	dump(mDefense * (tonumber(values.q_magic_defence) or 0), "mDefense")
	dump(hp * (tonumber(values.q_max_hp) or 0), "hp")
	dump(luck * (tonumber(values.q_luck) or 0), "luck")
	dump(hit * (tonumber(values.q_hit) or 0), "hit")
	dump(dodge * (tonumber(values.q_dodge) or 0), "dodge")
	dump(strike * (tonumber(values.q_crit) or 0), "strike")
	dump(tenacity * (tonumber(values.q_tenacity) or 0), "tenacity")
	dump(hu_shen_rift * (tonumber(values.q_projectDef) or 0), "hu_shen_rift")
	dump(hu_shen * (tonumber(values.q_project) or 0), "hu_shen")
	dump(freeze * (tonumber(values.q_benumb) or 0), "freeze")
	dump(freeze_oppose * (tonumber(values.q_benumbDef)), "freeze_oppose")
	--]]
	
	ret = attack * ((tonumber(values.q_attack) or 0)+(tonumber(values.q_magic_attack) or 0)+(tonumber(values.q_sc_attack) or 0)) + 
	      pDefense * (tonumber(values.q_defence) or 0) + 
		  mDefense * (tonumber(values.q_magic_defence) or 0) + 			
		  math.floor(hp * (tonumber(values.q_max_hp) or 0)) + 
		  luck * (tonumber(values.q_luck) or 0) + 
		  hit * (tonumber(values.q_hit) or 0) + 
		  dodge * (tonumber(values.q_dodge) or 0) + 
		  strike * (tonumber(values.q_crit) or 0) + 
		  tenacity * (tonumber(values.q_tenacity) or 0) + 
		  hu_shen_rift * (tonumber(values.q_projectDef) or 0) + 
		  hu_shen * (tonumber(values.q_project) or 0) + 
		  freeze * (tonumber(values.q_benumb) or 0) + 
		  freeze_oppose * (tonumber(values.q_benumbDef) or 0)
	-------------------------------------------
	-- 技能
	local skill = params.skill
	if type(skill) == "table" then
		local skills = nil

		if type(skill[1]) == "table" then
			skills = skill
		else
			skills = {}
			skills[1] = skill.id and skill or nil
		end

		local skillArea = 0
		local MskillOp = require "src/config/skillOp"
		--dump(skills, "skills")
		
		local incCombatPower = nil
		for i, v in ipairs(skills) do
			incCombatPower = MskillOp:incCombatPower(v.id, v.lv)
			
			if not incCombatPower then
				local id, lv = v.id, v.lv
				local all = MskillOp:combatAttr(id, lv, "all")
				incCombatPower = self:calcCombatPowerRange(
				{
					school = school,
					attack = all[Mconvertor:schoolAttack(school)],
					pDefense = all[Mconvertor.ePDefense],
					mDefense = all[Mconvertor.eMDefense],
					hp = MskillOp:maxHP(id, lv),
					luck = MskillOp:luck(id, lv),
					hit = MskillOp:hit(id, lv),
					dodge = MskillOp:dodge(id, lv),
					strike = MskillOp:strike(id, lv),
					tenacity = MskillOp:tenacity(id, lv),
					hu_shen_rift = MskillOp:huShenRift(id, lv),
					hu_shen = MskillOp:huShen(id, lv),
					freeze = MskillOp:freeze(id, lv),
					freeze_oppose = MskillOp:freezeOppose(id, lv),
				})
			end
			
			skillArea = skillArea + incCombatPower
		end

		ret = ret + skillArea
	end
	-------------------------------------------

	ret = math.floor( math.max(ret, 0) )
	--dump(ret, "ret:")
	return ret
end

local calcAverageValue = function(t)
	if type(t) == "table" then
		local lower, upper = t["["] or 0, t["]"] or 0
		if lower == upper then
			return true, lower
		else
			return true, math.floor((lower + upper) / 2)
		end
	else
		return false
	end
end

calcCombatPowerRange = function(self, params)
	local modify, value

	local tModify = {
		"attack",		-- 职业攻击
		"pDefense",		-- 物理防御
		"mDefense",		-- 魔法防御
	}
	--dump(params, "params")
	for i = 1, #tModify do
		local field = tModify[i]
		modify, value = calcAverageValue(params[field])
		if modify then params[field] = value end
	end

	return self:calcCombatPowerSingle(params)
end