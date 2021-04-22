 --斗罗AI 宗门武魂BOSS守卫
--宗门武魂争霸
--id 61029 61030
--[[
普攻
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_tongyong_shouwei= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 120,first_interval= 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51371}, --固定承伤
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
        
return zmwh_boss_tongyong_shouwei