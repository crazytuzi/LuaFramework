local bosaixi_shengli = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return bosaixi_shengli