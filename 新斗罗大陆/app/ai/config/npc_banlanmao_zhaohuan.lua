local npc_mantuoluoshe=
 {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 500, first_interval = 5},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50792},
                },                                                 --冲锋触发
            },
        },
         {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 17, first_interval = 17},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50792},
                },                                                 --冲锋触发
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
        
return npc_mantuoluoshe