
local shapeshifting_cobrahn = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "prepare_shapeshifting_cobrahn_adder_elite"},
        },
        -- {
        --     CLASS = "action.QSBActorFadeOut",
        --     OPTIONS = {is_target = false, duration = 0.3},
        -- },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 15},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "prepare_shapeshifting_cobrahn_adder_elite"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shapeshifting_cobrahn