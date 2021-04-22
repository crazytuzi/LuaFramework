-- 技能 唐昊大招斩杀
-- 技能ID 610
-- 斩杀
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_dazhao_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 6,
                {expression = "self:ssptanghao_sj5", select = 1},
                {expression = "self:ssptanghao_sj4", select = 2},
                {expression = "self:ssptanghao_sj3", select = 3},
                {expression = "self:ssptanghao_sj2", select = 4},
                {expression = "self:ssptanghao_sj1", select = 5},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639129, wait_finish = true},
                },
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639128, wait_finish = true},
                },
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639127, wait_finish = true},
                },
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639126, wait_finish = true},
                },
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639125, wait_finish = true},
                },
                {
                    CLASS = "action.QSBTriggerSkill",	
                    OPTIONS = {skill_id = 2639124, wait_finish = true},
                },
            },
        },
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2,
                {expression = "target:is_boss", select = 2},
                {expression = "target:ssptanghao_sj", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "allow_exec", is_target = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",	
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_dazhao_trigger

