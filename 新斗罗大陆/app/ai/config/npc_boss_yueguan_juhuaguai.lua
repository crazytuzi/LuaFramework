--boss 月关召唤的黄色菊花怪
--id 3318
--普攻ID:50409
--普攻,临死加BOSS血
--创建人：庞圣峰
--创建时间：2018-4-6

local npc_boss_yueguan_juhuaguai = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 999,first_interval = 10},
                },
				{
                    CLASS = "action.QAIAttackByStatus",
					OPTIONS = {is_team = true, status = "boss_special_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50420}, -- 临终加血
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
return npc_boss_yueguan_juhuaguai