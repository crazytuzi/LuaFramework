

local mantuoluoshe_dushechongci = {		--曼陀罗蛇毒蛇冲刺
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
       -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                    },
                },
		        {
		            CLASS = "composite.QSBSequence",
		            ARGS = {
		                {
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "boss_mantuoluoshe_1",is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBPlayLoopEffect",
		                    OPTIONS = {effect_id = "boss_mantuoluoshe_2",is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 1},
		                },
		                {
		                    CLASS = "action.QSBStopLoopEffect",
		                    OPTIONS = {effect_id = "boss_mantuoluoshe_2",is_hit_effect = false},
		                },
		            },   
		        },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 47 },
                        },   
		                {
							CLASS = "action.QSBHeroicalLeap",
		            		OPTIONS = {speed = 1800 ,move_time = 0.4 ,interval_time = 0.4 ,is_hit_target = true ,bound_height = 1},

		            	},
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return mantuoluoshe_dushechongci