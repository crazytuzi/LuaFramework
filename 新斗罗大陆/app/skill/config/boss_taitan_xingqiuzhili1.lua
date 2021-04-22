
local boss_taitan_xingqiuzhili1 = {
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
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "taitan_attack14_1",is_hit_effect = false},
		},	
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 32},
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
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 70},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
		-- {
		-- 	CLASS = "action.QSBApplyBuff",
		-- 	OPTIONS = {buff_id = "xiaowu_tongyongchongfeng_buff"},
		-- }, 
		-- {
		-- 	CLASS = "composite.QSBSequence",
		-- 	OPTIONS = {revertable = true},
		-- 	ARGS = 
		-- 	{
				-- {
    --                 CLASS = "action.QSBDelayTime",
    --                 OPTIONS = {delay_time = 13 / 24 },
    --             },
		-- 		{
		-- 			CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
		-- 			OPTIONS = {move_time = 0.75},
		-- 		},
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_time = 0.5},
  --               },
		-- 		{
		-- 			CLASS = "action.QSBRemoveBuff",
		-- 			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		-- 		},
		-- 		-- {
		-- 		-- 	CLASS = "action.QSBRemoveBuff",
		-- 		-- 	OPTIONS = {is_target = false, buff_id = "xiaowu_tongyongchongfeng_buff"},
		-- 		-- },
				-- {
				-- 	CLASS = "action.QSBAttackFinish",
				-- },
		-- 	},
		-- },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 11 / 24 },
                },
                -- {
                --  CLASS = "action.QSBSelectTarget",
                --  OPTIONS = {range_max = true},
                -- },
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {   
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attackee = true},
                                },
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 82, pass_key = {"pos"}},
                                -- },
                                {
                                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 10 / 24,offset = {x= 150,y=0}},
                                },
                            }, 
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attackee = true},
                                },
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 82, pass_key = {"pos"}},
                                -- },
                                {
                                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 10 / 24,offset = {x= -150,y=0}},
                                },
                            }, 
                        },
                    },
                },
            },
        },
	},
}

return boss_taitan_xingqiuzhili1