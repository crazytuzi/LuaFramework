----斗罗AI：BOSS人面魔蛛
--普通副本
--id 3247  2-6
--[[
召唤小蜘蛛，小蜘蛛死亡后，留下蛛网陷阱
喷吐蛛网：喷吐两个蛛网。踩到会被定身
小怪死亡：蛛网陷阱
后排单体攻击：向后排吐毒液
]]
--创建人：庞圣峰
--创建时间：2018-3-22

local npc_boss_renmianmozhu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 45,first_interval = 15},
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50095},-- 召唤-1
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 7.5},
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50313},-- 喷吐蛛网
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 11},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50314},-- 后排毒液
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

return npc_boss_renmianmozhu