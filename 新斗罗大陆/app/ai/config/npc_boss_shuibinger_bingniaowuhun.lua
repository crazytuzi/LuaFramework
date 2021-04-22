--斗罗AI 冰鸟武魂
--普通副本
--id 3286  6--12
--[[
一根筋,Ghost
普攻喷地50367
冰冻自爆50368
]]--
--创建人：庞圣峰
--重写时间：2018-6-21

local npc_boss_shuibinger_bingniaowuhun= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval= 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50367}, --持续AOE
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
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
                    OPTIONS = {interval = 500,first_interval=15/24},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50367},
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50367}, --持续AOE
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
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
                    OPTIONS = {interval = 0.2,first_interval= 300/24},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50368}, --冰冻自爆
                },
            },
        },
		{
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 2, first_interval = 1, allow_frameskip = true},
                        },
                        {
                            CLASS = "action.QAITrackTarget",
                        },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",--Track最近的目标
                },
                {
                    CLASS = "action.QAITrackTarget",
                },
                {
                    CLASS = "action.QAIRewindTimers",
                },
            },
        },
    },
}
        
return npc_boss_shuibinger_bingniaowuhun