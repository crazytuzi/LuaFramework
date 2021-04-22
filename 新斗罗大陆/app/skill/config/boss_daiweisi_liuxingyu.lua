--BOSS 戴维斯流星雨
--NPC ID: 3312
--技能ID: 50400
--以目标为中心放个小AOE
--创建人：庞圣峰
--创建时间:2018-4-4

local boss_daiweisi_liuxingyu = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.2},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anim_slowplay_01"},
				}, 
				{
					CLASS = "action.QSBPlayLoopEffect",
					OPTIONS = {effect_id = "hongquan_1", is_hit_effect = false, follow_actor_animation = true},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 3},
				},					
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anim_slowplay_01"},
				},
				{
					CLASS = "action.QSBStopLoopEffect",
					OPTIONS = {effect_id = "hongquan_1"},
				},
			},
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
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},

		
    },
}

return boss_daiweisi_liuxingyu