
local npc_plot_thrall = {
    CLASS = "composite.QAISequence",
    ARGS =
	{
        {
        	CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 3.2,first_interval=1},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201501},
                },
            },
        },
	}
}
        
return npc_plot_thrall