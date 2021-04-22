--斗罗AI 7-12BOSS
--普通副本
--character_id 3586
--戴维斯
--创建人：刘悦璘
--创建时间：2018-6-1

local npc_boss_daiweisi = {         --戴沐白转BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISelector",    -- 同时执行下3个技能
            ARGS = 
            {
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 20, first_interval = 5},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50600},      --白虎流星雨
                        },
                    },
                },
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 20, first_interval = 14},
                        },
                        {
                            CLASS = "action.QAIAttackEnemyOutOfDistance",
                            OPTIONS = {always = true , distance = 10},
                        },                                
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50602},      --白虎烈光波
                        },
                    },
                },
                {
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 20, first_interval = 10},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50092},      --白虎地裂破
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

return npc_boss_daiweisi