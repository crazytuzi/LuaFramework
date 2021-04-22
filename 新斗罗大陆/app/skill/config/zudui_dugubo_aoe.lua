--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：独孤博BOSS
--  类型：攻击
local zudui_dugubo_aoe = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
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
                            OPTIONS = {buff_id = "jinshu_dugubo_shedu_dot", num_pre_stack_count = 1, trigger_skill_id = 51086},
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
            OPTIONS = {multiple_target_with_skill = true, buff_id = "jinshu_dugubo_shedu_dot", remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_dugubo_aoe