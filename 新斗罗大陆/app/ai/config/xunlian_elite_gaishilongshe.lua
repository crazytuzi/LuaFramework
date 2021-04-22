--斗罗AI：盖世龙蛇
--普通副本
--id 3246  2-4
--[[
召唤：3~4*远程
大招：强化
上勾拳（击飞）
跳后排砸地  有前摇
]]
--创建人：庞圣峰
--创建时间：2018-3-22

local npc_boss_gaishilongshe = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 30,first_interval = 30},
  --               },
		-- 		{
  --                   CLASS = "action.QAIAttackAnyEnemy",
  --                   OPTIONS = {always = true},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50095},-- 召唤-1
  --               },
  --           },
  --       },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52134},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 6.5},
                },
                -- {
                --     CLASS = "action.QAIAttackByHatred",
                --     OPTIONS = {is_get_max = false},
                -- },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    -- OPTIONS = {distance = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53118},-- 跳砸地
                },
                -- {
                --     CLASS = "action.QAIIgnoreHitLog",
                -- },
            },
        },
		--------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 15},
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackByRole",
                                    OPTIONS = {role = "health"},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53120},     --冲锋
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53120},     --禁锢
                                },
                            },
                        },
                    },  
                },
            },
        },
         {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 17},
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackByRole",
                                    OPTIONS = {role = "health"},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53116},     --冲锋
                                },
                            },
                        },
                        {
                            CLASS = "composite.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIAttackAnyEnemy",
                                    OPTIONS = {always = true},
                                },
                                {
                                    CLASS = "action.QAIUseSkill",
                                    OPTIONS = {skill_id = 53116},     --禁锢
                                },
                            },
                        },
                    },  
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval = 20},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53115},-- 狂暴
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "health",exclusive = true,ignore_support = true},
                },
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = true},
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITrackTarget",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 40,first_interval = 32},
        --         },
        --         -- {
        --         --     CLASS = "action.QAIAttackByHatred",
        --         --     OPTIONS = {is_get_max = false},
        --         -- },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --             -- OPTIONS = {distance = 4},
        --         },
        --         {
        --             CLASS = "action.QAIIgnoreHitLog",
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 53006},-- 龙蛇猛击
        --         },
        --     },
        -- },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 40,first_interval = 40},
  --               },
  --               -- {
  --               --     CLASS = "action.QAIAttackClosestEnemy",
  --               -- },
		-- 		{
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 53004},-- 升龙拳
  --               },
  --           },
  --       },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval= 41},
                },
                {
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
		-------------
		
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 30,first_interval = 26},
  --               },
  --               {
  --                   CLASS = "action.QAIAttackEnemyOutOfDistance",
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50311},-- 跳砸地
  --               },
  --               {
  --                   CLASS = "action.QAIIgnoreHitLog",
  --               },
  --           },
  --       },
		----------------
        {
            CLASS = "action.QAIAttackByHatred",
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

return npc_boss_gaishilongshe