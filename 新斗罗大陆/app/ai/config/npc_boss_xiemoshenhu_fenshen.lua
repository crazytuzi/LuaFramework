--斗罗AI 暗黑邪魔神虎分身 3697
--普通副本17-4
--[[
退场
跳扑
]]--
--创建人：庞圣峰
--创建时间：2018-7-19


local npc_boss_xiemoshenhu = {         
    CLASS = "composite.QAISelector", 
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50098},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25, first_interval = 3.5},
                },
				{
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {status = "aim"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50868},  -- 跳扑
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1, first_interval = 18},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50869},  --退场
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
return npc_boss_xiemoshenhu