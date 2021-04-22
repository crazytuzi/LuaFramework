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
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.6},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = false},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 75 /30},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                }, 
                {                           --竞技场黑屏
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 75 / 30},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 2 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "sszzq_zd1_1"},
                                }, 
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 25 },
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="ssaosika_skill"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 25},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            { 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, effect_id = "sszzq_dz_2"},
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
                                            OPTIONS = {delay_frame = 35},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            { 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, effect_id = "sszzq_dz_2"},
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
                                            OPTIONS = {delay_frame = 42},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            { 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, effect_id = "sszzq_dz_2"},
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
                                            OPTIONS = {delay_frame = 75},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            { 
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true, effect_id = "sszzq_dz_2"},
                                                }, 
                                                {
                                                  CLASS = "action.QSBHitTarget",
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
        },
        {
          CLASS = "action.QSBAttackFinish",
        },
    },
}

return common_xiaoqiang_victory