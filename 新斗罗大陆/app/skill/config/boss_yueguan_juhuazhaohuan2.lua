--BOSS 月关第二波召唤
--NPC ID: 3313
--技能ID: 50404
--召唤4-6个,玄冰草
--创建人：庞圣峰
--创建时间:2018-4-6


local boss_yueguan_juhuazhaohuan2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 8},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "boss_yueguancz_attack11_1"}
				}
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 40},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "boss_yueguancz_attack11_2"}
				}
			},
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 75},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, effect_id = "juhuaguai_attack01_3" ,absolute_pos = {x = 350, y = 500}, use_render_texture = false},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, effect_id = "juhuaguai_attack01_3" ,absolute_pos = {x = 640, y = 425}, use_render_texture = false},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, effect_id = "juhuaguai_attack01_3" ,absolute_pos = {x = 1200, y = 350}, use_render_texture = false},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, effect_id = "juhuaguai_attack01_3" ,absolute_pos = {x = 640, y = 275}, use_render_texture = false},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, effect_id = "juhuaguai_attack01_3" ,absolute_pos = {x = 350, y = 200}, use_render_texture = false},
						},
					},	
				},
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 20},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBSummonMonsters",
									OPTIONS = {wave = -1},
								},
								{
									CLASS = "action.QSBSummonMonsters",
									OPTIONS = {wave = -2},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBArgsRandom",
											OPTIONS = {
												input = {
													datas = {-3,-4},
												},
												output = {output_type = "data"},
												args_translate = { select = "wave"}
											},
										},
										{
											CLASS = "action.QSBSummonMonsters",
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBArgsRandom",
											OPTIONS = {
												input = {
													datas = {-5,-6},
												},
												output = {output_type = "data"},
												args_translate = { select = "wave"}
											},
										},
										{
											CLASS = "action.QSBSummonMonsters",
										},
									},
								},
							},	
						},
					},
				},
            },
        },
    },
}

return boss_yueguan_juhuazhaohuan2