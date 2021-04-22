-- 技能 ss马红俊自动2
-- 技能ID 473
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zidong2 = 
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
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_ssmahongjun03_attack14_1", is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssmahongjun03_attack14_2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 8},
                },
                {
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        trapId = "pf_ssmahongjun03_liuxingyu", is_attackee = true,
                        args = 
                        {
                            {delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
                        },
                    },
                },
            },
        },
    },
}

return ssmahongjun_zidong2

