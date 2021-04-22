
local zudui_qianrenxue =
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
                    OPTIONS = {interval = 500,first_interval = 500},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54223},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 2},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54238},--召唤-1
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 5},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54213},--剑雨
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 7},
                },
                -- {
                --     CLASS = "action.QAIAttackEnemyOutOfDistance",
                --     OPTIONS = {current_target_excluded = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54238},---召唤-1
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 8},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54214},--4连神罚
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 13},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54239},--召唤-2
                },
            },
        },
	    {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54215},--终结1
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 70,first_interval = 33},
        --         },
        --         {
        --             CLASS = "action.QAIAttackByHitlog",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 54216},--领域
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 36},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54239},--召唤-1
                }, 
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 40},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54213},--剑雨
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 42},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54238},--4连神罚
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 43},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54214},--召唤-1
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 48},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54239},--召唤-2
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 50},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 54217},--终结1
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

return zudui_qianrenxue