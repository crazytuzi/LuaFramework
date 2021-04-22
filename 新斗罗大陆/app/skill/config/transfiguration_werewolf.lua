
local shapeshifting_cobrahn = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "prepare_shapeshifting_butcher_werewolf"},
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
            OPTIONS = {is_target = false, buff_id = "prepare_shapeshifting_butcher_werewolf"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shapeshifting_cobrahn