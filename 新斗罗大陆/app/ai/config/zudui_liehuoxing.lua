--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：烈火杏BOSS
--  关卡：4-8
local zudui_liehuoxing = {        
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
					OPTIONS = {interval = 36, first_interval = 5},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51724}, -- 一秒三喷
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 15},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51726}, -- 斜线AOE1
				},
			}
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 20},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51725}, -- 燃烧弹
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 25},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51727}, -- 斜线AOE2
				},
			}
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 35},
				},
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 3},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51788}, -- 火旋风
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

return zudui_liehuoxing