--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：八角寒冰草BOSS
--  关卡：4-12
local npc_boss_bajiaohanbingcao = {        
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
					OPTIONS = {interval = 500, first_interval = 12},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50458}, -- 面前AOE
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 500, first_interval = 32},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50458}, -- 面前AOE
				},
			},
		},			
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 20, first_interval = 52},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50459}, -- 面前AOE带冰冻
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 20, first_interval = 5},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50460}, -- 反复横跳
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 10, first_interval = 8},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50461}, -- 点名
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

return npc_boss_bajiaohanbingcao