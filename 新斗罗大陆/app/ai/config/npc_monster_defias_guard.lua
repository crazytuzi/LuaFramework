
local npc_monster_defias_guard = {
    CLASS = "composite.QAISelector",
    ARGS =
	{
        {
        	CLASS = "composite.QAISequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QAIHPLost",
                --     OPTIONS = {hp_less_then={0.5}},
                -- },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval=5},
                },
                {
                	CLASS = "action.QAIAttackAnyEnemy",
	            },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200513},
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
                    CLASS = "action.QAIAttackAnyEnemy",
                },
            },
        },
	},
}
        
return npc_monster_defias_guard
