--序章BOSS 鬼魅 入场
--先放陷阱，触发拖动教学，然后入场
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_guimei_ruchang = {
    CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlaySound",
		}, 
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				-- {
    --                 CLASS = "action.QSBDelayTime",
    --                 OPTIONS = {delay_time = 2.7},
    --             },
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack21"},
				},
				{
                    CLASS = "action.QSBAttackFinish"
                },
			},	
		},
	},
}

return prologue_boss_guimei_ruchang