
local baihe_longjuanfeng1 = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {CLASS = "composite.QAISequence",
            ARGS = 
            {
		        {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval= 0.2},
				},
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56009},
				},
			},
		},
        {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval= 3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56009},
                },
            },
        },
        
    },
}

return baihe_longjuanfeng1