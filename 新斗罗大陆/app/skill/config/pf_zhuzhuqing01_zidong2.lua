local zhuzhuqing_zidong2 = {
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
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "zhuzhuqing_zidong2_buff", is_target = true},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "pf_zhuzhuqing01_attack14_1",is_hit_effect = false},--该特效自带延迟
								},
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                },
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 27},
										},
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack14_1_1",is_hit_effect = false},
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
                                                        actor_id = 1040, skin_id = 34, life_span = 10,number = 1, no_fog = true, relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 363,--[[入场技能]]direction = "right",
                                                        extends_level_skills = {363}, same_target = true, clean_new_wave = true
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, skin_id = 34, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 363,--[[入场技能]]direction = "left",
                                                        extends_level_skills = {363}, same_target = true, clean_new_wave = true
                                                    },
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
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "pf_zhuzhuqing01_attack14_1",is_hit_effect = false},
								},
								{
                                    CLASS = "action.QSBPlayAnimation",
                                },
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 27},
										},
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {effect_id = "pf_zhuzhuqing01_attack14_1_1",is_hit_effect = false},
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
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "zhuzhuqing_zidong2_buff", is_target = true},
                        },
                        -- {
                        --     CLASS = "action.QSBRemoveBuff",
                        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
                        -- },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return zhuzhuqing_zidong2