
local yuxiaogang_huangjingshenglongpao = {
CLASS = "composite.QSBParallel",
ARGS = {
        
            {
                CLASS = "action.QSBPlaySound"
            },
            {
                CLASS = "action.QSBPlaySound",
                OPTIONS = {sound_id ="yuxiaogang_walk"},
            },
            {
                CLASS = "composite.QSBSequence",
                 ARGS = {
                            {  
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                                {
                                                     CLASS = "composite.QSBSequence",
                                                     ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 1},
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayAnimation",
                                                            OPTIONS = {animation = "attack11"},
                                                        },
                                                    },
                                                },
                                                {
                                                     CLASS = "composite.QSBSequence",
                                                     ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 18},
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = {is_hit_effect = false, effect_id = "boss_yuxiaogang_dazhao_atk11_1"},
                                                        }, 
                                                    },
                                                },
                                                {
                                                     CLASS = "composite.QSBSequence",
                                                     ARGS = 
                                                     {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 70},
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk01_3"},
                                                        }, 
                                                    },
                                                },
                                                {
                                                     CLASS = "composite.QSBSequence",
                                                     ARGS = 
                                                     {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 70},
                                                        },
                                                         {
                                                            CLASS = "action.QSBHitTarget",
                                                         },
                                                    },
                                                },
                                                
                                       },
                            }  
                        },
            },
            {

                CLASS = "composite.QSBSequence",

                ARGS = {

                            {

                                CLASS = "action.QSBPlayEffect",

                                OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                            },
                            {

                                CLASS = "action.QSBPlayLoopEffect",

                                OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                            },
                            {

                                CLASS = "action.QSBDelayTime",

                                OPTIONS = {delay_time = 2},

                            },
                            {

                                CLASS = "action.QSBStopLoopEffect",

                                OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                            },
                            {
                                 CLASS = "composite.QSBSequence",
                                 ARGS = 
                                {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 110},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish"
                                        },
                                },
                            },
                        },   
            },
                            
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     OPTIONS = {forward_mode = true,},   --不会打断特效
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBShowActor",
                        --             OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        --         },
                        --         {
                        --             CLASS = "action.QSBBulletTime",
                        --             OPTIONS = {turn_on = true, revertable = true},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 50 / 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBBulletTime",
                        --             OPTIONS = {turn_on = false},
                        --         },
                        --         {
                        --             CLASS = "action.QSBShowActor",
                        --             OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        --         },

                        --     },
                        -- },
                       
                        
                        {
                             CLASS = "composite.QSBSequence",
                             ARGS = 
                            {
                                    {
                                        CLASS = "action.QSBDelayTime",
                                        OPTIONS = {delay_frame = 110},
                                    },
                                    {
                                        CLASS = "action.QSBAttackFinish"
                                    },
                            },
                        },
    },
}

return yuxiaogang_huangjingshenglongpao