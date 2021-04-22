local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBRoledirection",
                    OPTIONS = {direction = "target", back_to = true},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack12_1", is_loop = true},       
                 }, 

                {
                     CLASS = "action.QSBActorKeepAnimation",
                     OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        trapId = "zibaozhizhu_xiadan2",
                        args = 
                        {
                            {delay_time = 0 , target_pos = true} ,
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBParallel",
                --     ARGS = {  
                --                 -- {
                --                 --     CLASS = "action.QSBPlayEffect",
                --                 --     OPTIONS = {is_hit_effect = true},
                --                 -- },
                --                 {
                --                     CLASS = "action.QSBHitTarget",
                --                 },
                --                 {
                --                     CLASS = "action.QSBActorKeepAnimation",
                --                     OPTIONS = {is_keep_animation = false}
                --                  },
                --             },
                -- },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 3},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong