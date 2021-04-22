
local pf_bosaixi_beidong2 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_bosaixi_beidong2_buff;y", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_bosaixi_beidong2