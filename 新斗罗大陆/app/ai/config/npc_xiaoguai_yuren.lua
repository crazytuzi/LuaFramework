local npc_xiaoguai_yuren = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201103},
        --         },
        --     },
        -- },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0.5},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200186},
        --         },
        --     },
        -- },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 40,first_interval=3}, 
        --         },
        --         -- {
        --         --     CLASS = "action.QAIAttackEnemyOutOfDistance",--选择一个多少距离之外的目标执行某个行为
        --         --     OPTIONS = {current_target_excluded = true},
        --         -- },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200186},
        --         },
        --     },
        -- },

       {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval=3}, 
                },
                {
                    CLASS = "action.QAIAttackByActorID",
                    OPTIONS = {actor_id = 10015},         ------------------锁定凯尔萨斯
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200185},
                },
            },
        },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 50,first_interval=50},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200003},   ---------------------召唤“-2”小怪
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

return npc_xiaoguai_yuren