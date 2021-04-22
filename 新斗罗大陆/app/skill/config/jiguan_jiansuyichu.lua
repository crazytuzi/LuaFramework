local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "jiguan_dongzhu"},
        -- },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "jiguan_bingdong_jiechu"},
        -- },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "jiguan_dongzhu", remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "jiguan_bingdong_jiansu", remove_all_same_buff_id = true},
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