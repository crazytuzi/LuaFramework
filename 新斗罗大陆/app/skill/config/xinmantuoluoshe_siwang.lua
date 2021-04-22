local boss_fulande_bianshen = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
    	-- {
     --        CLASS = "action.QSBApplyBuff",
     --        OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
     --    },
     --    {
     --        CLASS = "action.QSBUncancellable",    
     --    },
    	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "dead" , no_stand = true},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "mantuoluoshewang_dead_1" , is_hit_effect = false },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 5 / 24},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 18, duration = 0.4, count = 3},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 42 / 24},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.4, count = 2},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 5 / 24},
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {exit = true},
        -- },
        -- {
        --     CLASS = "action.QSBAttackFinish"
        -- },
    },
}
return boss_fulande_bianshen