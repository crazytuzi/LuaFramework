--人面魔蛛小怪
--普通副本（BOSS死后召唤，会治疗友军，BOSS出现后会提升BOSS生命上限，并自杀）
--创建人：庞圣峰
--创建时间：2018-1-5

local npc_renmianmozhu_zhiliaoboss = {
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
                    OPTIONS = {skill_id = 50143},		--治疗光环、自身禁疗
                },
            },
        },
				{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=20},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50144},          --提升BOSS生命上限
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200115},          --自杀
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

return npc_renmianmozhu_zhiliaoboss