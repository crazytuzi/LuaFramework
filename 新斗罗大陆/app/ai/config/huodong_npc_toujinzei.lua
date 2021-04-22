
local huodong_npc_xzhaocaimao = {
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
                    OPTIONS = {check_skill_id = 50140, reverse_result = true},
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
                    OPTIONS = {skill_id = 50140},
                },
                -- {
                --     CLASS = "action.QAIClearHitLog",
                -- },
            },
        },
        {
            CLASS = "action.QAIIsUsingSkill",
            OPTIONS = {check_skill_id = 50140},
        },
        {
            CLASS = "action.QAIWandering",
           OPTIONS = {animations = {"stand","attack01", "attack03", "attack04"}},
        },
    },
}

return huodong_npc_xzhaocaimao