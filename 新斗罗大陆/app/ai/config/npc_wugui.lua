--旋转乌龟
--缩壳旋转，动画还没好，红乌龟也暂时用这个脚本
--创建人：庞圣峰
--创建时间：2018-1-5

local npc_wugui = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {   
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval=8},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50044},
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
                    OPTIONS = {interval = 20,first_interval=8+7},
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
                    OPTIONS = {check_skill_id = 50044},
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
                    OPTIONS = {check_skill_id = 50044},
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
                    OPTIONS = {check_skill_id = 50044, reverse_result = true},
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

return npc_wugui