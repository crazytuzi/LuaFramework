-- 技能 持盾冲撞
-- 原地砸一下盾牌蓄力，然后向前冲撞，击飞路径上的敌人
--[[
	boss 牛皋
	ID:3305 副本3-12
	psf 2018-1-22
]]--

local npc_niugao_chidunchongzhuang1 = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
			CLASS = "action.QSBMultipleTrap",
			OPTIONS = {trapId = "boss_niugao_chongzhuang_circle",count = 1},
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "boss_niugao_attack15_1", is_hit_effect = false},
		},
		{	
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 62},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHeroicalLeap",
							OPTIONS = {speed = 800 ,move_time = 1.2 ,interval_time = 0.2 ,is_hit_target = true ,bound_height = 50},
						},
						-- {
							-- CLASS = "composite.QSBSequence",
							-- ARGS = 
							-- {
								-- {
									-- CLASS = "action.QSBHeroicalLeap",
									-- OPTIONS = {speed = 800 ,move_time = 0.6667 ,interval_time = 1.5 ,is_hit_target = true ,bound_height = 50},
								-- },
							-- },
						-- },
					},
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

return npc_niugao_chidunchongzhuang1

