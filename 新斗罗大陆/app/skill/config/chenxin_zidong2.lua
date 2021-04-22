-- 技能 尘心自动2 杀气毕露
-- 技能ID 220
-- 飞出剑气,攻击单体. 目标每层破绽会增加一段伤害.
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_zidong2 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
        {
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack14"},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "jiandouluo_attack14_1",is_hit_effect = false,haste = true},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "jiandouluo_attack14_1_1",is_hit_effect = false,haste = true},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 51},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 0,y = 105},effect_id = "jiandouluo_attack14_2",hit_effect_id = "jiandouluo_attack14_3"
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
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
					OPTIONS = {delay_frame = 56}
				},
				{
					CLASS = "action.QSBAttackByBuffNum",
					OPTIONS = {buff_id = "chenxin_pojia_debuff", num_pre_stack_count = 1, trigger_skill_id = 222, target_type = "target"},
				},
			},
		},
    },
}

return chenxin_zidong2

