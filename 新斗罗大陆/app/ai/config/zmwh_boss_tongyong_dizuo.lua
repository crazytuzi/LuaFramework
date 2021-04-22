 --斗罗AI 宗门武魂BOSS 底座
--宗门武魂争霸
--id 61019~24
--[[
开场
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmwh_boss_tongyong_dizuo= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}
        
return zmwh_boss_tongyong_dizuo