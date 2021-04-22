-- 技能 ss马红俊真技自动2
-- 技能ID 190271
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_zidong2 = 
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
                    OPTIONS = {delay_frame = 24},
                },
    --             {
				-- 	CLASS = "action.QSBPlayEffect",
				-- 	OPTIONS = {effect_id = "bibidong_attack01_1", is_hit_effect = false},
				-- },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },
                {
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        trapId = "ssmahongjun_liuxingyu_ex", is_attackee = true,
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

return ssmahongjun_zhenji_zidong2

