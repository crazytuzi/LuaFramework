
local npc_monster_goblin_engineer = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 5,first_interval = 2,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200501},
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

return npc_monster_goblin_engineer