-- 技能 鬼魅皮肤自动2 鬼影牌真技强化
-- 技能ID 290129
-- http://myst729.github.io/bezier-curve/
--[[
	hero 鬼魅
	ID:1017 
	psf 2019-3-26
]]--

local function SetBullets(df,et,sp_x,sp_y,a_id)
	local _effect_id
	local _bullet
	if et then
		_effect_id = "pf_guimei01_attack14_2_1"
	else
		_effect_id = "pf_guimei01_attack14_2_2"
	end
	_bullet = {
		CLASS = "composite.QSBSequence",
		ARGS = {
			{
				CLASS = "action.QSBDelayTime",
				OPTIONS = {delay_frame = df},
			},
			{
				CLASS = "action.QSBBullet",
				OPTIONS = {
					effect_id = _effect_id, hit_effect_id = "pf_guimei01_attack14_3", 
					speed = 1600, target_random = true, start_pos = {x = sp_x,y = sp_y}, is_bezier = true,ani_atk_idx = a_id
				},
				set_points = { 
					{{x = 150, y = -300},{x = 300, y = 0}}, 
					{{x = 140, y = 325},{x = 300, y = 0}}, 
					{{x = 170, y = 80}}, 
					{{x = 155, y = -90}}, 
					{{x = 115, y = 275},{x = 300, y = -150}}, 
					{{x = 130, y = -200},{x = 300, y = 150}}, 
				},
			},
		},
	}
	return _bullet
end

local guimei_zhenji_5 = {
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
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack14"},
                        },
						SetBullets(27,true,194.8,109.4,1),
						SetBullets(31,false,172.7,147.6,2),
						SetBullets(36,true,182.7,114.5,3),
						SetBullets(41,false,164.7,126.5,4),
						SetBullets(45,true,194.8,109.4,5),
						SetBullets(49,false,195.8,109.4,6),
						--真技额外
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 53},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "pf_guimei01_attack14_2_2", target_random = true, start_pos = {x = 180,y = 80}, is_bezier = true},------第一颗子弹
                                    set_points = { 
                                        {{x = 150, y = -250},{x = 300, y = 0}},
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 60},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "pf_guimei01_attack14_2_1", target_random = true, start_pos = {x = 180,y = 0}, is_bezier = true},------第二颗子弹
                                    set_points = { 
                                        {{x = 170, y = -300},{x = 300, y = 0}},
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
}

return guimei_zhenji_5

