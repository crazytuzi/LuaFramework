-- 技能 水冰儿普攻AOE
-- 技能ID 50368
-- 对周围AOE伤害,带冰冻
--[[
	boss 水冰儿 召唤钻石
	ID:3286 副本6-12
	psf 2018-4-2
]]--

local boss_shuibinger_zibao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
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

return boss_shuibinger_zibao

