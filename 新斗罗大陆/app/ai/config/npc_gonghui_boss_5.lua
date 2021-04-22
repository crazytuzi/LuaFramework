    
local npc_gonghui_boss_5 = {
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
                                    OPTIONS = {interval = 500, first_interval=13},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304007},          --风神种
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 500, first_interval=26},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304007},          --风神种
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 500, first_interval=47},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304007},          --风神种
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 500, first_interval=10},
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
                                    OPTIONS = {interval = 500, first_interval=20},
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
                                    OPTIONS = {interval = 500, first_interval=40},
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
                                    OPTIONS = {interval = 500, first_interval=55},
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
                                    OPTIONS = {interval = 500, first_interval=32},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304005},          --风眼
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimeSpan",
                                    OPTIONS = {from = 0, to = 28, relative = true},
                                },
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 9, first_interval=7},
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
                                    CLASS = "action.QAITimeSpan",
                                    OPTIONS = {from = 0, to = 28, relative = true},
                                },
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 9, first_interval=5},
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

                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimeSpan",
                                    OPTIONS = {from = 40, to = 60, relative = true},
                                },
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 9, first_interval=43},
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
                                    CLASS = "action.QAITimeSpan",
                                    OPTIONS = {from = 40, to = 60, relative = true},
                                },
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 9, first_interval=41},
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
                                    OPTIONS = {interval = 500, first_interval=69},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304005},          --风眼
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 15, first_interval=62},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304008},          --风神种
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 20, first_interval=67},
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
                                    OPTIONS = {interval = 19, first_interval=64},
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
                                    OPTIONS = {interval = 4, first_interval=85},
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
                                    OPTIONS = {interval = 500, first_interval=79},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304006},          --逆风吼
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
                                    OPTIONS = {interval = 500, first_interval=90},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304006},          --逆风吼
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 500, first_interval=106},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304005},          --风眼
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 500, first_interval=101},
                                },
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 304009},          --风神种
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 18, first_interval=95},
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
                                    OPTIONS = {interval = 18, first_interval=97},
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
                                    OPTIONS = {interval = 18, first_interval=99},
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

return npc_gonghui_boss_5