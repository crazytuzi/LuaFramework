--攻速盗贼
--普通副本
--创建人：蔡允卿
--创建时间：2017-12-21

local npc_daozei_1= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
                {
                    CLASS = "action.QAIUseSkill",
                 OPTIONS = {skill_id = 50083},          --嗜血
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
        
return npc_daozei_1