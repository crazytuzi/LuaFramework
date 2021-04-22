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

local npc_boss_yangwudi = 
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
					OPTIONS = {interval = 70, first_interval=2},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52160},--多重攻击
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52161},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=9},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52162},--aoe左
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=16},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52163},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=20},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52164},--zoe右
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=27},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52165},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=29},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52160},--多重攻击
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=32},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52162},--zoe左
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=37},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52161},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=41},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52163},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=45},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52164},--aoe右
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval= 51},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52165},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval= 57},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52161},--长枪牢笼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=61},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52164},--aoe右
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=66},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52162},--aoe左
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