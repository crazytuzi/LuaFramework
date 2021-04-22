local mahongjun_beidong3_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = true},
		},
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return mahongjun_beidong3_trigger