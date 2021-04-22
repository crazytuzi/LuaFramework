-- 技能 尘心普攻1
-- 技能ID 201215
-- 普攻1次
--[[
	hero 尘心太极仙剑皮肤
	ID:1028 
	psf 2019-7-25
]]--

local chenxin_pugong1 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack01"},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 19},
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
                    OPTIONS = {delay_frame = 20},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 65,y = 105},effect_id = "jiandouluo_attack1_2",hit_effect_id = "jiandouluo_attack1_3"
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },     
    },
}

return chenxin_pugong1

