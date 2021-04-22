local npc_chaoxuezhuhou_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    { 
       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "t"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56015 },  --坦克强化
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53375 },  --钢甲
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=4.5},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56023 },  --重击
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=9.3},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56003  },  --荆棘突袭
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=14.7},
                },
                -- {
                --     CLASS = "action.QAIAttackByRole",
                --     OPTIONS = {role = "t", exclusive = true, ignore_support = true},
                -- },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {not_support = true, not_copy_hero = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56005  },  --根须缠绕
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=20},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56023 },  --重击
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=28},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56017  },  --荆棘突袭(峰值)
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=30.5},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56002 },  --重击
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=34},
                },
                -- {
                --     CLASS = "action.QAIAttackByRole",
                --     OPTIONS = {role = "t", exclusive = true, ignore_support = true},
                -- },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {not_support = true, not_copy_hero = true},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56005  },  --根须缠绕
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval= 40.5},--40.5
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56004  },  --自然之怒
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=66.5,ignore_support = true},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "t", exclusive = true, ignore_support = true, ignore_copy_hero = true},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56005  },  --根须缠绕
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=71.4},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56002 },  --重击
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1000,first_interval=77},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56017  },  --荆棘突袭（峰值）
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=82.4},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56002 },  --重击
                },
            },
        },


        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                
                {
                    CLASS = "action.QAIBattleTimeLeft",
                    OPTIONS = {timeLeft = 3},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56003  },  --荆棘突袭（灭团展示）
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
        
return npc_chaoxuezhuhou_ai