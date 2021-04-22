--斗罗SKILL 魂力聚焦
--宗门武魂争霸
--id 51338
--通用 马甲
--[[
目标脚底陷阱
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_tongyong_first1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
					CLASS = "action.QSBLockTarget",     --锁定目标
					OPTIONS = {is_lock_target = true, revertable = true},
				},
				{
					CLASS = "action.QSBMultipleTrap",
					OPTIONS = {
						trapId = "zmwh_boss_tongyong_first1_trap",count = 1,
					},
				},
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = {is_lock_target = false},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zmwh_boss_tongyong_first1

