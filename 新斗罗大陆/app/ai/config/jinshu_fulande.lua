
local npc_boss_fulande = {         --弗兰德转BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHPLost",
        --             OPTIONS = {hp_less_then = {0.2},only_trigger_once = true},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
        --         },
        --         {
        --             CLASS = "action.QAIAttackAnyEnemy",
        --         },
        --         {
        --             CLASS = "action.QAIIsUsingSkill",
        --             OPTIONS = {reverse_result = true , check_skill_id = 50110},
        --         },
        --         -- {
        --         --     CLASS = "action.QAIAttackByHitlog",
        --         --     OPTIONS = {always = true},
        --         -- },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50110},--猫鹰七箭
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50099},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=5},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50945},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50942},--夺目鎏金
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=10},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50945},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50943},--觅杀弱点
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=15},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50945},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50944},--闪现
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=16},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50945},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50942},--夺目鎏金
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=22},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50945},--变身
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

return npc_boss_fulande