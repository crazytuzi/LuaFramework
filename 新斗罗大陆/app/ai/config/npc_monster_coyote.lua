
local npc_monster_coyote = {
    CLASS = "composite.QAISequence",
    ARGS =
	{
        {
        	CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200707},
                },
            },
        },
	}
}
        
return npc_monster_coyote