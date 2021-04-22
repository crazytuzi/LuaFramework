
local boss_mahongjun_xiaotianji = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
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
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_time = 2.5},
                                -- },                               
                                {
                                    CLASS = "action.QSBBullet",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBPlayLoopEffect",
        --             OPTIONS = {effect_id = "mahongjun_honghuan_3",is_hit_effect = true},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 2.5},
        --         },
        --         {
        --             CLASS = "action.QSBStopLoopEffect",
        --             OPTIONS = {effect_id = "mahongjun_honghuan_3",is_hit_effect = true},
        --         },
        --     }    
        -- },
    },
}

return boss_mahongjun_xiaotianji