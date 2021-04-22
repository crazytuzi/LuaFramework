
local boss_taitan_chongquan1 = {
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
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack12_1",is_loop = true},
		},
		
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 30},
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
					   
					},
				},
			},
		},
		
	
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.7},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "taitan_chongfeng_buffbo"},
				}, 
				{
					CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
					OPTIONS = {move_time = 0.3},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "taitan_chongfeng_buffbo"},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_taitan_chongquan1