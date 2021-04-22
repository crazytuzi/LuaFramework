--斗罗AI 鬼面盗贼BOSS
--普通副本
--id 3283  6--8
--[[
普攻带流血
突进
召唤旋转刀刃
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_guimiandaozei= {     
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
                    OPTIONS = {skill_id = 50098},
                },
            },
        },
---------------------召唤旋转刀刃
		{
			CLASS = "composite.QAISelector",
			ARGS =
			{
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 300,first_interval=25},
						},
						{
							CLASS = "action.QAIAttackClosestEnemy",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50358},          --召唤-1
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 300,first_interval=50},
						},
						{
							CLASS = "action.QAIAttackClosestEnemy",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50359},          --召唤-2
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 300,first_interval=75},
						},
						{
							CLASS = "action.QAIAttackClosestEnemy",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50360},          --召唤-3
						},
					},
				},
			},	
		},
----------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12.5,first_interval=7.5},
                },
				{
					CLASS = "action.QAIAttackClosestEnemy",
					OPTIONS = {always = true},
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50357},--突进
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
                    OPTIONS = {interval = 22,first_interval=12},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
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
    }
}
        
return npc_boss_guimiandaozei