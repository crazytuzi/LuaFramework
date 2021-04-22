
local dps = {
    -- CLASS = "action.QAIDPS",
    CLASS = "composite.QAISelector",
    ARGS = {
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
                            OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 2},
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
            CLASS = "action.QAIDPS",
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsIdle",
                }, 
				{
                    CLASS = "composite.QAISelector",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QAISaveTeammate",
                        --     OPTIONS = {who = "health"}
                        -- },
                        {
                            CLASS = "action.QAIBeatBack",
							OPTIONS = {interval = 6}
                        },
                        -- {
                        --     CLASS = "action.QAISaveTeammate",
                        --     OPTIONS = {who = "dps", priority = "closest"}
                        -- },
                        {
                            CLASS = "action.QAIAttackClosestEnemy",
                            OPTIONS = {in_battle_area = true,},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QAIPriorityBeatBack",
            OPTIONS = {period = 5},
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsWalking",
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = {
						{
                            CLASS = "action.QAIIsHaveTarget",
							OPTIONS = {reverse_result = true},
                        },
                        {
                            CLASS = "action.QAIBeatBack",
							OPTIONS = {interval = 2}
                        },
                    },
                },
            },
        },
    },
}

return dps
