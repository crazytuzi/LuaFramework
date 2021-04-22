-- 技能 BOSS人面魔蛛喷吐蛛网
-- 在场上随机地点丢出2个蛛网陷阱
--[[
	boss 人面魔蛛
	ID:3247 副本2-6
	psf 2018-3-23
]]--
--创建人：庞圣峰
--创建时间：2018-3-23

local boss_renmianmozhu_pentuzhuwang = {
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
            ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 63},
				},
				{
					CLASS = "action.QSBRandomTrap",
					OPTIONS = {trapId = "boss_dixuemozhu_zhuwang_trap",interval_time = 0.25,count = 1}
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
    },
}

return boss_renmianmozhu_pentuzhuwang

