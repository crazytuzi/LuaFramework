
local npc_boss_fulande = {         --弗兰德转BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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
                    OPTIONS = {reverse_result = true , check_skill_id = 50949},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50948},--箭雨
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
                    OPTIONS = {reverse_result = true , check_skill_id = 50949},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50947},--龙卷风1
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=18},
                },
                -- {
                --     CLASS = "action.QAIHPLost",
                --     OPTIONS = {hp_less_then = {0.4},only_trigger_once = true},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50949},    --变身大招
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=25},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50949},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50948},--箭雨
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35, first_interval=30},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50949},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50950},--龙卷风2
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