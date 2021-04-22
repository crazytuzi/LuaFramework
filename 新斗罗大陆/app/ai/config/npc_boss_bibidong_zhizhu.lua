--斗罗AI 比比东BOSS蜘蛛
--副本14-16
--id 3686
--[[
普攻
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local npc_boss_bibidong_zhizhu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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

return npc_boss_bibidong_zhizhu