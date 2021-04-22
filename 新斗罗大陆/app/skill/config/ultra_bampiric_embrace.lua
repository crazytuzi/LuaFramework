local ultra_bampiric_embrace = {
	CLASS = "composite.QSBParallel",
    ARGS = {
                {
                	CLASS = "composite.QSBSequence",
                	ARGS = 
                	{
                    	{
		                    CLASS = "action.QSBPlayAnimation",
		                    OPTIONS = {animation = "attack11"},
		                },
                        {
		                    CLASS = "action.QSBAttackFinish"
		                },
                	},
            	},
                {
                	CLASS = "composite.QSBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 7},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_1"},
                        },
                	},
            	},
            	{
                	CLASS = "composite.QSBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_3"},
                        },
                	},
            	},
            	{
                	CLASS = "composite.QSBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 38},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_2"},
                        },
                	},
            	},
            	{
                	CLASS = "composite.QSBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 38},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                	},
            	},
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.17},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                },
                {                       --竞技场黑屏
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.17},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                },
        	},
    	}
return ultra_bampiric_embrace