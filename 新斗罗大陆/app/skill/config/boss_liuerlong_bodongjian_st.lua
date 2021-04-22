-- 技能 BOSS柳二龙火焰波动剑
-- 技能ID 50655
-- 直排陷阱击飞
--[[
	boss 柳二龙 
	ID:3175 力量试炼
	psf 2018-5-31
]]--

local boss_liuerlong_bodongjian_st = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlaySound",
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "victory"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "boss_liuerlong_huoyanbo_hongkuang", is_target = false},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 36 / 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "liuerlong_attack01_1" ,is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 86 / 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "liuerlong_attack01_2" ,is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 60 / 24  },
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack02"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 51 / 24 },
                                },
                                {   
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1, pass_key = {"pos"}},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.225, attacker_face = false,attacker_underfoot = true,count = 6, distance = 150, trapId = "boss_liuerlong_huoyanbo_st"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 76 / 24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_liuerlong_bodongjian_st