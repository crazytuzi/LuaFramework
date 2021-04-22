--斗罗AI 兽武魂落地的手
--宗门武魂争霸
--id 61033
--[[
入场
待机
死亡
爆炸
]]--
--创建人：庞圣峰
--创建时间：2019-1-4

local zmwh_boss_shouwuhun_dazhaoer = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.5, first_interval = 4.8},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51375},
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51375},     --兽武魂爆炸
                },
            },
        },
--------------------------------------------------
			
        {
            CLASS = "action.QAIAttackByHitlog",
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

return zmwh_boss_shouwuhun_dazhaoer