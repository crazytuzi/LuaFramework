
local QHeroModel = import(".QHeroModel")
local QTotemChallengeActorModel = class("QTotemChallengeActorModel", QHeroModel)
local QBuff = import(".QBuff")
--[[
kind:
1:指定队伍死亡后地方全体获取怒气  value = {value = 怒气值, is_teammate = true是己方否则是敌方}
2.指定队伍释放大招后，释放大招的人回复x%的生命值  value:回复的百分比
3.指定队伍死亡后，对敌方全体造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}
4.指定队伍死亡后，对击杀者造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}
5.指定队伍死亡后同时对击杀者造成100%无视护盾无视防御的伤害
6.指定队伍获得，全体增加属性，value = {{属性, 值}, {属性, 值}}这样的数组
7.指定队伍获得:反伤 value = {physical = 物理反伤 ,magic = 法术反伤}
8.指定队伍获得:吸血 value = {physical = 物理吸血 ,magic = 法术吸血}
9.指定英雄增加属性，格式如同6
10.指定英雄免死，只有当队友死干净后才能死
11.指定英雄有队友时无敌
12.指定英雄有队友时反伤, value:反伤的系数
13.指定队伍每x秒获得一个buff, value = {interval=时间间隔, buffId=buff的id}
14.指定队伍每x秒会集火血量最少的敌人,value = {interval=时间间隔, duration=持续时间}
15.指定队伍有人死亡则触发奉献伤害/回血,value = {interval=时间间隔, duration=持续时间, value=系数, type = 1/伤害,2/回血}
16.指定队伍反射一切控制效果, value =  {status1, status2}要反射的status列表
17.指定队伍开场对指定玩家释放一个技能,value=skillId
18.指定队伍获得每击杀一个敌人英雄，降低敌方治疗量, value = 降低的治疗量
19.指定队伍放逐一个最强的敌人x秒, value放逐的时间
20.指定队伍开场降低base点暴击率，每击杀一个英雄，增长value点, value = {base = 基础值, value = 每杀死一个英雄增长的值}
21.指定队伍魔法伤害加深magic%，物理伤害加深physical%, value = {magic = 魔法伤害放大, physical = 物理伤害放大}
22.指定队伍击杀人之后会给己方全体上Buff value = "buffId"
23.指定队伍每隔x秒会给随机半场的敌人上一个buff,value = {interval = 时间间隔, buffId = "buffId"}
24.全场每隔x秒斩杀血量低于execute的英雄,value = {execute = 斩杀的血线, interval = 时间间隔}
25.全场每隔x秒增加value点的伤势,value = {value = 伤势的百分比, interval = 时间间隔}
26.全体被上指定status的buff之后，会再上一个指定id的buff, value = {status = {status1, status2, ...}, buffId = "要上的buffId"}；
27.指定队伍治疗转伤害, value = 治疗转伤害的系数
28.指定队伍受到的治疗翻倍, value = 翻倍的系数 (这个是直接乘以value)
29.指定队伍的AOE与单体伤害翻倍, value = {single = 单体系数, aoe = aoe系数}
--]]

local function increaseHpAndShow(actor, attacker, value, skill, tips)
	local _, dHp = QTotemChallengeActorModel.super.increaseHp(actor, value, attacker, skill, true)
	if dHp > 0 then
		actor:dispatchEvent({name = QTotemChallengeActorModel.UNDER_ATTACK_EVENT, isTreat = true, 
	                isCritical = false, tip = "", rawTip = {
	                    isHero = actor:getType() == ACTOR_TYPES.HERO, 
	                    isCritical = false, 
	                    isTreat = true,
	                    number = dHp,
	                    
	                }, tip_modifiers = tips})
	end

end

local function decreaseHpAndShow(actor, attacker, value, skill, ignoreAbsorb, isExecute, ignoreDamgeLimit, tips)
	local _, damage, absorb = QTotemChallengeActorModel.super.decreaseHp(actor, value, attacker, skill, true, nil, ignoreAbsorb, true, isExecute, nil, ignoreDamgeLimit)
    if absorb > 0 then
        local absorb_tip = "吸收 "
        actor:dispatchEvent({name = QTotemChallengeActorModel.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
            isHero = actor:getType() ~= ACTOR_TYPES.NPC, 
            isDodge = false, 
            isBlock = false, 
            isCritical = false, 
            isTreat = false,
            isAbsorb = true, 
            number = math.ceil(absorb),
        }})
    end
    actor:dispatchEvent({name = QTotemChallengeActorModel.UNDER_ATTACK_EVENT, isTreat = false,
        isCritical = false, tip = "", rawTip = {
            isHero = actor:getType() ~= ACTOR_TYPES.NPC,
            isDodge = false,
            isBlock = false,
            isCritical = false,
            isTreat = false,
            isAbsorb = false,
            number = math.ceil(damage),
        },tip_modifiers = tips})

end

function QTotemChallengeActorModel:ctor(...)
	QTotemChallengeActorModel.super.ctor(self, ...)
end

function QTotemChallengeActorModel:getTotemChallengeAffix()
	return app.battle:getTotemChallengeAffix(self)
end

function QTotemChallengeActorModel:setType(...)
	QTotemChallengeActorModel.super.setType(self, ...)
	--设置好类型后需要重新根据词缀刷一下属性
	self:_applyStaticActorNumberProperties()
end

function QTotemChallengeActorModel:_onKill(event)
	local affix = self:getTotemChallengeAffix()
	if app.battle._startCountDown ~= true then
		return
	end
	QTotemChallengeActorModel.super._onKill(self, event)
	if not app.grid:hasActor(self) then
	    return
    end
	if affix.kind == 1 and affix.triggered ~= true then
		local arr = affix.value.is_teammate and app.battle:getMyTeammates(self, false, true) or app.battle:getMyEnemies(self, true)
		for i,v in ipairs(arr) do
			v:changeRage(affix.value.value)
		end
	end
	if affix.kind == 3 and affix.triggered ~= true then
		local tips = affix.value.ignore_absorb and {"真实伤害"} or nil
		for i,v in ipairs(app.battle:getMyEnemies(self)) do
			decreaseHpAndShow(v, self, affix.value.value * v:getMaxHp(), nil, affix.value.ignore_absorb, false, true, tips)
		end
	end
	if affix.kind == 4 and affix.triggered ~= true and self._totem_last_attacker ~= nil then
		local tips = affix.value.ignore_absorb and {"真实伤害"} or nil
		decreaseHpAndShow(self._totem_last_attacker, self, affix.value.value * self._totem_last_attacker:getMaxHp(), nil, affix.value.ignore_absorb, false, true, tips)
	end
	if affix.kind == 5 and affix.triggered ~= true and self._totem_last_attacker ~= nil and affix.target == self then
		decreaseHpAndShow(self._totem_last_attacker, self, self._totem_last_attacker:getMaxHp(), nil, true, true, nil, {"真实伤害"})
	end
	if affix.kind == 15 and affix.triggered ~= true and affix.inDedicationTime then
		local ops = affix.value
		if ops.type == 1 then
			local actors = app.battle:getMyEnemies(self)
			for i, actor in ipairs(actors) do
				decreaseHpAndShow(actor, self, actor:getMaxHp() * ops.value)
				if affix.effect_buff_id then
					actor:applyBuff(affix.effect_buff_id)
				end
			end
		elseif ops.type == 2 then
			local actors = app.battle:getMyTeammates(self, false, true)
			for i, actor in ipairs(actors) do
				increaseHpAndShow(actor, self, actor:getMaxHp() * ops.value)
				if affix.effect_buff_id then
					actor:applyBuff(affix.effect_buff_id)
				end
			end
		end 
	end
	local enemy_affix = self:getType() == ACTOR_TYPES.NPC and app.battle._totem_challenge_affix_hero or app.battle._totem_challenge_affix_enemy
	if enemy_affix and enemy_affix.kind == 18 and enemy_affix.triggered ~= true and self:isHero() then
		local tab = self:getType() == ACTOR_TYPES.NPC and app.battle._heroTeamSkillProperty or app.battle._enemyTeamSkillProperty
		tab["magic_treat_percent_attack"] = (tab["magic_treat_percent_attack"] or 0) - enemy_affix.value
	end

	if affix and affix.kind == 20 and self:isHero() then
		local tab = self:getType() == ACTOR_TYPES.NPC and app.battle._enemyTeamSkillProperty or app.battle._heroTeamSkillProperty
		tab["critical_chance"] = (tab["critical_chance"] or 0) + affix.value.value
	end

	if enemy_affix and enemy_affix.kind == 22 and enemy_affix.triggered ~= true and self:isHero() and self._totem_last_attacker ~= nil then
		local actor = self
		for i,hero in ipairs(app.battle:getMyEnemies(actor, true)) do
			hero:applyBuff(enemy_affix.value, actor, actor:getTalentSkill())
		end
	end

	if (affix.kind == 10 or affix.kind == 11 or affix.kind == 12) and affix.effect_buff_id and affix.target and affix.target ~= self then
		local teammates = app.battle:getMyTeammates(affix.target, false, true)
		if #teammates == 0 then
			affix.target:removeBuffByID(affix.effect_buff_id)
		end
	end
end

function QTotemChallengeActorModel:increaseHp(hp, attacker, skill, not_add_to_log, ignoreSyncTreat, ...)
	if not app.battle._startCountDown then
		return QTotemChallengeActorModel.super.increaseHp(self, hp, attacker, skill, not_add_to_log, ignoreSyncTreat, ...)
	end
	if self:isExile() then
        return self, 0
    end
	local affix = self:getTotemChallengeAffix()
	if affix.kind == 27 and affix.triggered ~= true then
		if attacker then
			decreaseHpAndShow(self, attacker, hp * affix.value, nil)
		end
		return self, 0
	end
	if affix.kind == 28 and affix.triggered ~= true then
		hp = hp * affix.value
	end
	local result = table.pack(QTotemChallengeActorModel.super.increaseHp(self, hp, attacker, skill, not_add_to_log, ignoreSyncTreat, ...))
	return table.unpack(result)
end

function QTotemChallengeActorModel:decreaseHp(hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute, isBullet, ...)
	if not app.battle._startCountDown then
		return QTotemChallengeActorModel.super.decreaseHp(self, hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute, isBullet, ...)
	end
	if self:isExile() then
		return self, 0, 0, 0
	end
	local affix = self:getTotemChallengeAffix()
	local attacker_affix = attacker and attacker:getTotemChallengeAffix() or {}

	if affix.kind == 11 and (not affix.triggered) and affix.target == self then
		local teammates = app.battle:getMyTeammates(affix.target, false, true)
		local arr = {}
		table.mergeForArray(arr, teammates, function(actor) return not actor:isSupport() end)
		if #arr > 0 then
			self:dispatchEvent({name = QTotemChallengeActorModel.UNDER_ATTACK_EVENT, isTreat = true,
	        isCritical = false, tip = "", rawTip = {
	            isHero = self:getType() ~= ACTOR_TYPES.NPC, 
	        }, tip_modifiers = {"无敌"}})
			return self, 0, 0, 0
		end
	end

	if affix.kind == 12 and (not affix.triggered) and affix.target == self and attacker ~= self and attacker then
		local teammates = app.battle:getMyTeammates(affix.target, false, true)
		local arr = {}
		table.mergeForArray(arr, teammates, function(actor) return not actor:isSupport() end)
		if #arr > 0 then
			decreaseHpAndShow(attacker, self, hp * affix.value, nil, nil, nil, nil, {"反伤"})
			return self, 0, 0, 0
		end
	end

	if attacker_affix.kind == 21 and (not attacker_affix.triggered) and skill then
		local value = attacker_affix.value
		if value.physical and value.physical > 0 and skill:getDamageType() == skill.PHYSICAL then
			hp = hp * (1 + value.physical)
		end
		if value.magic and value.magic > 0 and skill:getDamageType() == skill.MAGIC then
			hp = hp * (1 + value.magic)
		end
	end

	if attacker_affix.kind == 29 and (not attacker_affix.triggered) then
		if isAOE then
			hp = hp * (attacker_affix.value.aoe or 1)
		else
			hp = hp * (attacker_affix.value.single or 1)
		end
	end

	local result = table.pack(QTotemChallengeActorModel.super.decreaseHp(self, hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute, isBullet, ...))
	if affix.kind == 7 and affix.triggered ~= true and skill and attacker and attacker ~= self then
		local value = affix.value
		if value.physical and value.physical > 0 and skill:getDamageType() == skill.PHYSICAL then
			decreaseHpAndShow(attacker, self, hp * value.physical, nil, nil, nil, nil, {"反伤"})
		end
		if value.magic and value.magic > 0 and skill:getDamageType() == skill.MAGIC then
			decreaseHpAndShow(attacker, self, hp * value.magic, nil, nil, nil, nil, {"反伤"})
		end
	end

	if attacker_affix and attacker_affix.kind == 8 and attacker_affix.triggered ~= true and skill and attacker then
		local value = attacker_affix.value
		if value.physical and value.physical > 0 and skill:getDamageType() == skill.PHYSICAL then
			increaseHpAndShow(attacker, self, hp * value.physical, nil, {"吸血"})
		end
		if value.magic and value.magic > 0 and skill:getDamageType() == skill.MAGIC then
			increaseHpAndShow(attacker, self, hp * value.magic, nil, {"吸血"})
		end
	end

	if attacker and attacker ~= self then
		self._totem_last_attacker = attacker
	end
	return table.unpack(result)
end

function QTotemChallengeActorModel:attack(skill, ...)
	local affix = self:getTotemChallengeAffix()
	local result = table.pack(QTotemChallengeActorModel.super.attack(self, skill, ...))
	if affix.kind == 2 and skill == self:getFirstManualSkill() and result[1] ~= nil and affix.triggered ~= true then
		increaseHpAndShow(self, self, self:getMaxHp() * affix.value, nil)
	end
	return table.unpack(result)
end

function QTotemChallengeActorModel:isImmuneDeath(...)
	local affix = self:getTotemChallengeAffix()
	if affix.kind == 10 and affix.triggered ~= true and affix.target == self then
		local teammates = app.battle:getMyTeammates(self, false, true)
		if #teammates > 0 then
			return true
		end
	end
    return QTotemChallengeActorModel.super.isImmuneDeath(self, ...)
end

function QTotemChallengeActorModel:applyBuff(id, attacker, skill, buff, ...)
	local affix = self:getTotemChallengeAffix()
	if affix.kind == 16 and affix.triggered ~= true and attacker then
		local status = affix.status
		if status == nil then
			status = {}
			for i,v in ipairs(affix.value) do
				status[v] = true
			end
			affix.status = status
		end
		local data = db:getBuffByID(id)
		if data and data.status then
			local buff_status = string.split(data.status, ";")
			for i, s in ipairs(buff_status) do
				if status[s] then
					QTotemChallengeActorModel.super.applyBuff(attacker, id, attacker, skill, buff, ...)
					return
				end
			end
		end
	end
	local result = table.pack(QTotemChallengeActorModel.super.applyBuff(self, id, attacker, skill, buff, ...))
	if affix.kind == 26 and affix.triggered ~= true and result[1] then
		local new_buff = result[1]
		for i,v in ipairs(affix.value.status) do
			if new_buff:hasStatus(v) then
				QTotemChallengeActorModel.super.applyBuff(self, affix.value.buff_id, attacker, skill, buff, ...)
				break
			end
		end
	end
	if affix.kind == 27 and affix.triggered ~= true and result[1] then
		local new_buff = result[1]
		local hp = new_buff:getAbsorbDamageValue()
		if attacker and hp > 0 then
			self:removeBuffByInstance(new_buff)
			decreaseHpAndShow(self, attacker, hp * affix.value, nil)
			return
		end
	end
	return table.unpack(result)
end

function QTotemChallengeActorModel:getMaxAttack(...)
	local forceYield = (self:isSupport() or self:getType() ~= ACTOR_TYPES.NPC) and 1 or app.battle:getTotemChallengeForceYield()
	return QTotemChallengeActorModel.super.getMaxAttack(self, ...) * forceYield
end

function QTotemChallengeActorModel:getMaxHp(...)
	local forceYield = (self:isSupport() or self:getType() ~= ACTOR_TYPES.NPC) and 1 or app.battle:getTotemChallengeForceYield()
	return QTotemChallengeActorModel.super.getMaxHp(self, ...) * forceYield
end

function QTotemChallengeActorModel:getPhysicalArmorWithoutSteal(...)
	local forceYield = (self:isSupport() or self:getType() ~= ACTOR_TYPES.NPC) and 1 or app.battle:getTotemChallengeForceYield()
	return QTotemChallengeActorModel.super.getPhysicalArmorWithoutSteal(self, ...) * forceYield
end

function QTotemChallengeActorModel:getMagicArmorWithoutSteal(...)
	local forceYield = (self:isSupport() or self:getType() ~= ACTOR_TYPES.NPC) and 1 or app.battle:getTotemChallengeForceYield()
	return QTotemChallengeActorModel.super.getMagicArmorWithoutSteal(self, ...) * forceYield
end

return QTotemChallengeActorModel
