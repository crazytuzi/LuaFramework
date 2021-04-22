--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：独孤博BOSS
--  关卡：4-16
local npc_boss_dugubo2 = {        
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
					OPTIONS = {interval = 12, first_interval = 4},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51081}, -- 毒瓶
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 24, first_interval = 10},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51082}, -- 玩蛇
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 24, first_interval = 14},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51087}, -- 丢第一个解药
				},
			}
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 18, first_interval = 14.5},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51088}, -- 丢第二个解药
				},
			}
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 18, first_interval = 24},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 51083}, -- 大招
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

return npc_boss_dugubo2