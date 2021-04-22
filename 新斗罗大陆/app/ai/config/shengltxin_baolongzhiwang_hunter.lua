--斗罗AI 暴龙之王-狩猎状态
--升灵台"巨兽沼泽"
--id 4127
--[[
    锁定血最少目标
    状态BUFF导致踩肉就吃
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_hunter = {
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
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {not_copy_hero = true , not_support = true}
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2,first_interval=20},
                },
                {
					CLASS = "action.QAIIsUsingSkill",
					OPTIONS = {reverse_result = true , check_skill_id = 53326},
                }, 
                {
					CLASS = "action.QAIIsUsingSkill",
					OPTIONS = {reverse_result = true , check_skill_id = 53327},
				}, 
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {not_copy_hero = true , not_support = true}
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53328},
                },
            },
        },
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
                            OPTIONS = {interval = 3, first_interval = 0, allow_frameskip = true},
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
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {not_copy_hero = true , not_support = true}
                },
                {
                    CLASS = "action.QAITrackTarget",
                },
                -- {
                --     CLASS = "action.QAIRewindTimers",
                -- },
            },
        },
    },
}

return shenglt_baolongzhiwang_hunter