--斗罗AI 7-16BOSS
--普通副本
--character_id 3587
--创建人：刘悦璘
--创建时间：2018-6-1
local npc_boss_huliena716 = {
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
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.4}},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50693},          --能量倾泻
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
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {skill_id = 50693},          --检查是否使用能量倾泻
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50692},          --推波
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20, first_interval = 15},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {skill_id = 50693},          --检查是否使用能量倾泻
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50694},          --连续魅惑
                },
            },
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.6},
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.8},
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
            },
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                }
            },
        },
    },
}
        
return npc_boss_huliena716