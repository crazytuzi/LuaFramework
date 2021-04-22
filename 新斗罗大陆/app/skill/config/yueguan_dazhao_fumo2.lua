--暂弃
local yueguan_dazhao_fumo1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlaySound",
			OPTIONS = {sound_id ="judouluo_walk"},
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
					OPTIONS = {effect_id = "yueguancz_attack11_2"}
				}
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 16},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "yueguancz_attack11_1"}
				}
			},
		},
		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 115},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
                },
            },
        },
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 115},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
                },

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
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
				{
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
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
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = -50, y = 200}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = 180, y = 150}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = 250, y = 0}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = 180, y = -150}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = -50, y = -200}, use_render_texture = false},
										},
									},	
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 14},
								},
								{
									CLASS = "action.QSBArgsIsDirectionLeft",
									OPTIONS = {is_attacker = true},
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
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = -50, y = 200}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = 180, y = 150}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = 250, y = 0}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = 180, y = -150}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = -50, y = -200}, use_render_texture = false},
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
									OPTIONS = {delay_frame = 20},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = 50, y = 200}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = -180, y = 150}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = -250, y = 0}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = -180, y = -150}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,relative_pos = {x = 50, y = -200}, use_render_texture = false},
										},
									},	
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 14},
								},
								{
									CLASS = "action.QSBArgsIsDirectionLeft",
									OPTIONS = {is_attacker = true},
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
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = 50, y = 200}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = -180, y = 150}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = -250, y = 0}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = -180, y = -150}, use_render_texture = false},
												},
												{
													CLASS = "action.QSBSummonGhosts",
													OPTIONS = {actor_id = 1019, life_span = 12.0,number = 1, no_fog = true,relative_pos = {x = 50, y = -200}, use_render_texture = false},
												},
											},	
										},
									},
								},	
							},
						},
					},	
				},
				----------------
				{
					CLASS = "action.QSBPetApplyBuff",
					OPTIONS = {buff_id = "yueguan_dazhao_buff;y"},
				},
            },
        },
    },
}

return yueguan_dazhao_fumo1 

