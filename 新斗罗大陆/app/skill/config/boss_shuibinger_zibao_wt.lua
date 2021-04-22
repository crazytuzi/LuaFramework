-- 技能 冰鸟武魂自爆
-- 技能ID 50662
-- 自爆AOE,冰冻周围
--[[
	boss 水冰儿 召唤钻石
	ID:3177 智慧试炼
	psf 2018-5-31
]]--

local boss_shuibinger_zibao_wt = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBPlayLoopEffect",
					OPTIONS = {effect_id = "honghuan_3", is_hit_effect = false, follow_actor_animation = true},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 33},
				},
				{
                    CLASS = "action.QSBHitTarget",
                },
				{
					CLASS = "action.QSBStopLoopEffect",
					OPTIONS = {effect_id = "honghuan_3"},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 12},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
                    CLASS = "action.QSBAttackFinish",
                },
			},
		},	
        {
			CLASS = "action.QSBPlayAnimation",
		},
    },
}

return boss_shuibinger_zibao_wt

