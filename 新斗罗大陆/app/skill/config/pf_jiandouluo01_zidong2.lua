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
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 44},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 0,y = 105},effect_id = "pf_jiandouluo01_attack14_2"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 8},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {	
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 43}
				},
				{
					CLASS = "action.QSBAttackByBuffNum",
					OPTIONS = {buff_id = "pf_jiandouluo01_pojia_debuff", num_pre_stack_count = 1, trigger_skill_id = 200222, target_type = "target"},
				},
			},
		},
    },
}

return chenxin_zidong2

