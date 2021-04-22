local npc_boss_langdao12_4 = {
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
            CLASS = "composite.QAISelector",
            ARGS =
            {
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 300,first_interval=25},
                        },
                        {
                            CLASS = "action.QAIAttackClosestEnemy",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50721},          --召唤-1
                        },
                    },
                },
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 300,first_interval=50},
                        },
                        {
                            CLASS = "action.QAIAttackClosestEnemy",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50722},          --召唤-2
                        },
                    },
                },
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 300,first_interval=75},
                        },
                        {
                            CLASS = "action.QAIAttackClosestEnemy",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50723},          --召唤-3
                        },
                    },
                },
            },  
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12, first_interval = 8},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50333},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=5.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50414},         
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 80},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50720},
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
        
return npc_boss_langdao12_4