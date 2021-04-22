--斗罗SKILL 漂浮物离场
--宗门武魂争霸
--id 51374
--通用 漂浮物
--[[
离场消失
]]--
--创建人：庞圣峰
--创建时间：2019-1-3

local zmwh_boss_tongyong_second2_leave = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
     	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.5},
				},
                {
					CLASS = "action.QSBSuicide",
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {no_stand = true},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}
return zmwh_boss_tongyong_second2_leave