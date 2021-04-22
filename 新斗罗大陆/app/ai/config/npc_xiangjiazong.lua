--象甲宗
--普通副本
--创建人：许成
--创建时间：2017-6-27

local npc_xiangjiazong= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        --{
        --    CLASS = "composite.QAISequence",
        --    ARGS = 
        --    {
        --        {
        --            CLASS = "action.QAITimer",
        --            OPTIONS = {interval = 8,first_interval=6},
        --        },
        --        {
        --            CLASS = "action.QAIAttackAnyEnemy",
        --            OPTIONS = {always = true},
        --        },
        --        {
        --            CLASS = "action.QAIUseSkill",
        --            OPTIONS = {skill_id = 50008},          --裂地猛击
        --        },
        --    },
        --},
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
        
return npc_xiangjiazong