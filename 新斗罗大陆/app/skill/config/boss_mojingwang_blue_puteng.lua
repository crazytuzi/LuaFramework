-- 技能 蓝色扑腾
-- 技能ID 50877
-- 扑腾召小怪
--[[
	boss 蓝魔鲸王
	ID:3700
	psf 2018-7-19
]]--

local boss_mojingwang_blue_puteng = {
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
						{	
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.3},
								},
								{
									CLASS = "action.QSBSummonMonsters",
									OPTIONS = { wave = -1 },
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
					-- CLASS = "action.QSBRemoveBuff",
					-- OPTIONS = {is_target = false, buff_id = "boss_mojingwang_bianshen_3700_buff"},
				-- },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_mojingwang_blue_puteng