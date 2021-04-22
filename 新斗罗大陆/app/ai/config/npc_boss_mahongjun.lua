
local npc_boss_mahongjun = {         --马红俊转BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201107},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",            -- BOSS第一阶段
            ARGS = 
            {
                -- {
                --     CLASS = "action.QAITimeSpan",
                --     OPTIONS = {from = 0, to = 60, relative = true},
                -- },
                {
                    CLASS = "composite.QAISelector",    -- 同时执行下3个技能
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 30, first_interval=14},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50122},--凤凰火线
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 15, first_interval=5},
                                },
                                {
                                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50125},--凤凰啸天击
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 15, first_interval=10},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50126},--凤凰流星雨
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIHPLost",
                                    OPTIONS = {hp_less_then = {0.5},only_trigger_once = true},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50147},--闪现
                                },
                            },
                        },
                    },
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

return npc_boss_mahongjun