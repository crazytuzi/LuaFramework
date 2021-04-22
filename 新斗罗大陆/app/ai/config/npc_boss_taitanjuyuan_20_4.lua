---斗罗AI 泰坦巨猿BOSS
--副本18-16
--id 3708
-- 增加一个attack14的技能, 恐惧身边的人,然后回血
--创建人：庞圣峰
--创建时间：2018-7-26

local npc_boss_taitanjuyuan_20_4 = {  
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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
                    OPTIONS = {skill_id = 50187},--泰坦威压(坐地)
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 27, first_interval=7},
                },
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.5, to = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50905},--捶胸吼
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
                    OPTIONS = {skill_id = 50186},--冲锋
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
                    OPTIONS = {skill_id = 50184},--巨石重击(蓄力)
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
                    OPTIONS = {skill_id = 50186},--冲锋
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
                    OPTIONS = {skill_id = 50184},--巨石重击(蓄力)
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

return npc_boss_taitanjuyuan_20_4