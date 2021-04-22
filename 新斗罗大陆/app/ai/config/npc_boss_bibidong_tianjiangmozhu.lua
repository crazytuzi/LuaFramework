--斗罗AI 比比东BOSS天降魔蛛
--副本14-16
--id 3687
--[[
出现后立即播动作(dm表里配的入场技能)
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local npc_boss_bibidong_tianjiangmozhu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.2, first_interval = 10},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50840},
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50840},     --叼到天上
                },
            },
        },
    },
}

return npc_boss_bibidong_tianjiangmozhu