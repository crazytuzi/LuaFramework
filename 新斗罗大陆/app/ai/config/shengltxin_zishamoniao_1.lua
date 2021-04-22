
local shengltxin_zishamoniao = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval = 10},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = false},
                },
                {
                    CLASS = "action.QAIAttackLowHp",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53345}, -- 沸血追击
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",--忽略之前的仇恨追现在的单位
                },
				{
                    CLASS = "action.QAITrackTarget",
                    -- OPTIONS = {disable = true},
                },
            },
        },

        {
            CLASS = "action.QAIAttackByHitlog",
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

return shengltxin_zishamoniao