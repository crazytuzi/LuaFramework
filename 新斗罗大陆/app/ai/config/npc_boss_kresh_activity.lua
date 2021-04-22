
local npc_boss_kresh = {
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
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 201103, reverse_result = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201104},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval=10},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200301},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                    OPTIONS = {store = true},
                },
                {
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {interval = 3},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval=10 + 7},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                    OPTIONS = {restore = true},
                },
                {
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200301},
                },
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 0.0, to = 1.1, relative = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = true}
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
                    OPTIONS = {check_skill_id = 200301},
                },
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 1.1, to = nil, relative = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = false}
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200301, reverse_result = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = false}
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false}
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

return npc_boss_kresh