
local bosaixi_zhenji_dazhao_jifei =  {
     CLASS = "composite.QSBSequence",
        ARGS = {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {min_distance = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return bosaixi_zhenji_dazhao_jifei

