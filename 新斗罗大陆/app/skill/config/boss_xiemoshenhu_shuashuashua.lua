-- 技能 BOSS邪魔神虎 刷刷刷
-- 技能ID 50866
-- 跳到边缘刷刷刷
--[[
	boss 邪魔神虎
	ID:3696
	psf 2018-7-19
]]--

local boss_xiemoshenhu_shuashuashua = {
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{ 
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 30 / 24},
						},
						{
	                        CLASS = "action.QSBActorFadeOut",
	                        OPTIONS = {duration = 0.2, revertable = true},
	                    },
                    },
                },
            },
        },
		{
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 640, y = 300}},
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{
							CLASS = "action.QSBPlayAnimation",
						},
						{
							CLASS = "action.QSBAttackFinish",
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
							OPTIONS = {delay_frame = 13},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								{
									CLASS = "action.QSBManualMode",
									OPTIONS = {enter = true, revertable = true},
								},
								{
									CLASS = "action.QSBImmuneCharge",
									OPTIONS = {enter = true, revertable = true},
								},
								-- {
									-- CLASS = "action.QSBActorFadeOut",
									-- OPTIONS = {duration = 0.15, revertable = true},
								-- },
							},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 23},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								-- {
									-- CLASS = "action.QSBActorFadeIn",
									-- OPTIONS = {duration = 0.15, revertable = true},
								-- },
								{
									CLASS = "action.QSBImmuneCharge",
									OPTIONS = {enter = false},
								},
								{
									CLASS = "action.QSBManualMode",
									OPTIONS = {exit = true},
								},
							},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
	},
}

return boss_xiemoshenhu_shuashuashua