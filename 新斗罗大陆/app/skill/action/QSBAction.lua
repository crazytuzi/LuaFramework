--[[
    Class name QSBAction
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBAction = class("QSBAction", QSBNode)

function QSBAction:ctor(director, attacker, target, skill, options)
    QSBAction.super.ctor(self, director, attacker, target, skill, options)
end

function QSBAction:isAffectedByHaste()
	local skill = self._skill
	return skill:isTalentSkill() or skill:isAffectedByHaste()
end

function QSBAction:updateLinearProperty(fromValue, toValue, duration, dt)
    if not self._updateLinearProperty then
        if duration <= 0 then
            self:setLinearProperty(toValue)
            self:finished()
            return
        end
        local currentTime = 0
        local function update(dt)
            currentTime = math.min(currentTime + dt, duration)
            local value = math.sampler(fromValue, toValue, currentTime / duration)
            set:setLinearProperty(toValue)
            if currentTime == duration then
                self:finished()
            end
        end
        self._updateLinearProperty = update
    end
    self._updateLinearProperty(dt)
end

function QSBAction:setLinearProperty(value)
end

function QSBAction:getDragonModifier()
    if self._options.dragon_modifier and app.battle:isInUnionDragonWar() then
        return self._options.dragon_modifier
    end

    return 1.0
end

function QSBAction:isDeflection(attacker, attackee, isHit)
    local p = app.random() * 100
    local deflection = attackee:getDeflection() - attacker:getPrecise()
    if (p > 0 and p < deflection) then
        -- 被偏转
        if not isHit then
            attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false,
                isCritical = false, tip = "闪避", rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC,
                    isDodge = true,
                    isBlock = false,
                    isCritical = false,
                    isTreat = false,
                    isAbsorb = false,
                    number = 0,
                }})
        end
        
        return true
    end

    return false
end

return QSBAction