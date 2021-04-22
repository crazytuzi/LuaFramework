local npc_xmantuoluoshe= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval= 5 },
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50806},          --毒蛇冲刺
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
    }
}
        
return npc_xmantuoluoshe