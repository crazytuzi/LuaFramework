
local npc_gonghui_boss_1 = {
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
                    OPTIONS = {skill_id = 201107},
                },
            },
        },
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
                    OPTIONS = {skill_id = 304016},      --BOSS开始加减攻击力
                },
            },
        },
        {
            CLASS = "composite.QAISequence",            -- BOSS第一阶段
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 0, to = 60, relative = true},
                },
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
                                    OPTIONS = {interval = 12, first_interval=15},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304001},          --风盘禁锢
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 6, first_interval=8},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304002},          --风压
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 6, first_interval=5},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304003},          --风之刺
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QAISequence",            -- BOSS第二阶段
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 60, to = 90, relative = true},
                },
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
                                    OPTIONS = {interval = 12, first_interval=61},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304001},          --风盘禁锢
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 12, first_interval=62},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304001},          --风盘禁锢
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 5, first_interval=65},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304002},          --风压
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 5, first_interval=64},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304003},          --风之刺
                                },
                            },
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "composite.QAISequence",            -- BOSS第三阶段
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 91, relative = true},
                },
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
                                    OPTIONS = {interval = 12, first_interval=91},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304001},          --风盘禁锢
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 12, first_interval=92},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304001},          --风盘禁锢
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 6, first_interval=93},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304002},          --风压
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 6, first_interval=96},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304002},          --风压
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 6, first_interval=95},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304003},          --风之刺
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

return npc_gonghui_boss_1