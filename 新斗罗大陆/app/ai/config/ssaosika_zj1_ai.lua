local npc_boss_yangwudi = 
{
	CLASS = "composite.QAISelector", 
	ARGS = 
	{	
        {
            CLASS = "action.QAIHEALTH",
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1, include_self = true, treat_hp_lowest = true}
        },					
    },
}

return npc_boss_yangwudi