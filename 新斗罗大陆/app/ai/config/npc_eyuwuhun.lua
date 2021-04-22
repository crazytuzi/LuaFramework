--鳄鱼武魂
--普通副本
--创建人：许成
--创建时间：2018-1-10

local npc_eyuwuhun= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 300,first_interval=16},
                },
                -- {
                --     CLASS = "action.QAIAttackAnyEnemy",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50149},          --鳄鱼水柱
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
        
return npc_eyuwuhun