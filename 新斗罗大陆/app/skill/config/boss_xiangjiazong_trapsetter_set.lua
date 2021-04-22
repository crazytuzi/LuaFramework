-- 技能 象甲宗缠绕陷阱放置
-- 技能ID 50378
-- 陷阱放置者随机放陷阱
--[[
	boss 象甲宗陷阱放置者
	ID:3289 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_trapsetter_set = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "npc_boss_xiangjiazong_1_trap",interval_time = 0.25,count = 1}
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_xiangjiazong_trapsetter_set