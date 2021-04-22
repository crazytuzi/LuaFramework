--风尾鸡冠蛇
--普通副本
--id 3024  2-3
--[[
单体：眩晕
毒液陷阱
直线冲锋 带击飞和眩晕
召唤一次直线冲锋的小蛇（绿色换皮）
]]
--创建人：许成
--创建时间：2017-7-4
--迭代: 庞圣峰 2018-3-23

local npc_boss_mantuoluoshewang1_1= 
{     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =45,first_interval=3},
                },
                {
                   CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50191},          --毒潭
                },
            },
        },        
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
        
return npc_boss_mantuoluoshewang1_1