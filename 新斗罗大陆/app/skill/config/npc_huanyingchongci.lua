local npc_zhaohuan_yezhuhengchongzhizhuang = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12" , is_loop = true},
                        },
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            -- OPTIONS = {speed = 300 ,move_time = 3 ,interval_time = 0.1 ,is_hit_target = true ,bound_height = 150},
                            OPTIONS = {distance = 4000 ,move_time = 8 ,outside =true}
                        },
                    },
                },
                -- {
                --     CLASS = "action.QSBAttackFinish",
                -- },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/24 },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 1.5},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24/24 },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 2},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36/24 },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 1.5},
                },
            },
        },
        {
             CLASS = "action.QSBHitTarget",
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
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
                    OPTIONS = {delay_time = 4 / 24},
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
                    OPTIONS = {delay_time = 6 / 24},
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
                    OPTIONS = {delay_time = 8 / 24},
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
                    OPTIONS = {delay_time = 10 / 24},
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
                    OPTIONS = {delay_time = 12 / 24},
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
                    OPTIONS = {delay_time = 14 / 24},
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
                    OPTIONS = {delay_time = 16 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24},
                },
                {
                     CLASS = "action.QSBHitTarget",
                },
            },
        }, 
    },
}
return npc_zhaohuan_yezhuhengchongzhizhuang