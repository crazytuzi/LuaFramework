-- 技能 牛天神技触发
-- 技能ID 39047~39051
-- 先后触发降龙和升龙
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_shenji_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
        },
        {
            CLASS = "action.QSBClearSkillCD",
            OPTIONS = {skill_id = 39052},
        },
        {
            CLASS = "action.QSBTriggerSkill",
            OPTIONS = {skill_id = 39052},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 56},
        },  
        {
            CLASS = "action.QSBClearSkillCD",
            OPTIONS = {skill_id = 39057},
        },
        {
            CLASS = "action.QSBTriggerSkill",
            OPTIONS = {skill_id = 39057},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssniutian_shenji_trigger