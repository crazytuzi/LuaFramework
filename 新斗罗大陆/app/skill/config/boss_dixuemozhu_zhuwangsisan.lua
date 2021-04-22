-- 技能 蛛网四散
-- 在场上随机地点丢出3个陷阱
--[[
	boss 地穴魔蛛
	ID:3022 副本3-12
	psf 2018-1-22
]]--

local boss_dixuemozhu_zhuwangsisan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 24},
				},
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "boss_dixuemozhu_zhuwang_trap",interval_time = 0.25,count = 3}
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_dixuemozhu_zhuwangsisan

