local xiaobai_beidong2 = {
    {
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QSBActorStatus",
                OPTIONS = {{"target:bled","target:apply_buff:xiaobai_beidong2_debuff","under_status"}}, 
            },
            {
                CLASS = "action.QSBAttackFinish"
            },
        },
    },
}

return xiaobai_beidong2