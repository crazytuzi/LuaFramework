local boss_duguyan_gongjizhiling = {
    CLASS = "composite.QSBParallel",
	OPTIONS = {revertable = true},
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {is_target = true ,buff_id = "angellove1"},
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 29 / 24},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return boss_duguyan_gongjizhiling

