
local team_npc_boss_smolderweb = {          --副本类型：组队副本 ；NPC_ID ：63024 ； 天网蛛后
    CLASS = "composite.QAISelector",
    ARGS = 
    {
       ---------------------------   免疫      --------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },

    -------------------------   召唤   -----------------------------------------------
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
                    OPTIONS = {skill_id = 200134},                  -- 备注：ID 200134(小蜘蛛): 1、skill——XXXXXXX  ：CD 10S  （释放蛛网，捆住敌人，持续3秒）
                },
            },
        },
    -------------------------  群体毒雾   ------------------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 10,max_hit = 3},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203009},    
                },
            },
        },

    --------------------------    boss狂暴  ------------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 55},    ------51S
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201107},
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=56},   ------52S
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200002},
                },
            },
        },

    ----------------------------------------------------------------------------------

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

return team_npc_boss_smolderweb