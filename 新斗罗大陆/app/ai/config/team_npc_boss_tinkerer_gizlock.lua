
local team_npc_boss_tinkerer_gizlock = {                --副本类型：组队副本，ID：63016，工匠地精发明家
    CLASS = "composite.QAISelector",
    ARGS = 
    {
-------------------------------免疫-----------------------------        
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
------------------------------地精龙枪------------------------------        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 5,relative = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 203004},
				},
            },
        },
-------------------------------- 冲锋-------------------------------------       
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 11, relative = true},
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
					OPTIONS = {skill_id = 200502},
				},
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10, first_interval = 21, relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200502},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
---------------------------------炸弹-----------------------------------------        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 9,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 203005},
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 19,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 203005},
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 20,relative = true},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203005},
                },
            },
        },
-------------------------------------------------------------        
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 8,first_interval=12, relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",
        --         },
        --     },
        -- },
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

return team_npc_boss_tinkerer_gizlock