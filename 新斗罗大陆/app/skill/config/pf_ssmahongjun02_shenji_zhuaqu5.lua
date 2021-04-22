-- 技能 ss马红俊升级1
-- 技能ID 39006
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_shenji_zhuaqu5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 39010, target_type="skill_target"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    { 
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {     
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf_ssmahongjun_shenji3_1", is_hit_effect = true, front_layer = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {     
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf_ssmahongjun_shenji3_2", is_hit_effect = true, front_layer = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return ssmahongjun_shenji_zhuaqu5
