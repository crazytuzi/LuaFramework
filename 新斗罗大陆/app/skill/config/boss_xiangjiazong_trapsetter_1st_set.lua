-- 技能 象甲宗缠绕陷阱初次置
-- 技能ID 50377
-- 左半场或右半场放置陷阱,并召唤相应定位怪,提供提示引导
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_trapsetter_1st_set = {
    CLASS = "composite.QSBSequence",
    ARGS = {
	-- 暂时固定位置
		-- {
			-- CLASS = "composite.QSBSequence",
			-- ARGS = {
				-- {
					-- CLASS = "action.QSBRandomTrap",
					-- OPTIONS = {trapId = "npc_boss_xiangjiazong_1_left_trap",interval_time = 0.25,count = 1}
				-- },
				-- {
					-- CLASS = "action.QSBAttackFinish",
				-- },
			-- },
		-- },
        {
			CLASS = "action.QSBArgsIsLeft",
			OPTIONS = {is_attackee = true},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBRandomTrap",
							OPTIONS = {trapId = "npc_boss_xiangjiazong_1_left_trap",interval_time = 0.25,count = 1}
						},
						{
							CLASS = "action.QSBSummonMonsters",
							OPTIONS = {wave = -1},
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
							CLASS = "action.QSBRandomTrap",
							OPTIONS = {trapId = "npc_boss_xiangjiazong_1_right_trap",interval_time = 0.25,count = 1}
						},
						{
							CLASS = "action.QSBSummonMonsters",
							OPTIONS = {wave = -2},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
        },
    },
}

return boss_xiangjiazong_trapsetter_1st_set