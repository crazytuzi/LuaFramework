
local npc_boss_liuerlong = {         --柳二龙转BOSS
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
                                    OPTIONS = {interval = 20, first_interval=20},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50117},--火龙爆裂斩
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 20, first_interval=15},
                                },
                                {
                                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50116},--龙爪手
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 20, first_interval=5},
                                },
                                {
                                    CLASS = "action.QAIIsAttacking",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50148},--三连击
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QAISequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QAITimer",
                        --             OPTIONS = {interval = 20, first_interval=9},
                        --         },
                                -- {
                                --     CLASS = "action.QAIAttackEnemyOutOfDistance",
                                --     OPTIONS = {always = true},
                                -- },
                        --         {
                        --             CLASS = "action.QAIUseSkill",
                        --             OPTIONS = {skill_id = 50219},--疾跑
                        --         },
                        --         {
                        --             CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 20, first_interval=9},
                                },
                                {
                                    CLASS = "action.QAIIsAttacking",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50115},--火焰波动剑
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QAISequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QAITimer",
                        --             OPTIONS = {interval =25,first_interval=10.5},
                        --         },
                        --         {
                        --             CLASS = "action.QAIAcceptHitLog",
                        --         },
                        --     },
                        -- },
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

return npc_boss_liuerlong