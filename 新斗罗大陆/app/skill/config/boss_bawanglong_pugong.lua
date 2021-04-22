-- 技能 霸王龙普攻
-- 技能ID 52180
--[[
	hunling 霸王龙
	ID:3950
	psf 2019-11-11
]]--
local boss_bawanglong_pugong = 
{
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 12 },
				},
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 15 },
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.15, plunder_rage_max = 16},
						},
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 45 },
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_hl_bawanglong_highest_rage_mark",enemy = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_hl_bawanglong_highest_rage_mark",highest_rage_enemy = true},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
    },
}

return boss_bawanglong_pugong