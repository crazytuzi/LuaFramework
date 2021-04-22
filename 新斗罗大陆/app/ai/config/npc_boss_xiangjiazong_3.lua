--斗罗AI 象甲宗BOSS
--普通副本
--id 3282  6--4
--[[
普攻
冲锋跳跃
摔倒
锤地板
狂暴
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_xiangjiazong_3= {     
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
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50353},
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
                    OPTIONS = {interval = 500,first_interval = 0.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50376},--召唤陷阱放置者
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval = 5},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50353},
                }, 
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50354},          --锤地板
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 24,first_interval = 14},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50353},
                }, 
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50352}, -- 冲锋跳跃
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
                    OPTIONS = {interval = 24,first_interval=16},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 24,first_interval=24},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50844},--狂暴
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
        
return npc_boss_xiangjiazong_3