--boss 恐怖骑士
--NPC原型 10017
--普攻ID:50300
--蓄力预警直线冲锋,群体乱刺,冲锋后排接单体乱刺,加回血BUFF召禁疗陷阱
--创建人：庞圣峰
--创建时间：2018-4-3

local npc_boss_kongbuqishi = {     
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
                    OPTIONS = {skill_id = 52134},          --免疫冲锋
                },
            },
        },
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
                    OPTIONS = {skill_id = 51929},          --陷阱
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 0.5},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51925}, -- 蓄力冲撞
                },
            },
        },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 13.5},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51926}, -- 冲锋
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
                    OPTIONS = {interval = 25,first_interval = 15},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51927}, -- 连刺
                },
            },
        },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 50,first_interval = 20},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51928}, -- 连刺AOE
                },
            },
        },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 7},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51930}, -- 加BUFF
                },
            },
        },
		
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =25,first_interval=20},
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
    },
}
        
return npc_boss_kongbuqishi