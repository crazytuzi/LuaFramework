--斗罗AI 比比东BOSS蜘蛛召唤师
--副本14-16
--id 3685
--[[
召天降魔蛛陷阱
召唤魔蛛
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local npc_boss_bibidong_zhizhuzhaohuanshi = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54223},
                },
            },
        },

--------------常规技能-----------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 7, first_interval = 5},
                },
				{
                     CLASS = "action.QAIAttackByStatus",
                     OPTIONS = {status = "poisoned"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54231},     --天降魔蛛陷阱
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30, first_interval = 30},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54232},    --召唤魔蛛
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

return npc_boss_bibidong_zhizhuzhaohuanshi