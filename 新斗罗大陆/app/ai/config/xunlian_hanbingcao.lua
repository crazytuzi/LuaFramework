--boss 月关召唤的寒冰草
--id 3584
--普攻ID:50347
--加攻击力，加攻速光环
--普攻,一段时间后全屏冰冻
--创建人：卢昫
--创建时间：2019-5-30

local zudui_hanbingcao = 
{     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS =
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53034},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 10},
                },
                {
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {is_team = true, status = "boss_special_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53050}, -- 全屏冰冻
                },
            },
        },
        
        {
            CLASS = "action.QAIAttackByRole",
            OPTIONS = {role = "health"},
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

return zudui_hanbingcao