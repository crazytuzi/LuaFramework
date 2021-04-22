--小蛇
--普通副本
--创建人：许成
--创建时间：2017-6-13

local npc_zhixianduyexiaoshe= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.5,first_interval=2.5},
                },
                -- {
                --     CLASS = "action.QAIAttackAnyEnemy",
                --     OPTIONS = {always = true},
                -- },
                {
                   CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50745},          --缠绕
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
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
            },
        },
    }
}
        
return npc_zhixianduyexiaoshe