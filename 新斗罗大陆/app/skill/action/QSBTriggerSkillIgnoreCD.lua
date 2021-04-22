-- @Author: wanghai
-- @Date:   2020-06-02 16:13:00
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-09-09 17:09:19

--[[
    触发技能忽视CD
--]]
local QSBAction = import(".QSBAction")
local QSBTriggerSkillIgnoreCD = class("QSBTriggerSkillIgnoreCD", QSBAction)

local QActor            = import("...models.QActor")
local QSkill            = import("...models.QSkill")

function QSBTriggerSkillIgnoreCD:_execute(dt)
    local actor = self._attacker
    local skill_id = self:getOptions().skill_id
    local skill_level = self:getOptions().skill_level

    if skill_id == nil or skill_id == "" then
        self:finished()
        return  
    end 

    if skill_level and skill_level < 1 then
        skill_level = self._skill:getSkillLevel()
    end

    local triggerSkill = actor._skills[skill_id]
    if triggerSkill == nil then
        triggerSkill = QSkill.new(skill_id, db:getSkillByID(skill_id), actor, skill_level)
        actor._skills[skill_id] = triggerSkill
    end
    if self._options.no_target then
        actor:triggerAttack(triggerSkill)
    else
        local targets
        if self._options.selectTargets then
            targets = self._options.selectTargets
        elseif self._options.selectTarget then
            targets = {self._options.selectTarget}
        else
            targets = {self._target}
        end
        for k, target in ipairs(targets) do
            actor:triggerAttack(triggerSkill, target)
        end
    end

    self:finished()
end

return QSBTriggerSkillIgnoreCD