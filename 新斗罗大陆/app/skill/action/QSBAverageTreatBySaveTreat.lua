local QSBAction = import(".QSBAction")
local QSBAverageTreatBySaveTreat = class("QSBAverageTreatBySaveTreat", QSBAction)
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

local function isNpc(actor)
    return actor and actor:getType() == ACTOR_TYPES.NPC
end

function QSBAverageTreatBySaveTreat:_execute(dt)
	local buff_id = self._options.buff_id
	if not buff_id then
		self:finished()
		return
	end
    if self._skill then
        self._skill._ignore_save_treat = true
    end
	local damage = 0
	for i, buff in ipairs(self._attacker:getBuffs()) do
		if buff:getId() == buff_id and buff:isSaveTreat() then
            local use_save = buff:getSaveTreat() * (self._options.coefficient or 1)
			damage = damage + use_save
            buff:reduceSaveTreat(use_save)
		end
	end

    damage = damage / 2

	if damage <= 0 then
		self:finished()
		return
	end

    local over_treat = damage
    local teammates = nil 
    local enemies = nil 
    if self._options.in_skill_range then
        local actors = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition(), nil, nil, nil, true)
        teammates = {}
        enemies = {}
        local attacker_is_npc = isNpc(self._attacker)
        for i,actor in ipairs(actors) do
            if attacker_is_npc then
                if isNpc(actor) then
                    table.insert(teammates, actor)
                else
                    table.insert(enemies, actor)
                end
            else
                if isNpc(actor) then
                    table.insert(enemies, actor)
                else
                    table.insert(teammates, actor)
                end
            end
        end
    else
        teammates = app.battle:getMyTeammates(self._attacker, true, true)
        enemies = app.battle:getMyEnemies(self._attacker)
    end

    if teammates == nil or enemies == nil then
        self:finished()
        return
    end

    table.sort( teammates, function(a, b)
        return a:getHp()/a:getMaxHp() < b:getHp()/b:getMaxHp()
    end)

    local meanHp = function(team, count, value, tab)
        local total = 0
        for i = 1, count do
            total = total + team[i]:getMaxHp()
        end
        for i = 1, count do
            if not tab[i] then tab[i] = 0 end
            tab[i] = tab[i] + (team[i]:getMaxHp()/total)*value
        end
    end

    local count = #teammates
    local damageTab = {}
    for i = 2, count do
        local actor1, actor2 = teammates[i-1], teammates[i]
        local percent1, percent2 = actor1:getHp()/actor1:getMaxHp(), actor2:getHp()/actor2:getMaxHp()
        local delta = (percent2 - percent1)
        local total = 0
        for j = 1, i - 1 do
            local deltaValue = delta * teammates[j]:getMaxHp()
            total = total + deltaValue
        end
        if damage >= total then
            for j = 1, i - 1 do
                local deltaValue = delta * teammates[j]:getMaxHp()
                if not damageTab[j] then
                    damageTab[j] = 0
                end
                damageTab[j] = damageTab[j] + deltaValue
            end
            damage = damage - total
        else
            meanHp(teammates, i-1, damage, damageTab)
            damage = 0
            break
        end
    end
    if damage > 0 then
        meanHp(teammates, #teammates, damage, damageTab)
    end


    for index, actor in ipairs(teammates) do
        if damageTab[index] then
            local real_treat = math.min(actor:getMaxHp(), damageTab[index])
            -- over_treat = over_treat - real_treat
            local _, dHp = actor:increaseHp(real_treat, self._attacker, self._skill)
            if dHp > 0 then
                actor:dispatchEvent({name = actor.UNDER_ATTACK_EVENT, isTreat = true, 
                        isCritical = false, tip = "", rawTip = {
                            isHero = actor:getType() ~= ACTOR_TYPES.NPC, 
                            isCritical = false, 
                            isTreat = true,
                            number = dHp,
                        }})
            end
        end
    end

    if over_treat > 0 then
    	
    	if #enemies > 0 then
    		local damage = over_treat * (self._options.damage_coefficient or 1)
    		for i, actor in ipairs(enemies) do
                if not self:isDeflection(self._attacker, actor) then
                    if not self._options.ignore_damage_percent_attack then
                        damage = self:getDamage(self._attacker, actor, damage)
                    end
                    damage = damage * self:getDragonModifier()
        			local _, value, absorb = actor:decreaseHp(damage, self._attacker, self._skill, false, true)
                    if absorb > 0 then
                        local absorb_tip = "吸收 "
                        actor:dispatchEvent({name = actor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                            isHero = actor:getType() ~= ACTOR_TYPES.NPC, 
                            isDodge = false, 
                            isBlock = false, 
                            isCritical = false, 
                            isTreat = false,
                            isAbsorb = true, 
                            number = absorb
                        }})
                    end
                    if value > 0 then
                        local tip = ""
                        actor:dispatchEvent({name = actor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tip .. tostring(math.floor(value)),
                            rawTip = {
                                isHero = actor:getType() ~= ACTOR_TYPES.NPC, 
                                isDodge = false, 
                                isBlock = false, 
                                isCritical = false, 
                                isTreat = false, 
                                number = value
                            }})
                    end
                end
    		end
    	end
    end

    self:finished()
end

-- 加成系数不能比1小
function QSBAverageTreatBySaveTreat:getDamage(attacker, attackee, damage)
    local damageType = self._skill:getDamageType()
    local coef = 1
    if app.battle:isPVPMode() then
        if damageType == QSkill.PHYSICAL then
            coef = math.max(1 + attacker:getPVPPhysicalAttackPercent() - attackee:getPVPPhysicalReducePercent(), 0)
        elseif damageType == QSkill.MAGIC then
            coef = math.max(1 + attacker:getPVPMagicAttackPercent() - attackee:getPVPMagicReducePercent(), 0)
        end
    else
        coef = math.max((1 + attacker:getPVEDamagePercentAttack() - attackee:getPVEDamagePercentBeattack()), 0)
    end
    coef = math.min(coef, 1)
    damage = damage * coef

    return damage
end

return QSBAverageTreatBySaveTreat
