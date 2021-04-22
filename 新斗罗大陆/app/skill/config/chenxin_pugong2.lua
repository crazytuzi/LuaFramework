-- 技能 尘心普攻2
-- 技能ID 201216
-- 普攻1次
--[[
	hero 尘心太极仙剑皮肤
	ID:1028 
	psf 2019-7-25
]]--

local chenxin_pugong2 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack02"},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 65,y = 105},effect_id = "jiandouluo_attack1_2",hit_effect_id = "jiandouluo_attack1_3"
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 9},
                },
                {
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = -60,y = 105},effect_id = "jiandouluo_attack1_2",hit_effect_id = "jiandouluo_attack1_3"
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },     
    },
}

return chenxin_pugong2

