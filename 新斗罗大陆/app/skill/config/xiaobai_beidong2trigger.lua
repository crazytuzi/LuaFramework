local xiaobai_beidong2trigger = {
    {
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            {
                CLASS = "composite.QSBParallel",
                ARGS = {
                    {
                        CLASS = "action.QSBRemoveBuff",
                        OPTIONS = {buff_id = "xiaobai_beidong2_debuff"},
                    },
                    {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {buff_id = "xiaobai_beidong2trigger_debuff"},
                    },
                },
            },
            {
                CLASS = "action.QSBHitTarget",
            },
            {
                CLASS = "action.QSBAttackFinish",
            },
        },
    },
}

return xiaobai_beidong2trigger