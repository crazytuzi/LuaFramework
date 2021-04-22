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

local npc_boss_yangwudi_15_12 = {
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
							OPTIONS = {interval = 76, first_interval=3},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50570},--多重攻击
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=8},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50575},--aoe左
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=15},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50574},--zoe右
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=23},
						},
						{
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {current_target_excluded = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50571},--长枪牢笼
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=27},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50570},--多重攻击
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=35},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50575},--zoe左
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=43},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50570},--多重攻击
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=49},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50574},--aoe右
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval= 56},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50571},--长枪牢笼
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval= 60},
						},
						{
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {current_target_excluded = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50571},--长枪牢笼
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval= 65},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50570},--多重攻击
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=69},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50574},--aoe右
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 76, first_interval=75},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50575},--aoe左
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

return npc_boss_yangwudi_15_12