-- 技能 ss马红俊自动1
-- 技能ID 472
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    --     {
    --         CLASS = "composite.QSBSequence",
    --         ARGS = {
    --             {
    --                 CLASS = "action.QSBDelayTime",
    --                 OPTIONS = {delay_frame = 18},
    --             },
    --             {
				-- 	CLASS = "action.QSBPlayEffect",
				-- 	OPTIONS = {effect_id = "ssmahongjun_attack13_1", is_hit_effect = false},
				-- },
    --         },
    --     },
    --     {
    --         CLASS = "composite.QSBSequence",
    --         ARGS = {
    --             {
    --                 CLASS = "action.QSBDelayTime",
    --                 OPTIONS = {delay_frame = 19},
    --             },
    --             {
    --                 CLASS = "action.QSBPlayEffect",
    --                 OPTIONS = {effect_id = "ssmahongjun_attack13_2", is_hit_effect = false},
    --             },
    --         },
    --     },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 19},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssmahongjun_attack13", is_hit_effect = false},
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 17},
        --         },
        --         {
        --             CLASS = "action.QSBArgsIsDirectionLeft",
        --             OPTIONS = {is_attacker = true},
        --         },
        --         {
        --             CLASS = "composite.QSBSelector",
        --             ARGS = 
        --             { 
        --                 {
        --                     CLASS = "composite.QSBSequence",
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {effect_id = "ssmahongjun_attack13_5", is_hit_effect = false},
        --                         },
        --                     },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBSequence",
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {effect_id = "ssmahongjun_attack13_4", is_hit_effect = false},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    { 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "ssmahongjun_attack13_5", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "ssmahongjun_attack13_4", is_hit_effect = false},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return ssmahongjun_zidong1

