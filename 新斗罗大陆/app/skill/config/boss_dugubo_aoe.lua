--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：独孤博BOSS
--  类型：攻击
local boss_dugubo_aoe = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 6},
                        -- },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "boss_dugubo_attack11_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 6},
                        -- },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "boss_dugubo_attack11_1_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 70},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = 
                     {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30},
                        },
                        -- {
                        --     CLASS = "action.QSBArgsPosition",
                        -- },
                        {
                            CLASS = "action.QSBAttackByBuffNum",
                            OPTIONS = {buff_id = "boss_dugubo_shedu_dot", num_pre_stack_count = 1, trigger_skill_id = 50489},
                        },
                        -- {
                        --     CLASS = "action.QSBTriggerSkill",
                        --     OPTIONS = {skill_id = 50467},
                        -- },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {multiple_target_with_skill = true, buff_id = "boss_dugubo_shedu_dot", remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_dugubo_aoe