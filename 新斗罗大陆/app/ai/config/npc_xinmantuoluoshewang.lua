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
                    OPTIONS = {interval =24,first_interval=6},
                },
                -- {
                --    CLASS = "action.QAIAttackEnemyOutOfDistance",
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51312},          --甩尾
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =24,first_interval=13},
                },
                {
                   CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51313},          --甩尾
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =24,first_interval=18},
                },
                -- {
                --    CLASS = "action.QAIAttackEnemyOutOfDistance",
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51312},          --甩尾
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