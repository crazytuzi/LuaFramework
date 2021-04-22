
local npc_boss_lott_grip = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 6,relative = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201818},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 60,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201819},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 120,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201820},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=12},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200510},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=16},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 38,first_interval = 22,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201812},
        --         },
        --     },
        -- },
        --  {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 180,first_interval = 40,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201814},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 180,first_interval = 50,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201814},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 20,first_interval = 65,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201814},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 20,first_interval = 75,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201814},
        --         },
        --     },
        -- },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 25,first_interval = 17,relative = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201808},
        --         },
        --     },
        -- },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 12, first_interval = 8, relative = true},
  --               },
		-- 		{
  --                   CLASS = "action.QAIAttackEnemyOutOfDistance",
		-- 			OPTIONS = {distance = 5},
  --               },
		-- 		{
  --                   CLASS = "action.QAIIgnoreHitLog",
  --               },
		-- 		{
		-- 			CLASS = "action.QAIUseSkill",
		-- 			OPTIONS = {skill_id = 200502},
		-- 		},
  --           },
  --       },
  --       {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 12,first_interval = 6,relative = true},
  --               },
  --               {
  --                   CLASS = "action.QAIAttackEnemyOutOfDistance",
		-- 			OPTIONS = {distance = 5},
  --               },
		-- 		{
		-- 			CLASS = "action.QAIUseSkill",
		-- 			OPTIONS = {skill_id = 201810},
		-- 		},
  --           },
  --       },
    --     {
    --         CLASS = "composite.QAISequence",
    --         ARGS = 
    --         {
    --             {
    --                 CLASS = "action.QAITimer",
    --                 OPTIONS = {interval = 15,first_interval = 15,relative = true},
    --             },
    --             {
    --                 CLASS = "action.QAIAttackEnemyOutOfDistance",
				-- 	OPTIONS = {distance = 5},
    --             },
				-- {
				-- 	CLASS = "action.QAIUseSkill",
				-- 	OPTIONS = {skill_id = 201810},
				-- },
    --         },
    --     },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 8,first_interval=12, relative = true},
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

return npc_boss_lott_grip