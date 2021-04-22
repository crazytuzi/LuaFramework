
local npc_boss_taitanjuyuan = {         --泰坦巨猿转BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
                -- {
                --     CLASS = "action.QAITimeSpan",
                --     OPTIONS = {from = 0, to = 60, relative = true},
                -- },
                
      --                       CLASS = "composite.QAISequence",
      --                       ARGS = 
      --                       {
      --                           {
      --                               CLASS = "action.QAITimer",
      --                               OPTIONS = {interval = 25, first_interval=6},
      --                           },
      --                           {
      --                               CLASS = "action.QAIIsAttacking",
      --                               OPTIONS = {always = true},
      --                           },
      --                           {
      --                               CLASS = "action.QAIUseSkill",
      --                               OPTIONS = {skill_id = 50312},--巨石重击(无红圈)
      --                           },
      --                       },
      --                   },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27, first_interval=18},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51183},--泰坦威压(坐地)
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27, first_interval=8},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    -- OPTIONS = {distance = 3},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51182},--冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27, first_interval=12},
                },
                -- {
                --     CLASS = "action.QAIIsAttacking",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51047},--巨石重击(蓄力)
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =27,first_interval=14},
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
                    OPTIONS = {interval = 27, first_interval=22},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    -- OPTIONS = {distance = 3},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51182},--冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27, first_interval=26},
                },
                -- {
                --     CLASS = "action.QAIIsAttacking",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51181},--巨石重击(蓄力)
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =27,first_interval=27},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
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

return npc_boss_taitanjuyuan