--斗罗AI：铁虎BOSS
--普通副本
--创建人：psf
--创建时间：2018-1-20
--id 3304  3--4
--和铁龙搭档。顺劈斩、加防御、

local zudui_npc_boss_tiehu = 
{
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 4.5},
                },
				-- {
    --                 CLASS = "action.QAIAttackAnyEnemy",
    --                 OPTIONS = {always = true},
    --             },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51683},--顺劈斩
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 14},
                },
                -- {
    --                 CLASS = "action.QAIAttackAnyEnemy",
    --                 OPTIONS = {always = true},
    --             },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51683},--顺劈斩
                },
            },
        },
    --     {
    --         CLASS = "composite.QAISequence",
    --         ARGS = 
    --         {
    --             {
    --                 CLASS = "action.QAITimer",
    --                 OPTIONS = {interval = 28,first_interval = 8},
    --             },
				-- -- {
    -- --                 CLASS = "action.QAIAttackAnyEnemy",
    -- --                 OPTIONS = {always = true},
    -- --             },
    --             {
    --                 CLASS = "action.QAIUseSkill",
    --                 OPTIONS = {skill_id = 50224},--加防
    --             },
    --             -- {
    --             --     CLASS = "action.QAIIgnoreHitLog",
    --             -- },
    --         },
    --     },
        --  {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 30,first_interval=10},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",
        --         },
        --     },
        -- },
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

return zudui_npc_boss_tiehu