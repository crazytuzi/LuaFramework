local zuiquan = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		-- 打拳动作
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11"},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				-- 打拳特效
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_1", scale_actor_face = -1, front_layer = true},
						}
					},
				},
				-- 打拳伤害(一共四下)
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 1},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 8},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 8},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 8},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
				-- 跳起灰尘特效
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 26},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_2"},
						}
					},
				},
				-- 刀光特效
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 39},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_3", is_flip_x = true},
						},
					},
				},
				-- 地面特效（包括最后一下伤害）
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 40},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_4", scale_actor_face = -1, ground_layer = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
		},
	},
}

return zuiquan