
local QAIUseSkill = import(".QAIUseSkill")
local QAIUseSkillWithJudgement = class("QAIUseSkillWithJudgement", QAIUseSkill)

function QAIUseSkillWithJudgement:ctor( options )
    QAIUseSkillWithJudgement.super.ctor(self, options)
    self:setDesc("使用魂技,并判断")
end

function QAIUseSkillWithJudgement:useSkillForActor(actor, skillId)
    if actor == nil or actor:isDead() == true then
        return false
    end

    if skillId == nil then
        return false
    end

    local skill = actor:getSkillWithId(skillId)
    if skill == nil then
        return false
    end

    if skill:getSkillType() == skill.PASSIVE then
        return true
    end

    if skill:isNeedATarget() == true then
        if actor:getTarget() == nil or actor:getTarget():isDead() == true then
            return false
        end
    end

    if actor:canAttack(skill) == false then
        return false
    end

    actor:attack(skill)

    return true
end

return QAIUseSkillWithJudgement