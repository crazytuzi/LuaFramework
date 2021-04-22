-- **************************************************
-- Author               : wanghai
-- FileName             : QAIUseSkillForType.lua
-- Description          : 根据类型使用相关的技能
-- Create time          : 2019-10-28 16:49
-- Last modified        : 2019-10-28 16:49
-- **************************************************


--注意这个只能在copyhero里用，是copyhero专用的技能

local QAIAction = import("..base.QAIAction")
local QAIUseSkillForType = class("QAIUseSkillForType", QAIAction)

function QAIUseSkillForType:ctor(options)
    QAIUseSkillForType.super.ctor(self, options)
    self:setDesc("根据类型使用相关的技能")
end

function QAIUseSkillForType:_evaluate(args)
    return true
end

--[[--
@param talent_skill   普攻技能
@param active_skill   自动技能
@param manual_skill   大招
@param god_skill      触发神技被动
--]]
function QAIUseSkillForType:_execute(args)
    local type = self._options.type
    local actor = args.actor
    if type == "talent_skill" then
        return actor:useTalentSKill() 
    elseif type == "active_skill" then
        return actor:useActiveSkill()
    elseif type == "manual_skill" then
        return actor:useManualSkill()
    elseif type == "god_skill" then
        return actor:triggerGodSkill()
    elseif type == "charge_skill" then
        return actor:useChargeSkill()
    end

    return false 
end

return QAIUseSkillForType
