--斗罗AI 暴龙之王
--升灵台"巨兽沼泽"
--id 4127~30
--[[
    咆哮
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 300,first_interval=0},
                },
				{
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=1},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53341},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1,first_interval=13.5},
                },
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53324},
                },
            },
        },
		-- {
		-- 	CLASS = "action.QAIAttackByStatus",
		-- 	OPTIONS = {status = "highest_rage"},
        -- },
        {
            CLASS = "action.QAIAttackByHitlog",
        },
        {
			CLASS = "action.QAIAttackClosestEnemy",
		},
    },
}

return shenglt_baolongzhiwang