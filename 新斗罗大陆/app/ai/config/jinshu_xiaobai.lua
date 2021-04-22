local npc_boss_xiaobai12_8 = {         
    CLASS = "composite.QAISelector",    -- 同时执行下3个技能
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
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 25},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51196},  -- 随机子弹AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 77},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51196},  -- 随机子弹AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 103},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51196},  -- 随机子弹AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 115},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51196},  -- 随机子弹AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 30},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51197},  -- 水柱阵
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51194},  -- 点名水柱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 10},
                },
                {
                     CLASS = "action.QAIAttackByStatus",
                     OPTIONS = {status = "shark_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51195},  -- 鲨鱼陷阱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 15},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51194},  -- 点名水柱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 20},
                },
                {
                     CLASS = "action.QAIAttackByStatus",
                     OPTIONS = {status = "shark_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51195},  -- 鲨鱼陷阱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10, first_interval = 70},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51194},  -- 点名水柱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10, first_interval = 75},
                },
                {
                     CLASS = "action.QAIAttackByStatus",
                     OPTIONS = {status = "shark_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51195},  -- 鲨鱼陷阱
                },
            },
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.75},
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

return npc_boss_xiaobai12_8