-- 技能 ss剑道尘心真技
-- 技能ID 190345~7
-- 施加破绽
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local function QISHAZHENSHEN(ds)
    local qishazhenshen
    qishazhenshen = 
    {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBBullet",	
                OPTIONS = {damage_scale = ds, property_promotion = {critical_chance = -0.3}},
            },
            {
                CLASS = "action.QSBArgsSelectTarget",
                OPTIONS = {is_teammate = true, lowest_rage = true}
            },
            {
                CLASS = "action.QSBAddRage",
                OPTIONS = {coef_type = "attack_max_hp",type = "beattack_rage",coefficient = 6.8*0.35,min = 36,max =90}
            },
            -- {
            --     CLASS = "action.QSBApplyBuff",
            --     OPTIONS = {buff_id = "sschenxin_rage_buff"},
            -- },
        },
    }
    return qishazhenshen
end



local sschenxin_zhenji_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {	
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:is_pvp=true", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {highest_attack = true,prior_role = "dps",default_select = true,
                                    not_copy_hero = true, change_all_node_target = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"sschenxin_zhenji_debuff_2","sschenxin_zhenji_debuff_3","sschenxin_select_enemy_debuff"}},
                                },
                                ---======
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {effect_id = "sschenxin_zhenji_3"},
                                -- }, 	
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = {"sschenxin_zhenji_debuff_2","sschenxin_zhenji_debuff_3","sschenxin_select_enemy_debuff"}},
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
                    CLASS = "action.QSBBullet",	
                    OPTIONS = {shake = {amplitude = 25, duration = 0.17, count = 1},}
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true,include_self = true, lowest_rage = true}
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "sschenxin_rage_buff",pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {coef_type = "attack_max_hp",type = "beattack_rage",coefficient = 7,max = 120}
                },
                QISHAZHENSHEN(0.5),
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                QISHAZHENSHEN(0.6),
                QISHAZHENSHEN(0.7),
                QISHAZHENSHEN(0.8),
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                QISHAZHENSHEN(0.9),
                QISHAZHENSHEN(1),
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_zhenji_trigger

