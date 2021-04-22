local npc_boss_yangwudi = 
{
	CLASS = "composite.QAISelector", 
	ARGS = 
	{
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=2.5},
				},
				{
				    CLASS = "action.QAIUseSkillForType",
				    OPTIONS = {type = "god_skill"},
				},
			},
		},	
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=4},
				},
				{
				    CLASS = "action.QAIUseSkillForType",
				    OPTIONS = {type = "manual_skill"},
				},
			},
		},						
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