local ultra_flame_buffet = {	-- 烈焰打击
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true,},
			ARGS = {
	            {
	                CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = true, revertable = true},
	            },
	            {
	                CLASS = "action.QSBBulletTime",
	                OPTIONS = {turn_on = true, revertable = true},
	            },
	            {
	                CLASS = "action.QSBActorScale",
	                OPTIONS = {is_attacker = true, scale_to = 1.4, duration = 0},
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.72},
	            },
	            {
	                CLASS = "action.QSBActorScale",
	                OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0},
	            },
	            {
	                CLASS = "action.QSBBulletTime",
	                OPTIONS = {turn_on = false},
	            },
	            {
	                CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = false},
	            },
			},
		},

		{					-- 竞技场黑屏
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true,},
			ARGS = {
	            {
	                CLASS = "action.QSBShowActorArena",
	                OPTIONS = {is_attacker = true, turn_on = true, revertable = true},
	            },
	            {
	                CLASS = "action.QSBBulletTimeArena",
	                OPTIONS = {turn_on = true, revertable = true},
	            },
	            {
	                CLASS = "action.QSBActorScale",
	                OPTIONS = {is_attacker = true, scale_to = 1.4, duration = 0},
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.72},
	            },
	            {
	                CLASS = "action.QSBActorScale",
	                OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0},
	            },
	            {
	                CLASS = "action.QSBBulletTimeArena",
	                OPTIONS = {turn_on = false},
	            },
	            {
	                CLASS = "action.QSBShowActorArena",
	                OPTIONS = {is_attacker = true, turn_on = false},
	            },
			},
		},
		-- animation
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
		        {
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack11"},
		        },
		        {
		            CLASS = "action.QSBAttackFinish",
		        },
			},
		},
		-- effect
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
		        {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "alar_1_1", is_hit_effect = false},
		        },
		        {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "alar_1_2", is_hit_effect = false},
		        },
			},
		},
		-- bullet
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true,},
			ARGS = {
		        {
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1.78},
		        },
		        {
		        	CLASS = "action.QSBUncancellable",
		    	},
				{
					CLASS = "action.QSBArgsIsLeft",
					OPTIONS = {is_attackee = true},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, hit_effect_id = "flame_buffet_hit_3", shake = {amplitude = 15, duration = 0.17, count = 1},
			        						start_pos = {x = 1280 - -100, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.35 / 16.0},
								},
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, shake = {amplitude = 17, duration = 0.17, count = 1},
			        						start_pos = {x = 1280 - 500, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.15 / 10.0},
								},
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, shake = {amplitude = 20, duration = 0.17, count = 1},
			        						start_pos = {x = 1280 - 600, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.15 / 10.0},
				                },
								{
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.15, count = 1,},
				                },
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, hit_effect_id = "flame_buffet_hit_3", shake = {amplitude = 15, duration = 0.17, count = 1},
			        						start_pos = {x = -100, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.35 / 16.0},
								},
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, shake = {amplitude = 17, duration = 0.17, count = 1},
			        						start_pos = {x = 500, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.15 / 10.0},
								},
								{
									CLASS = "action.QSBBullet",
			        				OPTIONS = {effect_id = "alar_2", speed = 1800 * 3, time = 0.3 / 2.3, shake = {amplitude = 20, duration = 0.17, count = 1},
			        						start_pos = {x = 600, y = 600, global = true}, dead_ok = true, single = true},
								},
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.15 / 10.0},
				                },
								{
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.15, count = 1,},
				                },
							},
						},
					},
				},
			},
		},

		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "alar_y"},
                },
            },
        },

	},
} 

return ultra_flame_buffet