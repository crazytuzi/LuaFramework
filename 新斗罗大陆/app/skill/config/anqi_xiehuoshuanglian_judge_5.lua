local anqi_xiehuoshuanglian_judge_5 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
                {expression = "target:hp/target:max_hp<0.6", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 40398,target_type="skill_target"},
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
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 40398,target_type="skill_target"},
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 40403,target_type="skill_target"},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return anqi_xiehuoshuanglian_judge_5