 --斗罗AI 宗门武魂BOSS天气 雷雨
--宗门武魂争霸
--id 61035
--[[
打雷
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmhw_boss_weather_rainy = {     
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
                    OPTIONS = {skill_id = 51392},
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
        
return zmhw_boss_weather_rainy