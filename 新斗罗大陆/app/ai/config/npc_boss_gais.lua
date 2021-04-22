
local npc_boss_gais = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    --------------------------------盖斯---------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201107},
                },
            },
        },
----------------------------------吐息------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {

                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200173},
                },
            },
        },


-------------------------------面对疾风吧---------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {

                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval = 6},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200174},
                },
            },
        },
        
  ------------------------暴风雪-------------------------------------
       {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.5,to =0},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval=5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200175},
                },
            },
        },

 
---------------------------------------------------------------------
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

return npc_boss_gais