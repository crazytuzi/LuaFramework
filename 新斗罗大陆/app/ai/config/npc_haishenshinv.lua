---斗罗AI 海神侍女
--副本18章
--id 3711
-- 打后排, 残血会回血
--创建人：庞圣峰
--创建时间：2018-7-26

local npc_haishenshinv= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.33, to = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50904},--自我治疗
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 8, first_interval=8},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    }
}
        
return npc_haishenshinv