local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "mingyueye_debuff2_2"},
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = 
                            {
                                failed_select = 1,
                                {expression = "target:hp/target:max_hp=1", select = 1},
                                {expression = "target:hp/target:max_hp>0.8", select = 2},
                                {expression = "target:hp/target:max_hp>0.6", select = 3},
                                {expression = "target:hp/target:max_hp>0.4", select = 4},
                                {expression = "target:hp/target:max_hp>0.2", select = 5},
                                {expression = "target:hp/target:max_hp>0", select = 6},                                
                            }
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
                                    OPTIONS = {damage_scale = 1.2},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {damage_scale =1.4},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {damage_scale = 1.6},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {damage_scale =1.8},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {damage_scale = 2},
                                },                                
                            },
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

return zidan_tongyong