
local npc_assist_stormstout_1_3 = {
    CLASS = "composite.QAISelector",
    ARGS = {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 600},
                },
                {
                    CLASS = "action.QAIUseSkillWithJudgement",
                    OPTIONS = {skill_id = 105206},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 600},
                },
                {
                    CLASS = "action.QAIUseSkillWithJudgement",
                    OPTIONS = {skill_id = 105202},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 600},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 105209,level = 10},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 105207},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsManualMode",
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAIReturnToAI",
                            OPTIONS = {hp_above_for_melee = 0.3, wait_time_for_melee = 2},
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = {
                                {
                                    CLASS = "action.QAIIsIdle",
                                    OPTIONS = {ignore_attackee = true},
                                },
                                {
                                    CLASS = "composite.QAISelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QAIBeatBack",
                                            OPTIONS = {without_move = true},
                                        },
                                        {
                                            CLASS = "action.QAIAttackClosestEnemyWithoutMove",
                                            OPTIONS = {aggressive = true},
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QAIAlwaysSuccess",
                        },
                    },
                },
            },
        },

        {
            CLASS = "action.QAIT",
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsIdle",
                }, {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAIBeatBack",
                        },
                        {
                            CLASS = "action.QAIAttackClosestEnemy",
                            OPTIONS = {in_battle_area = true,},
                        }
                    },
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsAttacking",
                }, {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAISaveTeammate",
                            OPTIONS = {who = "health"}
                        },
                        {
                            CLASS = "action.QAIContinueAttackBoss"
                        },
                        -- {
                        --     CLASS = "action.QAISaveTeammate",
                        --     OPTIONS = {who = "dps"}
                        -- },
                    },
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsWalking",
                }, {
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        {
                            CLASS = "action.QAIBeatBack",
                        },
                    },
                },
            },
        },
    },
}

return npc_assist_stormstout_1_3