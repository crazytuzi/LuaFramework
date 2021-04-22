-- 技能 恐怖骑士禁疗陷阱
-- 技能ID 50515
-- 放禁疗陷阱
--[[
	boss 恐怖骑士斯科特
	ID:3311 副本68-4
	庞圣峰 2018-4-3
]]--

local boss_kongbuqishi_summon_trap = {
	CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "boss_kongbuqishi_jinliao_trap",interval_time = 0.0,count = 1}
				},
				{
                    CLASS = "action.QSBAttackFinish",
                }, 
            },
        },
    },
}

return boss_kongbuqishi_summon_trap