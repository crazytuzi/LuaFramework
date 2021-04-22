--蜘蛛：召唤
--原型 10009
--NPC ID:3253
--普攻ID:50015
--会配合攻击指令一根筋后排
--创建人：庞圣峰
--创建时间：2018-3-21

local npc_putongzhizhu_ai= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 60,first_interval =3},
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
					OPTIONS = {interval = 60,first_interval =10},
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
        
return npc_putongzhizhu_ai