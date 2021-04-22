--斗罗AI 唐晨BOSS蝙蝠替身
--副本14-8
--id 3683
--[[
呆着不动
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local scale = {
    CLASS = "composite.QAISelector",
    ARGS = {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIForbidNormalAttack",
                },
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1, first_interval = 0},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50826},
                },
            },
        },
    },
}

return scale