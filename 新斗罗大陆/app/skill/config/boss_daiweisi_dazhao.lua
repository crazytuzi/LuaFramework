--BOSS 戴维斯大招拉人
--NPC ID: 3312
--技能ID: 50401
--拉人
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
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				}, 		
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 29},
				},	
				{
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 80,y = 0} , duration = 0.25, flip_with_actor = true },
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBShakeScreen",
							OPTIONS = {amplitude = 18, duration = 0.25, count = 1,},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.75},
						},
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
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