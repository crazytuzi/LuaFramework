-- 技能 冰鸟武魂普攻AOE
-- 技能ID 50661
-- 持续对周围AOE伤害
--[[
	boss 水冰儿 召唤钻石
	ID:3177 智慧试炼
	psf 2018-5-31
]]--

local boss_shuibinger_loopattack_wt = {
    CLASS = "composite.QSBSequence",
    ARGS = {   
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai",no_cancel = true},
		},
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack_21",no_stand = true},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.6},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayLoopEffect",
									OPTIONS = {effect_id = "honghuan_3_05", is_hit_effect = false, follow_actor_animation = true},
								},
								{
									CLASS = "action.QSBPlayLoopEffect",
									OPTIONS = {effect_id = "shuibinger_attack12_3", is_hit_effect = false, follow_actor_animation = true},
								},
								{
									CLASS = "action.QSBHitTimer",
								},
							},
						},
					},
				},
            },
        },

		-- {
			-- CLASS = "action.QSBRemoveBuff",
			-- OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		-- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                    -- CLASS = "action.QSBActorKeepAnimation",
                    -- OPTIONS = {is_keep_animation = false}
                -- },
				{
					CLASS = "action.QSBStopLoopEffect",
					 OPTIONS = {effect_id = "shuibinger_attack12_3"},
				},
				{
					CLASS = "action.QSBStopLoopEffect",
					 OPTIONS = {effect_id = "honghuan_3_05"},
				},
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_shuibinger_loopattack_wt