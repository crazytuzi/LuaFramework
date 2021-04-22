local boss_renmianmozhu_pentuzhuwang = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 63},
				},
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "boss_dixuemozhu_zhuwang_trap2",interval_time = 0.25,count = 1}
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
    },
}

return boss_renmianmozhu_pentuzhuwang