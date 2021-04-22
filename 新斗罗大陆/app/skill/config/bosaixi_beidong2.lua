
local bosaixi_beidong2 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "bosaixi_beidong2_buff;y", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return bosaixi_beidong2