
local npc_boss_lady_anacondra_activity = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 6,first_interval = 6},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200001},
                        },
                    },
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200312},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 14,first_interval = 16},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200001},
                        },
                    },
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200316},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.40}, only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200313},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 60,first_interval = 39.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200001},
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
                    OPTIONS = {interval = 60,first_interval = 46},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.40,to =0},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5,allow_frameskip = true},
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200001},
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                    OPTIONS = {always = true},
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200316},
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

return npc_boss_lady_anacondra_activity