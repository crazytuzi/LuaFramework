--斗罗AI 唐晨BOSS替身
--副本14-8
--id 3676
--[[
负责唐晨的召唤与血量控制
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local npc_boss_tangchen_tishen = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 300, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50099},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.5, first_interval = 0.7},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51013},
                },
            },
        },
	},
}

return npc_boss_tangchen_tishen