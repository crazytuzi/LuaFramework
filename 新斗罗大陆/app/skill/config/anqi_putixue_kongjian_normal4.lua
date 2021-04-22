local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {

        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true, status = "save_treat"},
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 40248,target_type="skill_target"},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return shifa_tongyong