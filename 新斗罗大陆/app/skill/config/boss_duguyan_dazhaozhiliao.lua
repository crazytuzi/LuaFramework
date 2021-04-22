-- 技能 独孤雁攻击指令
-- 给目标上被集火DEBUFF,队友上集火BUFF(BUFF本身没有效果,只是表现)
--[[
	boss 独孤雁
	ID:3252 副本3-16
	庞圣峰 2018-3-24
]]--

local boss_duguyan_dazhaozhiliao = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {  
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 32},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBApplyBuffMultiple",
					OPTIONS = {target_type = "teammate",buff_id = "boss_duguyan_yinchang_buff"},
				},
			},
		},
    },
}

return boss_duguyan_dazhaozhiliao