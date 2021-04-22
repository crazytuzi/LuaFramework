
local team_npc_boss_razorlash = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
---------------------------------------免疫------------------------------------------
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
--------------------------------------AOE技能------------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 10},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203002},
                },
            },
        },
--------------------------------------召唤---------------------------------------------        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 5},
                },
        		{
        			CLASS = "action.QAIUseSkill",
        			OPTIONS = {skill_id = 203001},
        		},
            },
        },
 ---------------------------------------------------------------------------------------       
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

return team_npc_boss_razorlash