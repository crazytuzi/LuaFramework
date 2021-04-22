 --斗罗AI 器武魂漂浮物
--宗门武魂争霸
--id 61028
--[[
普攻
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

 local zmwh_boss_qiwuhun_piaofuwu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 4, first_interval = 2, allow_frameskip = true},
                        },
                        {
                            CLASS = "action.QAITrackTarget",
                        },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.5,first_interval = 12},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51374},--离场
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51374},--离场
                },
            },
        },
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAITrackTarget",
                },
                {
                    CLASS = "action.QAIRewindTimers",
                },
            },
        },
    },
}

return zmwh_boss_qiwuhun_piaofuwu