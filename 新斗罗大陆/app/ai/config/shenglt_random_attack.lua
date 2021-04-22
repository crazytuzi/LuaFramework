--斗罗AI：斑斓猫
--升灵台
--id 4118
--[[
随机攻击
]]
--psf 2020-4-14

local shenglt_random_attack = {
	CLASS = "composite.QAISelector", 
	ARGS = 
	{
        {
            CLASS = "action.QAIAttackAnyEnemy",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}

return shenglt_random_attack