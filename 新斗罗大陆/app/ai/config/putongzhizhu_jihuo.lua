--p普攻蜘蛛
--原型 10009
--NPC ID:94002

--普攻ID:950844 

--会配合攻击指令一根筋后排
--创建人：庞圣峰
--创建时间：2018-3-21

local pugongzhizhu_jihuo= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 12,first_interval =8 },
				},
				{
					CLASS = "action.QAIAttackByStatus",
					OPTIONS = {status = "attack_order"},
				},	
				{
					CLASS = "action.QAIIgnoreHitLog",
				},
			},
		},

		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 12,first_interval =16 },
				},
				{
					CLASS = "action.QAIAcceptHitLog",
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
        
return pugongzhizhu_jihuo