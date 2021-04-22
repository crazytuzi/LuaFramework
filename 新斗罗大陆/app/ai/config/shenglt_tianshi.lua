--斗罗AI：小天使
--升灵台
--id 4109
--[[
打血量最低
]]
--psf 2020-4-14

local shenglt_tianshi = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAIAttackLowHp",
        },
        {
            CLASS = "action.QAIAttackByRole",
            OPTIONS = {role = "health"},
        },
        {
            CLASS = "action.QAIAttackByRole",
            OPTIONS = {role = "dps"},
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

return shenglt_tianshi