local npc_yaohu1_ai = {
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
                    OPTIONS = {skill_id = 50098},          --免疫冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40, first_interval = 8},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50095},          --召唤-1波
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 7,first_interval= 6},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50528},          --子弹陷阱
                },
            },
        },
		{
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.6},
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                }
            },
        },
    },
}
        
return npc_yaohu1_ai