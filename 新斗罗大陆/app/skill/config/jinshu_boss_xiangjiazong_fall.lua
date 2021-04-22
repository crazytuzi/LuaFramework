-- 技能 象甲宗摔倒
-- 技能ID 50353
-- 扑通一声摔到地上
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_fall = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = false},
        },
		{
            CLASS = "action.QSBUncancellable",    
        },
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "boss_xiangjiazong_1_kuangbao_buff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "boss_xiangjiazong_2_kuangbao_buff"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlaySound",
		},        
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					ARGS = {
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
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 4},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBManualMode",
					OPTIONS = {exit = true},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
	},
}

return boss_xiangjiazong_fall