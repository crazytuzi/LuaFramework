local fenshen = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QSBSequence",
			ARGS =
			{
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack13"},
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
					OPTIONS = {delay_frame = 15},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "mirror_image_1"},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS =
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 43 - 11},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS =
					{
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "mirror_image_2", is_flip_x = true},
						},
					},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 6},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBSummonGhosts",
			            	OPTIONS = {actor_id = 41584, life_span = 5.0, no_fog = true, relative_pos = {x = -120, y = 0}, set_color = ccc3(128, 128, 128)}
						},
						{
							CLASS = "action.QSBSummonGhosts",
			            	OPTIONS = {actor_id = 41584, life_span = 5.0, no_fog = true, relative_pos = {x = 120, y = 0}, set_color = ccc3(128, 128, 128)}, 
						},
					},
				},
			},
		},
	}
}

return fenshen