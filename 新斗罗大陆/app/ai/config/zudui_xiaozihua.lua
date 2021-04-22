--boss 月关召唤的紫色菊花怪
--id 3583
--普攻ID:50409
--加攻击力，加攻速光环
--普攻,一段时间后加BOSS攻
--创建人：卢昫
--创建时间：2019-5-30

local zudui_xiaozihua = 
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
                    OPTIONS = {skill_id = 51790},
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
                    OPTIONS = {skill_id = 50679}, -- 临终加攻
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

return zudui_xiaozihua