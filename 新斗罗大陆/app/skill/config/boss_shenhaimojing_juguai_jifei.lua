local boss_shenhaimojing_juguai_jifei = 
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS =
                    {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 0.5},
                        -- },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                               {
                                  CLASS = "action.QSBShakeScreen",
                                  OPTIONS = {amplitude = 40, duration = 0.25, count = 2,},
                               },
                               {
                                  CLASS = "composite.QSBSequence",
                                  ARGS =
                                  {
                                     {
                                        CLASS = "action.QSBDelayTime",
                                        OPTIONS = {delay_time = 0.5},
                                     },
                                     {
                                        CLASS = "action.QSBDragActor",
                                        OPTIONS = {pos_type = "self" , pos = {x = 100,y = 0} , duration = 0.75, flip_with_actor = true },
                                     },
                                  },
                               },      
                            }, 
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                               {
                                  CLASS = "action.QSBDelayTime",
                                  OPTIONS = {delay_time = 5/24},
                               },
                               {
                                  CLASS = "action.QSBShakeScreen",
                                  OPTIONS = {amplitude = 40, duration = 0.25, count = 1,},
                               },
                            },
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
        }
return boss_shenhaimojing_juguai_jifei