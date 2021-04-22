--海马武魂BOSS（白衣）
--普通副本
--创建人：庞圣峰
--创建时间：2018-1-3

local npc_zibaozhizhu_shenglingtai= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50098},          --免疫冲锋
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 14,first_interval=10.8},
        --         },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50605},          --玄水冰封
        --         },
        --         {
        --             CLASS = "action.QAIAttackClosestEnemy",
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 14,first_interval=8},
        --         },
        --         {
        --             CLASS = "action.QAIAttackClosestEnemy",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50488},          --刺豚炸弹
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 14,first_interval=6},
        --         },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50139},          --刺豚炸弹
        --         },
        --         {
        --             CLASS = "action.QAIAttackByHitlog",
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "action.QAITeleport",
        --     OPTIONS = {interval = 30, hp_less_than = 0.75},
        -- },
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
        
return npc_zibaozhizhu_shenglingtai