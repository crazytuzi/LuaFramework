

local xunlian_terminal_gaishilongshe = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52134},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 3},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53253},-- 标记敌人
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 7},
                },
                {
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {is_team = false, status = "gaishilongshe_biaoji"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53241},-- 跳砸地
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 12},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53253},-- 标记敌人
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 17},
                },
                {
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {is_team = false, status = "gaishilongshe_biaoji"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53241},-- 跳砸地
                },
            },
        },
		--------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70,first_interval = 23},
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackByRole",
                                    OPTIONS = {role = "health"},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53243},     --冲锋
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53243},     --禁锢
                                },
                            },
                        },
                    },  
                },
            },
        },
         {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval = 24},
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackByRole",
                                    OPTIONS = {role = "health"},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53239},     --冲锋
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53239},     --禁锢
                                },
                            },
                        },
                    },  
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval = 27},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53238},-- 狂暴
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "health",exclusive = true,ignore_support = true},
                },
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = true},
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITrackTarget",
                            OPTIONS = {always = true},
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
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval= 37.5},
                },
                {
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval = 63},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53254},-- 点名
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval = 67},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53238},-- 狂暴
                },
                {
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {is_team = false, status = "gaishilongshe_du"},
                },
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = true},
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITrackTarget",
                            OPTIONS = {always = true},
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
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 80,first_interval= 77.5},
                },
                {
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        {
            CLASS = "action.QAIAttackByHatred",
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

return xunlian_terminal_gaishilongshe