local npc_yaohu2_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    { 
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
                    OPTIONS = {interval = 7.5},
                }, 
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                     CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50339},
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
        
return npc_yaohu2_ai