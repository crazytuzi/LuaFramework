--斗罗AI 14-12 BOSS
--普通副本
--鬼魅BOSS
--character_id 3585

local npc_boss_guimei20_12 = {         --
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",            -- BOSS第一阶段
            ARGS = 
            {
                -- {
                --     CLASS = "action.QAITimeSpan",
                --     OPTIONS = {from = 0, to = 60, relative = true},
                -- },
                {
                    CLASS = "composite.QAISelector",    -- 同时执行下3个技能
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 30, first_interval = 15},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50594},  -- 全屏AOE
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QAISequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QAITimer",
                        --             OPTIONS = {interval = 15, first_interval = 5},
                        --         },
                        --         -- {
                        --         --     CLASS = "action.QAIAttackEnemyOutOfDistance",
                        --         --     OPTIONS = {always = true},
                        --         -- },
                        --         {
                        --             CLASS = "action.QAIUseSkill",
                        --             OPTIONS = {skill_id = 50592},  -- 单体恐惧
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 15, first_interval = 10},
                                },
                                {
                                    CLASS = "action.QAIAttackByHitlog",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 50593},  -- 机关枪
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITeleport",
                                    OPTIONS = {interval = 10.0, hp_less_than = 0.75},
                                },
                            },
                        },
                    },
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

return npc_boss_guimei20_12