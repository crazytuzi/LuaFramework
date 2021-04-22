-- 技能 ss马红俊胜利动作
-- 技能ID 479
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_ruchang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.01, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attacker = true , enter_stop_position = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2 / 30 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            -- OPTIONS = {pos = {x = 500, y = 320}},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 3 / 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 0.01, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "ssmahongjun_attack21_1"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "ssmahongjun_attack21_2"},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack21"},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 3, duration = 0.4, count = 3,},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 22 / 30 },
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 0 / 30 },
                --         },
                --         {
                --             CLASS = "action.QSBApplyBuff",
                --             OPTIONS = {is_target = false, buff_id = "zsdaimubai_mianyi2"},
                --         },
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 13 / 30 },
                --         },
                --         -- {
                --         --     CLASS = "action.QSBPlayEffect",
                --         --     OPTIONS = {is_hit_effect = false, effect_id = "ssdaimubai_victory"},
                --         -- },
                --         {
                --             CLASS = "action.QSBApplyBuff",
                --             OPTIONS = {is_target = false, buff_id = "zsdaimubai_mianyi3"},
                --         },
                --     },
                -- },
            },
        },
    },
}

return ssmahongjun_ruchang
