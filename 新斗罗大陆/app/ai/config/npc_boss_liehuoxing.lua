--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：烈火杏BOSS
--  关卡：4-8
local npc_boss_liehuoxing = {        
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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
                    OPTIONS = {skill_id = 50098},
                },
            },
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval = 6},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50453}, -- 一秒三喷
				},
			},
		},
		-- {
		-- 	CLASS = "composite.QAISequence",
		-- 	ARGS = 
		-- 	{
		-- 		{
		-- 			CLASS = "action.QAITimer",
		-- 			OPTIONS = {interval = 25, first_interval = 6},
		-- 		},
		-- 		{
  --                   CLASS = "action.QAIAttackEnemyOutOfDistance",
  --                   OPTIONS = {distance = 3},
  --               },
		-- 		{
		-- 			CLASS = "action.QAIUseSkill",
		-- 			OPTIONS = {skill_id = 50454}, -- 燃烧弹
		-- 		},
		-- 	},
		-- },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval = 15},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50454}, -- 燃烧弹
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval = 25},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50454}, -- 燃烧弹
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval = 10},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50455}, -- 斜线AOE1
				},
			}
        },
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 50, first_interval = 47},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50455}, -- 斜线AOE1
				},
			}
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval = 20},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50456}, -- 斜线AOE2
				},
			}
        },
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 50, first_interval = 37},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50456}, -- 斜线AOE2
				},
			}
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

return npc_boss_liehuoxing