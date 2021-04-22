local npc_mantuoluoshe= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval = 15, first_interval = 1},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50789},
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
                    OPTIONS = {interval = 15, first_interval = 7},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50777},
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
                    OPTIONS = {interval = 15, first_interval = 10},
                },
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50344},
                },                                                 --冲锋触发
            },
        },
        {
            CLASS = "composite.QAISequence",                         --顺序执行行为
            ARGS = 
            {
                {
                     CLASS = "action.QAITimer",                      --超过一定时间就触发一次
                     OPTIONS = {interval = 15, first_interval =15}, 
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
        
return npc_mantuoluoshe