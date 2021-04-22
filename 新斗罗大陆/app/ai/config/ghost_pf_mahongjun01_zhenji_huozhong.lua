
local ghost_mahongjun_zhenji_huozhong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.5,first_interval=0.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 290179}, 
                },
            },
        },
    },
}

return ghost_mahongjun_zhenji_huozhong