
local zudui_bibidong_web = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlayAnimation",
			ARGS = 
			{
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.4},
				},
				{
					CLASS = "action.QSBTrap",
					OPTIONS = {
						trapId = "zudui_bibidong_web_trap",
						args = {{delay_time = 0 , relative_pos = { x = 0, y = 0}}},
					},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.4},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zudui_bibidong_web