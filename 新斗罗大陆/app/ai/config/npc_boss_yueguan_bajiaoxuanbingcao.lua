--boss 月关召唤的八角玄冰草
--id 3338
--普攻ID:50347
--普攻,临死全屏冰冻
--创建人：庞圣峰
--创建时间：2018-4-6

local npc_boss_yueguan_bajiaoxuanbingcao = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 7.5,first_interval = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50422}, -- 全屏冰冻
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
return npc_boss_yueguan_bajiaoxuanbingcao