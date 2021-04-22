
local the_beast = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {

    --------------------------------比斯巨兽--------------------------------------------
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


------------------------------------冲锋--------------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 10},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200314},     
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
                    OPTIONS = {interval = 20},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",  
                },
            },
        },
  --------------------------------恐惧咆哮--------------------------------------------
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
                    OPTIONS = {interval = 15,first_interval = 7},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200170},
                },
            },
        },
-------------------------------践踏---------------------------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QAIHealthSpan",
                --     OPTIONS = {from = 0.5,to =0},               
                -- },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 12},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200171},
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

return the_beast