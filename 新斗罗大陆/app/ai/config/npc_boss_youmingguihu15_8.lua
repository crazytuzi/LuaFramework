local npc_boss_youmingguihu15_8= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 30, first_interval = 4},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50847},
                },                                                 --冲锋触发
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",                       --顺序执行行为
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",                     --超过一定时间就触发一次
        --             OPTIONS = {interval = 30, first_interval = 18},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
        --             OPTIONS = {skill_id = 50848},
        --         },                                                 --冲锋触发
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 30, first_interval = 9},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50095},
                },                                                 --冲锋触发
            },
        },
        {
            CLASS = "composite.QAISequence",                         --顺序执行行为
            ARGS = 
            {
                {
                     CLASS = "action.QAITimer",                      --超过一定时间就触发一次
                     OPTIONS = {interval = 30, first_interval = 10}, 
                },
                {
                    CLASS = "action.QAIAcceptHitLog",                --使得ai取消忽略仇恨列表，取消锁定当前目标，可以选择恢复仇恨列表
                },
            },
        },
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 30, first_interval = 14},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50849},
                },                                                 --冲锋触发
            },
        },
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 30, first_interval = 21},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50791},
                },                                                 --冲锋触发
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
            },
        },
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 30, first_interval = 25},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50847},
                },                                                 --冲锋触发
            },
        },
        {
            CLASS = "composite.QAISequence",                         --顺序执行行为
            ARGS = 
            {
                {
                     CLASS = "action.QAITimer",                      --超过一定时间就触发一次
                     OPTIONS = {interval = 30, first_interval = 30}, 
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
    }
}
        
return npc_boss_youmingguihu15_8