
local zudui_fenhongniangniang = {
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval= 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51805},       --粉红娘娘加标记
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 18, first_interval = 12},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52043},          --大招
                },
            },
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.75},
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 2, include_self = false, treat_hp_lowest = true},
        },
    },    
}
        
return zudui_fenhongniangniang