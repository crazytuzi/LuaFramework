--斗罗AI 冰鸟武魂
--普通副本
--id 3286  6--12
--[[
一根筋,Ghost
普攻喷地50367
冰冻自爆50368
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_baihe_yigenjinglongjuanfeng= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
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
                            OPTIONS = {interval = 2, first_interval = 0.3, allow_frameskip = true},
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
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 3,first_interval=0.1},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50559}, --持续AOE
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
        
return npc_boss_baihe_yigenjinglongjuanfeng