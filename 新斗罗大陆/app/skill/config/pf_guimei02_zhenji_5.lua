-- 技能 尘心自动1 平如流水
-- 技能ID 219
-- 飞剑导弹 打五下 , 有几率上标记
-- http://myst729.github.io/bezier-curve/
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--
local function SetBullets(df,et,sp_x,sp_y,a_id)
	local _effect_id
	local _bullet
	if et then
		_effect_id = "pf_guimei02_attack14_2"
	else
		_effect_id = "pf_guimei02_attack14_2"
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
					effect_id = _effect_id, hit_effect_id = "pf_guimei02_attack14_3", 
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
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {revertable = true,},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_guimei02_attack14_1"},
				},
				{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
				SetBullets(27,true,120,125,1),
				SetBullets(31,false,110,130,2),
				SetBullets(36,true,120,125,3),
				SetBullets(41,false,115,120,4),
				SetBullets(45,true,120,125,5),
				SetBullets(49,false,125,130,6),
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 53},
						},
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {effect_id = "pf_guimei02_attack14_2", target_random = true, start_pos = {x = 120,y = 140}, rail_number = 4, rail_delay = 0.033, is_bezier = true},------第一颗子弹
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
							OPTIONS = {effect_id = "pf_guimei02_attack14_2", target_random = true, start_pos = {x = 120,y = 110}, rail_number = 4, rail_delay = 0.033, is_bezier = true},------第一颗子弹
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
}

return guimei_zhenji_5

