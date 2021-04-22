-- 技能 尘心自动1 平如流水
-- 技能ID 219
-- 飞剑导弹 打五下 , 有几率上标记
-- http://myst729.github.io/bezier-curve/
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_zidong1 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack13"},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "jiandouluo_attack13_1",haste =true},
				}, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = -60,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 150, y = -300},{x = 300, y = 0}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 65,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 140, y = 325},{x = 300, y = 0}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = -60,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 170, y = 80}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 65,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 155, y = -90}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = -60,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 115, y = 275},{x = 300, y = -150}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 65,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 130, y = -200},{x = 300, y = 150}},  
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = -60,y = 105},
						effect_id = "jiandouluo_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, 
						hit_effect_id = "jiandouluo_attack13_3", is_bezier = true, bullet_delay = 0.07, 
						set_points = { 
							{{x = 150, y = -250},{x = 300, y = 0}}, 
						} 
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },     
    },
}

return chenxin_zidong1

