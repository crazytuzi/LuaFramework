 --斗罗AI 宗门武魂BOSS天气 大风
--宗门武魂争霸
--id 61035
--[[
龙卷风
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmhw_boss_weather_windy= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27,first_interval = 15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51394},
                },
            },
        },
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
        
return zmhw_boss_weather_windy