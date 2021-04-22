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
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
					ARGS = {
						{
                            CLASS = "action.QSBBullet",
                            OPTIONS = {
								effect_id = "pf_jiandouluo01_attack13_2", speed = 1800, rail_number = 2, rail_delay = 0.033, hit_effect_id = "pf_jiandouluo01_attack1_3", is_bezier = true, bullet_delay = 0.07, 
								set_points = { 
									{{x = 150, y = -300},{x = 300, y = 0}}, 
									{{x = 140, y = 325},{x = 300, y = 0}}, 
									{{x = 170, y = 80}}, 
									{{x = 155, y = -90}}, 
									{{x = 115, y = 275},{x = 300, y = -150}}, 
									{{x = 130, y = -200},{x = 300, y = 150}}, 
									{{x = 150, y = -250},{x = 300, y = 0}}, 
								} 
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
}

return chenxin_zidong1

