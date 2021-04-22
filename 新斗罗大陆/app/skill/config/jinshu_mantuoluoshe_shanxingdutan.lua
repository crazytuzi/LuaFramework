
local mantuoluoshe_shanxingdutan = {
	CLASS = "composite.QSBParallel",
    ARGS = { 
		{
            CLASS = "action.QSBPlaySound"
        },	
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                    },
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        }, 
		{
			CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
			OPTIONS = {interval_time = 0, count = 2, distance = 100, trapId = {"kong_trap","jinshu_mantuoluoshe_shanxingdutan"}},
		},		
	},
}

return mantuoluoshe_shanxingdutan