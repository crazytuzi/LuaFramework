--绛珠
--普通副本
--创建人：许成
--创建时间：2017-6-22

local npc_jiangzhu= 
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
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50099},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=3},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50973},          --护盾
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval = 6.5 },
        --         },
        --         -- {
        --         --     CLASS = "action.QAIAttackByStatus",
        --         --     OPTIONS = {status = "angellove1"},
        --         -- }, 
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50756},          --护盾
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval = 35 },
        --         },
        --         -- {
        --         --     CLASS = "action.QAIAttackByStatus",
        --         --     OPTIONS = {status = "angellove1"},
        --         -- }, 
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50756},          --护盾
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval = 25 },
        --         },
        --         {
        --             CLASS = "action.QAIAttackByStatus",
        --             OPTIONS = {status = "angellove2"},
        --         }, 
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50754},          --护盾
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval = 45 },
        --         },
        --         {
        --             CLASS = "action.QAIAttackByStatus",
        --             OPTIONS = {status = "angellove3"},
        --         }, 
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50754},          --护盾
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 15 },
                },
                -- {
                --     CLASS = "action.QAIAttackByStatus",
                --     OPTIONS = {status = "angellove3"},
                -- }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50975},          --护盾
                },
            },
        },
		{
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.5},
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.35},
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1, include_self = false, treat_hp_lowest = true},
        },
    },    
}

return npc_jiangzhu