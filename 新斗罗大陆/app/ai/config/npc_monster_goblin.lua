
local npc_monster_goblin = {
    CLASS = "composite.QAISelector",
    ARGS =
	{
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0, max_hit=1},
                },
                {
                    CLASS = "action.QAIFaceTowardCenter",
                },
            },
        },
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
                    OPTIONS = {skill_id = 200509},
                },
            },
        },
	}
}
        
return npc_monster_goblin