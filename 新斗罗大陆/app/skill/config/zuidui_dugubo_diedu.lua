
local zuidui_dugubo_diedu = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "zuidui_dugubo_diedu", all_enemy = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zuidui_dugubo_diedu