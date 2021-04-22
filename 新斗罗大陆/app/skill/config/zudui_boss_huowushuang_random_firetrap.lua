-- 技能 BOSS火无双 普攻随机陷阱
-- 技能ID 50369
-- 随机放陷阱
--[[
	boss 火无双
	ID:3287 副本6-16
	psf 2018-3-30
]]--

local zudui_boss_huowushuang_random_firetrap = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
					OPTIONS = {delay_frame = 42},
				},
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "npc_boss_huowushuang_trap",interval_time = 0.25,count = 1}
				},
            },
        },
    },
}

return zudui_boss_huowushuang_random_firetrap