-- 技能 红色扑腾
-- 技能ID 50876
-- 扑腾留下陷阱
--[[
	boss 红魔鲸王
	ID:3699
	psf 2018-7-19
]]--

local boss_mojingwang_red_puteng = {
    CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{	
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsIsDirectionLeft",
					OPTIONS = {is_attacker = true,},
				},
				{
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "right"},
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
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBHeroicalLeap",
							OPTIONS = {speed = 700 ,move_time = 2 ,interval_time = 0.5 ,is_hit_target = false ,bound_height = 50,outside = true},
						},
						{	
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.2},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.25},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.25},
								},
								{
									 CLASS = "action.QSBHitTarget",
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				-- {
					-- CLASS = "action.QSBApplyBuff",
					-- OPTIONS = {is_target = false, buff_id = "boss_mojingwang_bianshen_3700_buff",no_cancel = true},
				-- },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_mojingwang_red_puteng