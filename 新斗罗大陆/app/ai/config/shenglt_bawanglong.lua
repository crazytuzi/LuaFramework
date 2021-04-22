--斗罗AI 霸王龙
--升灵台
--id 4120
--[[
打怒最高,吼叫减怒
]]--
--psf 2020-4-14

local shenglt_bawanglong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 8,first_interval=6},
                },
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53308},
                },
            },
        },
		{
			CLASS = "action.QAIAttackByStatus",
			OPTIONS = {status = "highest_rage"},
		},
        {
			CLASS = "action.QAIAttackClosestEnemy",
		},
    },
}

return shenglt_bawanglong