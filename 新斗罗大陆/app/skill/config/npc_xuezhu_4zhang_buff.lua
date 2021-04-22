local npc_xuezhu_4zhang_buff = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBActorStand",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return npc_xuezhu_4zhang_buff