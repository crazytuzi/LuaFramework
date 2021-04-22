
local wandering_drunken_dwarf = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0, max_hit = 1},
                },
                {
                    CLASS = "action.QAIForbidNormalAttack",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false},
                },
            },
        },
    	{
    		CLASS = "composite.QAISequence",
    		ARGS = 
    		{
		    	{
		    		CLASS = "action.QAIReturnToAI",
					OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 0.0},
		    	},
		    	{
		    		CLASS = "action.QAIStopMoving",
		    	},
		    	{
		    		CLASS = "action.QAIResult",
					OPTIONS = {result = false},
		    	},
    		},
    	},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 201405, reverse_result = true},
                },
                {
                    CLASS = "action.QAIInBattleRange",
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAIAttackByHitlog",
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = {
                                {
                                    CLASS = "action.QAIIsAttackerDead",
                                },
                                {
                                    CLASS = "action.QAIAttackClosestEnemy",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QAIUseSkillWithJudgement",
                    OPTIONS = {skill_id = 201405},
                },
                -- {
                --     CLASS = "action.QAIClearHitlog",
                -- },
            },
        },
        {
            CLASS = "action.QAIIsUsingSkill",
            OPTIONS = {check_skill_id = 201405},
        },
        {
            CLASS = "action.QAIWandering",
            OPTIONS = {skill_id = 201403, behaviors = {"pour_wine_drunken_dwarf", "stand01_drunken_dwarf"}}
        },
    },
}

return wandering_drunken_dwarf