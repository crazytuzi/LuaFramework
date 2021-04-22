
local team_npc_boss_cobrahn_elite = {
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
                    OPTIONS = {skill_id = 201103},        --免疫冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {               
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.5}},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200403},            --变形术
                },
            },
        },
        
        {
            CLASS = "composite.QAISequence",              --5秒放一次闪电箭
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 5,first_interval=5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},            
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

return team_npc_boss_cobrahn_elite