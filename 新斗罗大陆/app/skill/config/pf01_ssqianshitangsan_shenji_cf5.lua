local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attackee = true,status = "qianshitangsan_debuff1"},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBArgsConditionSelector",
                                                    OPTIONS = 
                                                    {
                                                        failed_select = 1,
                                                        {expression = "target:buff_num:ssqianshitangsan_putixue1=0", select = 1},
                                                        {expression = "target:buff_num:ssqianshitangsan_putixue1=1", select = 2},
                                                        {expression = "target:buff_num:ssqianshitangsan_putixue1=2", select = 3},
                                                        {expression = "target:buff_num:ssqianshitangsan_putixue1=3", select = 4},                                                                                                            
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSelector",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBHitTarget",                                                                                    
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 1.3},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 1.6},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 1.9},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 2.2},
                                                        },                                                              
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf01_ssqianshitangsan_shenji_1", is_hit_effect = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf01_ssqianshitangsan_shenji_2", is_hit_effect = true},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish",
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf01_ssqianshitangsan_shenji_1", is_hit_effect = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf01_ssqianshitangsan_shenji_2", is_hit_effect = true},
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
        },
    },
}

return common_xiaoqiang_victory