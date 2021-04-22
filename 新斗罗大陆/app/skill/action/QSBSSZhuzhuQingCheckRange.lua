--[[
    单独给SS朱竹青写的技能脚本，检查全场敌方英雄是否在指定区域内，根据情况触发不同的行为
    参数
    interval:检测的时间间隔
    duration:该脚本的持续时间
    radius:检查的半径
    pos:检查的中心点，如果不配置那么则以技能的释放者为中心
    

    tick_in_debuff_time:英雄在圈内时tick的时间间隔
    out_range_debuff_time:从圈内出圈外时造成的扣血效果的时间间隔
    in_range_debuff_time:从圈内进圈外造成扣血效果的时间间隔
    注:以上三个时间都是以interval参数为单位计算的所以推荐配置成interval的整数倍

    beattack_coefficient:在圈内受击回怒系数,填写负数才是降低
    in_range_damage_scale:从圈外进圈内的伤害系数
    out_range_damage_scale:从圈内出圈外的伤害系数
    tick_inrange_damage_scale:在圈内tick的伤害系数

    tick_inrange_debuff_id:在圈内不断的tick时上的buff的id
    out_range_debuff_id:从圈外出圈内的一瞬间上的debuff的id

    这个脚本的revertable要配置成true
--]]
local QSBAction = import(".QSBAction")
local QSBSSZhuzhuQingCheckRange = class("QSBSSZhuzhuQingCheckRange", QSBAction)

local function getTime()
    return app.battle:getTime()
end

function QSBSSZhuzhuQingCheckRange:checkCoolDown(actor, func)
    if self._cooldown_tab[actor] == nil or self._cooldown_tab[actor][func] == nil then
        return true
    end
    return getTime() - self._cooldown_tab[actor][func] > self._cd_list[func]
end

function QSBSSZhuzhuQingCheckRange:coolDown(actor, func)
    if self._cooldown_tab[actor] == nil then self._cooldown_tab[actor] = {} end
    self._cooldown_tab[actor][func] = getTime()
end

function QSBSSZhuzhuQingCheckRange:ctor(director, attacker, target, skill, options)
    QSBSSZhuzhuQingCheckRange.super.ctor(self, director, attacker, target, skill, options)
    self._interval = self._options.interval or 0.5

    self._actors_in_range = {}
    self._actors_out_range = {}

    self._cooldown_tab = {}

    self._cd_list = 
    {
        ["tickInDebuff"] = self._options.tick_in_debuff_time or 1,
        ["outRangeDebuff"] = self._options.out_range_debuff_time or 1,
        ["inRangeDebuff"] = self._options.in_range_debuff_time or 1,
    }
end

function QSBSSZhuzhuQingCheckRange:_execute(dt)
    if self._start_time ~= nil then
        local cur_time = getTime()
        if cur_time - self._start_time >= self._options.duration then
            self:onSkillEnd()
            self:finished()
        elseif cur_time - self._last_check_time > self._interval then
            self:checkRange()
            self._last_check_time = cur_time
        end
        return
    end

    self:checkRange()
    self._start_time = getTime()
    self._last_check_time = self._start_time
end

function QSBSSZhuzhuQingCheckRange:checkRange()
    local targets = app.battle:getMyEnemies(self._attacker)
    for i,actor in ipairs(targets) do
        if self:isActorInRange(actor) then
            if self._actors_in_range[actor] then
                self:tickIn(actor)
            else
                self:onActorInRange(actor)
                self._actors_out_range[actor] = false
                self._actors_in_range[actor] = true
            end
        else
            if self._actors_out_range[actor] then
                self:tickOut(actor)
            elseif self._actors_in_range[actor] then
                self:onActorOutOfRange(actor)
                self._actors_in_range[actor] = false
                self._actors_out_range[actor] = true
            end
        end
    end
end

function QSBSSZhuzhuQingCheckRange:isActorInRange(actor)
    local center = self._options.pos or clone(self._attacker:getPosition())
    local offset = app.battle:getFromMap(self._attacker, "SS_ZHUZHUQING_RANGE_OFFSET")
    if offset then
        center.x = center.x + offset.x
        center.y = center.y + offset.y
    end
    local radius = self._options.radius
    if radius then
        if not IsServerSide and DISPLAY_SKILL_RANGE == true then
            app.scene:displayCircleRange({center.x, center.y}, radius)
        end
        if radius then
            local distance = q.distOf2Points(center, actor:getPosition())
            if distance > radius then
                return false
            end
        end
    end
    local rect = self._options.rect
    if rect then
        local left = center.x - rect.width/2
        local right = center.x + rect.width/2
        local bottom = center.y - rect.height/2
        local top = center.y + rect.height/2
        if not IsServerSide and DISPLAY_SKILL_RANGE == true then
            app.scene:displayRect({x = left, y = bottom}, {x = right, y = top})
        end
        local pos = actor:getPosition()
        return pos.x >= left and pos.x <= right and pos.y >= bottom and pos.y <= top
    end
    return true
end

function QSBSSZhuzhuQingCheckRange:onActorInRange(actor)
    actor:insertPropertyValue("rage_increase_coefficient", self._skill, "+", self._options.beattack_coefficient or -1)
    if self:checkCoolDown(actor, "inRangeDebuff") then
        self._attacker:hit(self._skill, actor, nil, nil, nil, nil, nil, self._options.in_range_damage_scale)
        self:coolDown(actor, "inRangeDebuff")
    end
end

function QSBSSZhuzhuQingCheckRange:onActorOutOfRange(actor)
    actor:removePropertyValue("rage_increase_coefficient", self._skill)
    if self:checkCoolDown(actor, "outRangeDebuff") then
        self._attacker:hit(self._skill, actor, nil, nil, nil, nil, nil, self._options.out_range_damage_scale)
        actor:applyBuff(self._options.out_range_debuff_id, self._attacker, self._skill)
        if self._options.out_range_debuff_id2 then
            actor:applyBuff(self._options.out_range_debuff_id2, self._attacker, self._skill)
        end
        if self._options.out_range_debuff_id3 then
            actor:applyBuff(self._options.out_range_debuff_id3, self._attacker, self._skill)
        end
        self:coolDown(actor, "outRangeDebuff")
        self:coolDown(actor, "tickInDebuff")
    end
end

function QSBSSZhuzhuQingCheckRange:tickIn(actor)
    if self:checkCoolDown(actor, "tickInDebuff") then
        self._attacker:hit(self._skill, actor, nil, nil, nil, nil, nil, self._options.tick_inrange_damage_scale)
        actor:applyBuff(self._options.tick_inrange_debuff_id, self._attacker, self._skill)
        if self._options.tick_inrange_debuff_id2 then
            actor:applyBuff(self._options.tick_inrange_debuff_id2, self._attacker, self._skill)
        end
        if self._options.tick_inrange_debuff_id3 then
            actor:applyBuff(self._options.tick_inrange_debuff_id3, self._attacker, self._skill)
        end
        self:coolDown(actor, "tickInDebuff")
    end
end

function QSBSSZhuzhuQingCheckRange:tickOut(actor)

end

function QSBSSZhuzhuQingCheckRange:onSkillEnd()
    for actor,isIn in pairs(self._actors_in_range) do
        if isIn then
            actor:removePropertyValue("rage_increase_coefficient", self._skill)
        end
    end
end

function QSBSSZhuzhuQingCheckRange:_onCancel()
    self:onSkillEnd()
end

function QSBSSZhuzhuQingCheckRange:_onRevert()
    self:onSkillEnd()
end

return QSBSSZhuzhuQingCheckRange