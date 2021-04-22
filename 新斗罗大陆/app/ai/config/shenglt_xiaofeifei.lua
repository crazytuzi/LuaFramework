
local shenglt_xiaofeifei = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1,first_interval=12},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53281},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 4,first_interval=2},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53280},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0, max_hit = 1},
                },
                {
                    CLASS = "action.QAIForbidNormalAttack",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIReturnToAI",
                    OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 0.0},
                },
                {
                    CLASS = "action.QAIStopMoving",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 53279, reverse_result = true},
                },
                {
                    CLASS = "action.QAIInBattleRange",
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAIAttackByHitlog",
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = {
                                {
                                    CLASS = "action.QAIIsAttackerDead",
                                },
                                {
                                    CLASS = "action.QAIAttackClosestEnemy",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QAIUseSkillWithJudgement",
                    OPTIONS = {skill_id = 53279},
                },
                -- {
                --     CLASS = "action.QAIClearHitLog",
                -- },
            },
        },
        -- {
        --     CLASS = "action.QAIWandering",
        --     OPTIONS = {animations = {"stand","attack01", "attack03", "attack04"}},
        -- },
        -- {
        --     CLASS = "action.QAIWandering",
        --    OPTIONS = {animations = {"stand","attack11_1", "attack11_2", "attack11_3"}},
        -- },
    },
}

return shenglt_xiaofeifei