local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBHitTarget",

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