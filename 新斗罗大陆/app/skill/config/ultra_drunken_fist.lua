-- 张南：熊猫醉拳的特效配置
-- "drunken_fist_1_1": {
--     "id": "drunken_fist_1_1",
--     "file": "drunken_fist_1_1",
--     "scale": 2,
--     "play_speed": 1,
--     "offset_x": 75,
--     "offset_y": 25,
--     "rotation": 0
-- },
-- "drunken_fist_1_2": {
--     "id": "drunken_fist_1_2",
--     "file": "drunken_fist_1_2",
--     "scale": 1,
--     "play_speed": 1,
--     "rotation": 0,
--     "dummy": "dummy_bottom"
-- },
-- "drunken_fist_1_3": {
--     "id": "drunken_fist_1_3",
--     "file": "drunken_fist_1_3",
--     "scale": 1,
--     "play_speed": 1,
--     "offset_x": 500,
--     "offset_y": 0,
--     "rotation": 0,
--     "dummy": "dummy_weapon"
-- },
-- "drunken_fist_1_4": {
--     "id": "drunken_fist_1_4",
--     "file": "drunken_fist_1_4",
--     "scale": 1,
--     "play_speed": 1,
--     "offset_x": 225,
--     "offset_y": 0,
--     "rotation": 0
-- }

local ultra_drunken_fist = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "blade_fury_buff"},
		},
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
		            CLASS = "action.QSBRemoveBuff",
		            OPTIONS = {buff_id = "blade_fury_buff"},
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
							OPTIONS = {effect_id = "drunken_fist_1_1"},
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
							OPTIONS = {delay_frame = 51},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_3"},
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
							OPTIONS = {delay_frame = 52},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_fist_1_4"},
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

return ultra_drunken_fist