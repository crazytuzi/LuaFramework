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

local elite_xunlian_gaishilongshe = {
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
                    OPTIONS = {interval = 32,first_interval = 28},
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53091},-- 狂暴
                },
            },
        },
		--------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 32,first_interval = 15},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53092},-- 升龙拳
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 32,first_interval = 17},
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
                    CLASS = "action.QAIIgnoreHitLog",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53094},-- 龙蛇猛击
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 32,first_interval = 23},
                },
                -- {
                --     CLASS = "action.QAIAttackClosestEnemy",
                -- },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53092},-- 升龙拳
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 32,first_interval= 24},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
		-------------
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 32,first_interval = 6.5},
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
                    OPTIONS = {skill_id = 53094},-- 跳砸地
                },
                -- {
                --     CLASS = "action.QAIIgnoreHitLog",
                -- },
            },
        },
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

return elite_xunlian_gaishilongshe