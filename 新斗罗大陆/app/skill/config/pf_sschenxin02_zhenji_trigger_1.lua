-- 技能 ss剑道尘心真技
-- 技能ID 190345~7
-- 施加破绽
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local QISHAZHENSHEN =
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBBullet",	
            OPTIONS = {property_promotion = { critical_chance = -0.2}},
        },
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {is_teammate = true, lowest_rage = true}
        },
        {
            CLASS = "action.QSBAddRage",
            OPTIONS = {coef_type = "attack_max_hp",type = "beattack_rage",coefficient = 4.75*0.15,min = 12,max =30}
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "sschenxin_rage_buff"},
        -- },
    },
}



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
                                    OPTIONS = {buff_id = {"pf_sschenxin02_zhenji_debuff_1","sschenxin_select_enemy_debuff"}},
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
                                    OPTIONS = {is_target = true, buff_id = {"pf_sschenxin02_zhenji_debuff_1","sschenxin_select_enemy_debuff"}},
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
                    OPTIONS = {buff_id = "pf_sschenxin02_rage_buff",pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {coef_type = "attack_max_hp",type = "beattack_rage",coefficient = 3,max = 40}
                },
                QISHAZHENSHEN,
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                QISHAZHENSHEN,
                QISHAZHENSHEN,
                QISHAZHENSHEN,
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                QISHAZHENSHEN,
                QISHAZHENSHEN,
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_zhenji_trigger

