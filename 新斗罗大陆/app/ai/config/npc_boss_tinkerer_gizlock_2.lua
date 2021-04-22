
local npc_boss_tinkerer_gizlock = {
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
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval = 10,relative = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 201809},-----------------------------------------地精龙骑
				},
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12, first_interval = 9, relative = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
                    CLASS = "action.QAIIgnoreHitLog",
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200502},----------------------------------------冲锋
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval = 4,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 201810},--------------------------------------定时炸弹
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 15,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 201810},----------------------------------------定时炸弹
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=25, relative = true},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
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

return npc_boss_tinkerer_gizlock