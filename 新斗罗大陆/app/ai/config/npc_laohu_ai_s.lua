
local npc_laohu_ai_s = {
    CLASS = "composite.QAISelector",
    ARGS =
	{
        
        {
            CLASS = "composite.QAISequence",                       --顺序执行行为
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",                     --超过一定时间就触发一次
                    OPTIONS = {interval =6,first_interval=6},    --10秒间隔,首次10秒后触发
                },
               
                {
                    CLASS = "action.QAIUseSkill",                  --触发一次指定的技能
                    OPTIONS = {skill_id = 50080},
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
        
return npc_laohu_ai_s