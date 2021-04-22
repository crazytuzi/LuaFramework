local ultra_bombarded = {	
	CLASS = "composite.QSBParallel",
	ARGS = {
		-- animation
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
		        {
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack14"},
		        },
		        {
		            CLASS = "action.QSBAttackFinish",
		        },
			},
		},
		-- effect
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
		        {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "jianyu_1", is_hit_effect = false, haste = true},
		        },
			},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
		        {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "jianyu_y"},
		        },
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 69},
                },
		        {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "jianyu_y1"},
		        },
			},
		},
		-- {
  --           CLASS = "composite.QSBSequence",
  --           OPTIONS = {forward_mode = true,},
  --           ARGS = {
  --               {
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 59},
  --               },
  --               {
		--             CLASS = "action.QSBPlayEffect",
		--             OPTIONS = {effect_id = "jianyu_3", is_hit_effect = true},
		--         },
  --           },
  --       },
		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 69},
                },
                 {
                    CLASS = "action.QSBHitTimer",
                },
            },
        },

	},
} 

return ultra_bombarded