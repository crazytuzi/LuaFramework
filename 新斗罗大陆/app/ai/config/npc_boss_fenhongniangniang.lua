--  创建人：蔡允卿
--  创建时间：2018.04.12
--  NPC：宁风致
--  类型：治疗
local npc_boss_fenhongniangniang= {
    CLASS = "composite.QAISelector",
    ARGS =
    {
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
                    OPTIONS = {skill_id = 50098},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 600, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50502},          --睡眠全场+复活吕布
                },
            },                         
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 30, first_interval = 15},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50370},          --加攻
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 30, first_interval = 18},
        --         },
        --         {
        --             CLASS = "action.QAIAttackAnyEnemy",
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50371},          --魅惑
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12, first_interval = 12},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50503},          --大招
                },
            },
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.75},
        },
        -- {
        --     CLASS = "action.QAITeleport",
        --     OPTIONS = {interval = 10.0, hp_less_than = 0.35},
        -- },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 2, include_self = false, treat_hp_lowest = true},
        },
    },    
}
        
return npc_boss_fenhongniangniang