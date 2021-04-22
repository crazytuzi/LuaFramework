-- 技能 ss马红俊普攻1
-- 技能ID 467
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_pugong1 = 
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
                    OPTIONS = {delay_frame = 16},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_ssmahongjun_attack01", is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_ssmahongjun_attack01_1", speed = 1500, hit_effect_id = "ssmahongjun_attack01_3"},
                },
            },
        },
    },
}

return ssmahongjun_pugong1

