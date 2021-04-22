-- 技能 尘心自动2 杀气毕露
-- 技能ID 201220
-- 飞出剑气,攻击单体. 目标每层破绽会增加一段伤害.
--[[
	hero 尘心
	ID:1028 
	psf 2019-7-25
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
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_jiandouluo02_attack14_1",is_hit_effect = false,haste = true},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_jiandouluo02_attack14_1_2",is_hit_effect = false,haste = true},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 36},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 0,y = 105},effect_id = "pf_jiandouluo02_attack14_2"
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
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
					OPTIONS = {delay_frame = 41}
				},
				{
					CLASS = "action.QSBAttackByBuffNum",
					OPTIONS = {buff_id = "chenxin_pojia_debuff", num_pre_stack_count = 1, trigger_skill_id = 201222, target_type = "target"},
				},
			},
		},
    },
}

return chenxin_zidong2

