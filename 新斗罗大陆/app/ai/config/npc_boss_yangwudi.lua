--斗罗AI：BOSS杨无敌
--普通副本
--id 3040  2-2
--[[
闪电陷阱（添加技能范围红圈）
大招：类似露娜的大招
弹射：标枪射到一个目标身上，从目标身上弹出两道闪电攻击其他目标
]]
--创建人：庞圣峰
--创建时间：2018-3-22

local npc_boss_yangwudi = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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
							OPTIONS = {interval = 20, first_interval=10},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50197},--闪电长枪雨
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 20, first_interval=15},
						},
						{
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50199},--闪电陷阱
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 20, first_interval=5},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50198},--弹射枪
						},
					},
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

return npc_boss_yangwudi