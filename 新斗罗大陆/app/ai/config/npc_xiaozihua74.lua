--boss 月关召唤的紫色菊花怪
--id 3583
--普攻ID:50409
--普攻,一段时间后加BOSS攻
--创建人：刘悦璘
--创建时间：2018-6-1

local npc_xiaozihua74 = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 10},
                },
				{
                    CLASS = "action.QAIAttackByStatus",
					OPTIONS = {is_team = true, status = "boss_special_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50679}, -- 临终加攻
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
return npc_xiaozihua74