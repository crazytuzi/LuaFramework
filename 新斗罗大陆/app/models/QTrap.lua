local QTrap
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QTrap = class("QTrap", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QTrap = class("QTrap", QModelBase)
end

-- trap damage type
QTrap.ATTACK = "attack"
QTrap.TREAT = "treat"

-- type damage target
QTrap.ENEMY = "enemy"
QTrap.TEAMMATE = "teammate"
QTrap.EVERYONE = "everyone"
QTrap.SELF = "self"

-- type range type
QTrap.SHAPE_CIRCLE = "circle"
QTrap.SHAPE_RING = "ring"
QTrap.SHAPE_RECT = "rect"

QTrap.TRIGGER = "TRIGGER_TRAP"

-- 定义属性
QTrap.schema = {}
QTrap.schema["name"]                                = {"string", ""}
QTrap.schema["duration"]                            = {"number", 0}
QTrap.schema["interval"]                            = {"number", 0}
QTrap.schema["range"]                               = {"number", 0}
QTrap.schema["range2"]                              = {"number", 0}
QTrap.schema["range_shape"]                         = {"string", QTrap.SHAPE_CIRCLE}
QTrap.schema["damage"]                              = {"number", 0}
QTrap.schema["damage_target_max_hp_percent"]        = {"number", 0}
QTrap.schema["damage_type"]                         = {"string", ""}
QTrap.schema["damage_target"]                       = {"string", ""}
QTrap.schema["influence_with_attack"]               = {"boolean", false}
QTrap.schema["influence_coefficient"]               = {"number", 1}
QTrap.schema["effect_type_1"]                       = {"string", ""}
QTrap.schema["effect_type_2"]                       = {"string", ""}
QTrap.schema["effect_type_3"]                       = {"string", ""}
QTrap.schema["effect_value_1"]                      = {"number", 0}
QTrap.schema["effect_value_2"]                      = {"number", 0}
QTrap.schema["effect_value_3"]                      = {"number", 0}
QTrap.schema["start_effect"]                        = {"string", ""}
QTrap.schema["execute_effect"]                      = {"string", ""}
QTrap.schema["area_effect"]                         = {"string", ""}
QTrap.schema["finish_effect"]                       = {"string", ""}
QTrap.schema["status"]                              = {"string", ""}
QTrap.schema["flip_with_actor"]                     = {"boolean", false}
QTrap.schema["offset_x"]                            = {"number", 0}
QTrap.schema["offset_y"]                            = {"number", 0}
QTrap.schema["absolute_position"]                   = {"boolean", false}
QTrap.schema["y_ratio"]                             = {"number", 2}
QTrap.schema["trigger_target"]                      = {"string", ""}
QTrap.schema["trigger_trap_id"]                     = {"string", ""}
-- QTrap.schema["trigger_skill_id"] = {"number", -1}
QTrap.schema["trigger_buff_id"]                     = {"string", ""}
QTrap.schema["level"]                               = {"level", 1}
QTrap.schema["ot_buff_id"]                          = {"string", ""}
-- QTrap.schema["ot_skill_id"]     = {"number", -1}
QTrap.schema["trigger_once"]                        = {"boolean",false}
QTrap.schema["trigger_status"]                      = {"string",nil}
QTrap.schema["trigger_skill_as_current"]            = {"boolean",false}
QTrap.schema["trigger_duration_time"]               = {"number",0}
QTrap.schema["trigger_duration_effect"]             = {"string",""}
QTrap.schema["trigger_duration_end_effect"]         = {"string",""}
QTrap.schema["ot_from_owner"]                       = {"boolean", false}
QTrap.schema["transmit_pos"]                        = {"boolean", false}
QTrap.schema["override_trap_id"]                    = {"string", nil}

QTrap.schema["addition_time_config"]                = {"string", nil}
QTrap.schema["dragon_modifier"]                     = {"number", 1.0}

function QTrap:get(key)
    return self._getInfo[key] or QTrap.schema[key][2]
end

function QTrap:set(key, value)
    self._getInfo[key] = value
end

function QTrap:getId()
    return self._id
end

local _pvpCoefficientsInitialized = false
local function InitializePVPCoefficients()
    if _pvpCoefficientsInitialized == false then
        local globalConfig = db:getConfiguration()
        local function getValue(k, dv)
            local v = dv
            if globalConfig[k] ~= nil and globalConfig[k].value ~= nil then
                v = globalConfig[k].value
            end
            QTrap[k] = v
        end
        getValue("ARENA_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SUNWELL_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SILVERMINE_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("ARENA_TREAT_COEFFICIENT", 1)
        getValue("SUNWELL_TREAT_COEFFICIENT", 1)
        getValue("SILVERMINE_TREAT_COEFFICIENT", 1)
        getValue("SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("SOTO_TEAM_TREAT_COEFFICIENT", 1)
        _pvpCoefficientsInitialized = true
    end
end

function QTrap:ctor(id, position, actor, level, skill)
    InitializePVPCoefficients()

    assert(position ~= nil, "invalid position to initailze a trap.")
    self._position = clone(position)

    local trapInfo = db:getTrapByID(id)
    assert(trapInfo ~= nil, "trap id: " .. id .. " does not exist!")

    -- if db:isTrapDataEnabled() then
    --     local trapData = db:getTrapDataByIdAndLevel(id, level)
    --     assert(trapData ~= nil, "trap data id: " .. id .. " level: " .. tostring(level) .. " does not exist!")
    --     trapInfo = q.cloneShrinkedObject(trapInfo)
    --     trapData = q.cloneShrinkedObject(trapData)
    --     table.merge(trapInfo, trapData)
    -- end

    assert(actor ~= nil, "invalid actor initialize a trap.")
    self._actor = actor
    self._skill = skill
    self._enhance_value_multiply = 1 + ((skill and skill:getEnhanceValue()) or 0)
    self._id = id
    self._getInfo = trapInfo

    QTrap.super.ctor(self, trapInfo)

    self.effects = {}

    self:_setEffect(self:get("effect_type_1"), self:get("effect_value_1"))
    self:_setEffect(self:get("effect_type_2"), self:get("effect_value_2"))
    self:_setEffect(self:get("effect_type_3"), self:get("effect_value_3"))

    self._duration = self:get("duration")
    self._interval = self:get("interval")
    self._executeCount = math.floor(self._duration / self._interval)
    self._status   = self:get("status")
    assert(self._executeCount > 0, "this trap could not be trigger any more, please check duration and interval value.")

    if self:get("addition_time_config") then
        local cfgs = string.split(self:get("addition_time_config"), ";")
        self._addition_time = tonumber(cfgs[1]) or 0
        self._max_duration = tonumber(cfgs[2]) or self._duration
    end

    self.effects.status = self._status
    self.effects.influence_with_attack = self:get("influence_with_attack")
    self.effects.influence_coefficient = self:get("influence_coefficient")

    local damage = self:get("damage")
    if self.effects.influence_with_attack then
        damage = damage + (self.effects.influence_coefficient + 1) * self._actor:getAttack()
    end
    self._damageEachTime = math.ceil(damage / self._executeCount) * self._enhance_value_multiply
    -- PVP系数影响
    if app.battle:isPVPMode() then
        if self:getDamageType() == QTrap.ATTACK then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._damageEachTime = self._damageEachTime * QTrap.SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT
                else
                    self._damageEachTime = self._damageEachTime * QTrap.ARENA_FINAL_DAMAGE_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._damageEachTime = self._damageEachTime * QTrap.SUNWELL_FINAL_DAMAGE_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._damageEachTime = self._damageEachTime * QTrap.SILVERMINE_FINAL_DAMAGE_COEFFICIENT
            end
        elseif self:getDamageType() == QTrap.TREAT then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._damageEachTime = self._damageEachTime * QTrap.SOTO_TEAM_TREAT_COEFFICIENT
                else
                    self._damageEachTime = self._damageEachTime * QTrap.ARENA_TREAT_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._damageEachTime = self._damageEachTime * QTrap.SUNWELL_TREAT_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._damageEachTime = self._damageEachTime * QTrap.SILVERMINE_TREAT_COEFFICIENT
            end
        end
    end

    if self:get("flip_with_actor") then
        if self:get("absolute_position") then
            if actor:isFlipX() then
                self._position.x = self:get("offset_x")
            else
                self._position.x = self:get("offset_x")
            end
        else
            if actor:isFlipX() then
                self._position.x = self._position.x + self:get("offset_x")
            else
                self._position.x = self._position.x - self:get("offset_x")
            end
        end
    else
        if self:get("absolute_position") then
            self._position.x = self:get("offset_x")
        else
            self._position.x = self._position.x + self:get("offset_x")
        end
    end
    if self:get("absolute_position") then
        self._position.y = self:get("offset_y")
    else
        self._position.y = self._position.y + self:get("offset_y")
    end

    self._triggerSkillID = trapInfo.trigger_skill_id
    self._otSkillID = trapInfo.ot_skill_id

    self._rect = QRectMake(-48, 0, 100, 96)
    self._triggerDurationPassTime = 0
end

function QTrap:_setEffect(prop, value)
    if prop ~= nil and string.len(prop) > 0 then
        self.effects[prop] = value
    end
end

function QTrap:getDuration()
    return self._duration
end

function QTrap:getRange()
    return self:get("range") * global.pixel_per_unit
end

function QTrap:getRange2()
    return self:get("range2") * global.pixel_per_unit
end

function QTrap:getRangeShape()
    return self:get("range_shape")
end

function QTrap:getDamageType()
    return self:get("damage_type")
end

function QTrap:getDamageTarget()
    return self:get("damage_target")
end

function QTrap:getStartEffectId()
    local effectId = self:get("start_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getTriggerDurationEffectId()
    local effectId = self:get("trigger_duration_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getTriggerDurationEndEffectId()
    local effectId = self:get("trigger_duration_end_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getExecuteEffectId()
    local effectId = self:get("execute_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getAreaEffectId()
    local effectId = self:get("area_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getFinishEffectId()
    local effectId = self:get("finish_effect")
    if string.len(effectId) == 0 then
        return nil
    end
    return effectId
end

function QTrap:getPosition()
    return self._position
end

function QTrap:setPosition(position)
    self._position = position
end

function QTrap:getDamageEachTime()
    return self._damageEachTime
end

function QTrap:start()
    self._passedTime = 0 
    self._lastTriggerTime = 0
end

function QTrap:visit(dt)
    self._passedTime = self._passedTime + dt
    if (self._passedTime - self._lastTriggerTime) > self._interval then
        self:dispatchEvent({name = QTrap.TRIGGER, trap = self})
        self._lastTriggerTime = self._interval + self._lastTriggerTime
    end
end

function QTrap:setIsEnd()
    self._trap_end = true
end

function QTrap:isEnded()
    return self._trap_end or (self._passedTime > self._duration)
end

function QTrap:getStatus()
	return self._status
end

function QTrap:getEnhanceValue()
    return self._enhance_value_multiply - 1
end

function QTrap:getYRatio()
    return self:get("y_ratio")
end

function QTrap:getTriggerTarget()
    return self:get("trigger_target")
end

function QTrap:getTriggerBuffID()
    return self:get("trigger_buff_id")
end

function QTrap:getTriggerSkillID()
    return self._triggerSkillID
end

function QTrap:getTriggerTrapID()
    return self:get("trigger_trap_id")
end

function QTrap:getOTBuffID()
    return self:get("ot_buff_id")
end

function QTrap:getOTSkillID()
    return self._otSkillID
end

function QTrap:getTrapOwner()
    return self._actor
end

function QTrap:getTrapOwnerSkill()
    return self._skill
end

function QTrap:getBoundingBox()
    return QRectMake(  self._rect.origin.x + self._position.x, 
                        self._rect.origin.y + self._position.y, 
                        self._rect.size.width, self._rect.size.height)
end

function QTrap:isFlipWithActor()
    return self:get("flip_with_actor")
end

function QTrap:getTriggerStatus()
    local strs = self:get("trigger_status")
    if not strs then return nil end
    local status_str = string.trim(strs)
    local status_list
    if status_str and status_str ~= "" then
        status_list = string.split(status_str,";")
    end
    return status_list
end

function QTrap:isTriggerOnce()
    return self:get("trigger_once")
end

function QTrap:getTriggerSkillAsCurrent()
    return self:get("trigger_skill_as_current")
end

function QTrap:getTriggerDurationTime()
    return self:get("trigger_duration_time")
end

function QTrap:getTriggerDurationPassTime()
    return self._triggerDurationPassTime
end

function QTrap:setTriggerDurationPassTime(time)
    self._triggerDurationPassTime = time
end

function QTrap:isOtFromOwner()
    return self:get("ot_from_owner")
end

function QTrap:isTransmitPos()
    return self:get("transmit_pos")
end

function QTrap:getAdditionTime()
    return self._addition_time
end

function QTrap:additionTime(time)
    self._duration = math.min(self._duration + time, self._max_duration)
end

function QTrap:IsTriggered()
    return self._trap_end
end

function QTrap:getOverrideTrapId()
    return self:get("override_trap_id")
end

function QTrap:getDamageTargetMaxHpPercent()
    return self:get("damage_target_max_hp_percent")
end

function QTrap:getDragonModifier()
    if app.battle:isInUnionDragonWar() then
        return self:get("dragon_modifier")
    else
        return 1.0
    end
end

return QTrap
