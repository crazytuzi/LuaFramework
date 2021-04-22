
local boss_dugubo_blink = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 16},
	            },
				{
					CLASS = "action.QSBHitTarget",
                },
				{  
					CLASS = "composite.QSBSequence",
					OPTIONS = {forward_mode = true,},
					ARGS = {
						{
							CLASS = "action.QSBArgsIsLeft", -- 根据目标是否在屏幕左半侧选择
							OPTIONS = {is_attackee = true},
						},
						-- {
							-- CLASS = "composite.QSBSelector",
							-- OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
							-- ARGS = {
								-- {
									-- CLASS = "action.QSBArgsPosition",
									-- OPTIONS = {x = 1000, is_attackee = true}, -- 生成传递参数 pos = {x = 800, y = 目标的y轴}
								-- },
								-- {
									-- CLASS = "action.QSBArgsPosition",
									-- OPTIONS = {x = 200, is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
								-- },
							-- },
						-- },
						{
							CLASS = "composite.QSBSelector",
							OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
							ARGS = {
								{
									CLASS = "action.QSBSetActorToPos",
									OPTIONS = {pos = {x = 1000, y = 300},speed = 1500, effectId = "haunt_3"},
								},
								{
									CLASS = "action.QSBSetActorToPos",
									OPTIONS = {pos = {x = 240, y = 300},speed = 1500, effectId = "haunt_3"},
								},
							},
						},
					}, 
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "boss_yuxiaogang_chengshuishoulei_hongquan", is_target = true},
        -- },
    },
}

return boss_dugubo_blink

