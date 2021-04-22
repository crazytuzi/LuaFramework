local feiti = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack12"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
		        {
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {enter = true, revertable = true},
		        },
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 10},
				},
				{
					CLASS = "action.QSBFeiti",
				},
				{
		            CLASS = "action.QSBApplyBuff",
		            OPTIONS = {is_target = true, buff_id = "stun_charge"},
		        },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            
                            OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                        },
                        {
                             CLASS = "action.QSBHitTarget",
                        }
                    },
                },
		        {
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {exit = false,},
		        },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return feiti

--[[
t1. play jump animation
t2. wait for xxx frame, play impact effect at body with rotation
t3. wait for xxx frame, play dragon head effect attached to body with rotation
t4. wait for xxx frame, play dragon body effect attached to body with rotation (with extra scale)
t5, wait for xxx frame, move actor to target position

rotation: vector [jump high point] -> [target position]
]]