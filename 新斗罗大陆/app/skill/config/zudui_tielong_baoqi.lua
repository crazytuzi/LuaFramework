local zudui_tielong_baoqi = {
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
            CLASS = "action.QSBMultipleTrap",
            OPTIONS = {trapId = "tielong_tiaoyue_circle",count = 1, pass_key = {"pos"}},
        },     
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{	
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack13"},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack14"},	
					-- ARGS = 
					-- {
					-- 	{
					-- 		CLASS = "action.QSBHitTarget",
					-- 	},
					-- },											
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4, pass_key = {"pos"}},
                },
				{
					CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
					OPTIONS = {move_time = 0.3},
				},	
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 61 / 24},
                },
                {
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tiehu_attack14_3" , is_hit_effect = false},
                        },
                    },
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 40 / 24},
                },
				{
					CLASS = "action.QSBAttackFinish",
				}, 
			},
		},
	},
}

return zudui_tielong_baoqi