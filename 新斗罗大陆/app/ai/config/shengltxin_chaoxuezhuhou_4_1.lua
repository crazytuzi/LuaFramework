local npc_chaoxuezhuhou_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    { 
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 1},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53375 },  --钢甲
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 160,first_interval =9},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "dps", exclusive = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53364 },  --缠绕
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 1,first_interval=5},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 53360  },          --召唤蜘蛛1
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=34},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role  = "dps"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53378  },  --缠绕
                },
            },
        },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 1,first_interval=20},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --              OPTIONS = {skill_id = 53361  },  --召唤蜘蛛2
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1,first_interval=30},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53362  },          --召唤蜘蛛3
                },
            },
        },


        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                }
            },
        },
    },
}
        
return npc_chaoxuezhuhou_ai