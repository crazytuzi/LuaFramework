--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：八角寒冰草BOSS
--  关卡：4-12
local zudui_bajiaohanbingcao = {        
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
					OPTIONS = {interval = 36, first_interval = 8.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51797}, -- 冰冻陷阱
				},
			}
        },	
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 11.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51797}, -- 冰冻陷阱
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
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51796}, -- 召唤雪孤竹
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 36, first_interval = 30},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51729}, -- 面前AOE
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

return zudui_bajiaohanbingcao