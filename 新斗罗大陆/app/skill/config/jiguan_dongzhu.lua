local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "jiguan_dongzhu"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "jiguan_bingdong_yichu"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "jiguan_bingdong_jiansu", remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="jiguan_bingdong"},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 2},
        },
        -- {
        --     CLASS = "action.QSBPlaySound",
        -- },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = false},
        --         },
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             ARGS = {
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = {  
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {is_hit_effect = true},
        --                         },
        --                         {
        --                             CLASS = "action.QSBHitTarget",
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --     },
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return shifa_tongyong