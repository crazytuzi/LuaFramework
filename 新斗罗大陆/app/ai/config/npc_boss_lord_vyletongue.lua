
local npc_boss_lord_vyletongue = {
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
                    OPTIONS = {interval = 25,first_interval = 6,relative = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 201806},
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 11,relative = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201806},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 60,relative = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201806},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 17,relative = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201808},
                },
            },
        },
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

return npc_boss_lord_vyletongue