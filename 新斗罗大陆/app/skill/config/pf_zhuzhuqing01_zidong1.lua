local zhuzhuqing_zidong1 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "canying"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "zhuzhuqing_canying", is_target = false},
                        },
                        {
                            CLASS = "action.QSBPlaySound"
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
									CLASS = "action.QSBPlayAnimation",
								},
								{
									CLASS = "composite.QSBSequence", 
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 12},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_1", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
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
											OPTIONS = {delay_frame = 23},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_2", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
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
											OPTIONS = {delay_frame = 47},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_3", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
												},
											},
										},
									},
								},
                                
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBArgsIsDirectionLeft",
                                            OPTIONS = {is_attacker = true},
                                        },
                                        {
                                            CLASS = "composite.QSBSelector",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, skin_id = 34, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -160, y = 0}, 
                                                        appear_skill = 362,--[[入场技能]]direction = "right",
                                                        extends_level_skills = {362}, same_target = true, clean_new_wave = true
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, skin_id = 34, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 160, y = 0}, 
                                                        appear_skill = 362,--[[入场技能]]direction = "left",
                                                        extends_level_skills = {362}, same_target = true, clean_new_wave = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "action.QSBApplyBuff",
                                        --     OPTIONS = {buff_id = "zhuzhuqing_yingzi_zidong1", is_target = true},
                                        -- },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySound"
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
									CLASS = "action.QSBPlayAnimation",
								},
								{
									CLASS = "composite.QSBSequence", 
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 12},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_1", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
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
											OPTIONS = {delay_frame = 23},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_2", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
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
											OPTIONS = {delay_frame = 47},
										},
										{
											CLASS = "composite.QSBParallel", 
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack13_3", is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = { is_hit_effect = true},
												},
											},
										},
									},
								},
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return zhuzhuqing_zidong1