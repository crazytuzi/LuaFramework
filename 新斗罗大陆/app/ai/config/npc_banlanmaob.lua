--傲娇的斑斓猫
--普通副本
--创建人：许成
--创建时间：2017-6-13

local npc_banlanmaob= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 5,first_interval=3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50006},          --嗜血
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
        
return npc_banlanmaob