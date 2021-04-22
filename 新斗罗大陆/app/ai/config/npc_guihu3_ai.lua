local npc_guihu3_ai = {
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 15, first_interval = 8},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50440},
                },                                                 --冲锋触发
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 9.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50343}, --三连刺
                },
            },
        },
        
                {
            CLASS = "composite.QAISequence",                       
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     
                    OPTIONS = {interval = 30,first_interval = 18},  
                },
               
                {
                    CLASS = "action.QAIUseSkill",                  
                    OPTIONS = {skill_id = 50346}, --战争践踏
                },                 
            },
        },

        {
            CLASS = "composite.QAISequence",                         --顺序执行行为
            ARGS = 
            {
                {
                     CLASS = "action.QAITimer",                      --超过一定时间就触发一次
                     OPTIONS = {interval = 15, first_interval = 15}, 
                },
                {
                    CLASS = "action.QAIAcceptHitLog",                --使得ai取消忽略仇恨列表，取消锁定当前目标，可以选择恢复仇恨列表
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
        
return npc_guihu3_ai