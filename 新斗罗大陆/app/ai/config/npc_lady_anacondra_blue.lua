
local npc_lady_anacondra_blue = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {      
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 3,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200316},
                },
            },
        },
    },
}

return npc_lady_anacondra_blue