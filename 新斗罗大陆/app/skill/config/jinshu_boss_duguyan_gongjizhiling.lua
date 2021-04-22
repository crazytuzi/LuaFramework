-- 技能 独孤雁攻击指令
-- 给目标上被集火DEBUFF,队友上集火BUFF(BUFF本身没有效果,只是表现)
--[[
	boss 独孤雁
	ID:3252 副本3-16
	庞圣峰 2018-3-24
]]--

local boss_duguyan_gongjizhiling = {
    CLASS = "composite.QSBParallel",
	OPTIONS = {revertable = true},
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = true ,buff_id = "boss_duguyan_attack_order_debuff"},
				},
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return boss_duguyan_gongjizhiling

