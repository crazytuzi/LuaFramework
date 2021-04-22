-- 技能 唐昊被动2触发
-- 技能ID 611
-- 计数,每三下附带高额伤害
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_beidong2_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2,
                {expression = "self:status_apply_count:ssptanghao_bd2_count>1", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBAddApplyCount",--清零方法
                            OPTIONS = {status = "ssptanghao_bd2_count", set_apply_count_num = 0}
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "ssptanghao_beidong2_3", is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAddApplyCount",
                    OPTIONS = {status = "ssptanghao_bd2_count"}
                },
            },
        }, 
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {status = "ssptanghao_sj", is_attackee = true,}
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {    
                {CLASS = "action.QSBChangeRage",OPTIONS = {rage_value = 0.1},},
            },
        },
        {
			CLASS = "action.QSBClearSkillCD",
			OPTIONS = {skill_id = 611},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_beidong2_trigger

