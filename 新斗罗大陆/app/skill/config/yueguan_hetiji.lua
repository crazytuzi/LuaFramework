-- 技能 月关 悠悠花开
-- ID 197
-- 魂师大招 召四朵菊花
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_hetiji = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlaySound",
		},
		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
		            CLASS = "action.QSBManualMode",     --进入手动模式
		            OPTIONS = {enter = true, revertable = true},
		        },
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
				{
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {exit = true},
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
					CLASS = "action.QSBPlayAnimation",
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
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
                    CLASS = "action.QSBArgsIsLeft",
                    OPTIONS = {is_attacker = true},
                },
				{
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
						--开大时在左
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 200, y = 250}, use_render_texture = false},
										-- },
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 200, y = 400}, use_render_texture = false},
										-- },
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 125, y = 325}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 400, y = 200}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 400, y = 450}, use_render_texture = false},
										},
									},	
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 35},
								},
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {
												-- actor_id = 40001, life_span = 10.5,number = 1, no_fog = true, absolute_pos = {x = 200, y = 250}, use_render_texture = false,
												-- is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] 
												-- percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												-- extends_level_skills = {268} --此技能可成长
											-- },
										-- },
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {
												-- actor_id = 40001, life_span = 10.5,number = 1, no_fog = true ,absolute_pos = {x = 200, y = 400}, use_render_texture = false,
												-- is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] 
												-- percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												-- extends_level_skills = {268}
											-- },
										-- },
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true,absolute_pos = {x = 125, y = 325}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true,absolute_pos = {x = 400, y = 200}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]]  dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true ,absolute_pos = {x = 400, y = 450}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
									},	
								},
								{
									CLASS = "action.QSBHitTarget",--本身无效果,用于其他地方的判定
								},
							},
						},
						
						--开大时在右
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 1200, y = 250}, use_render_texture = false},
										-- },
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 1200, y = 400}, use_render_texture = false},
										-- },
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 1275, y = 325}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 1000, y = 200}, use_render_texture = false},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 1000, y = 450}, use_render_texture = false},
										},
									},	
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 35},
								},
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {
												-- actor_id = 40001, life_span = 10.5,number = 1, no_fog = true ,absolute_pos = {x = 1200, y = 250}, use_render_texture = false,
												-- is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] 
												-- percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												-- extends_level_skills = {268}
											-- },
										-- },
										-- {
											-- CLASS = "action.QSBSummonGhosts",
											-- OPTIONS = {
												-- actor_id = 40001, life_span = 10.5,number = 1, no_fog = true ,absolute_pos = {x = 1200, y = 400}, use_render_texture = false,
												-- is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]] 
												-- percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												-- extends_level_skills = {268}
											-- },
										-- },
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true ,absolute_pos = {x = 1275, y = 325}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]]  dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true ,absolute_pos = {x = 1000, y = 200}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]]  dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {
												actor_id = 40001, life_span = 13.5,number = 1, no_fog = true,absolute_pos = {x = 1000, y = 450}, use_render_texture = false,
												is_attacked_ghost = false,--[[不能被旋转和攻击]] appear_skill = 268,--[[入场技能]]  dead_skill = 190078,
												percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
												extends_level_skills = {268}
											},
										},
									},	
								},
								{
									CLASS = "action.QSBHitTarget",
								},
							},
						},
						
					},	
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
            },
        },
    },
}

return yueguan_hetiji 

