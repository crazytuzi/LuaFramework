
local immunize_boss_4 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_prepare_polymorph", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_polymorph_sheep_state", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_polymorph_sheep", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_stun", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_fear", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_knockback", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_time_stop", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_stun_charge", no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "immunize_freeze", no_cancel = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return immunize_boss_4