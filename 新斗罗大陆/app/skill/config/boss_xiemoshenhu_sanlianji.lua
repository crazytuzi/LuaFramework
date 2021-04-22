-- 技能 BOSS邪魔神虎 三连击
-- 技能ID 50865
-- 蓄力红框打三下
--[[
	boss 邪魔神虎
	ID:3696
	psf 2018-7-19
]]--

local boss_xiemoshenhu_sanlianji = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai",no_cancel = false,revertable = true},
		},
		{
			CLASS = "action.QSBPlaySound",
		},        
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
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_xiemoshenhu_sanlianji_circle", is_target = false,no_cancel = false,revertable = true},--红框
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3},
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

return boss_xiemoshenhu_sanlianji