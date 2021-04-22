
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
                    OPTIONS = {skill_id = 50555},
				},
			},
		},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval= 1.2},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 100,y = -100}}, speed = 900},
                },
            },
        },
    },
}

return baihe_longjuanfeng1