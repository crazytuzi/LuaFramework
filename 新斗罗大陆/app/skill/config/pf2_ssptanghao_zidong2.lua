-- 技能 蓝昊护体
-- 技能ID 608
-- 加BUFF
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local ssptanghao_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    OPTIONS = {test = "ssptanghao_zidong2"},
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
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
                            OPTIONS = {delay_frame = 27},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao02_attack14_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao02_attack14_1_1", is_hit_effect = false},
                        },
                    },
        },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "pf_ssptanghao01_attack14_1", is_hit_effect = false},
        -- },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "pf_ssptanghao01_attack14_1_1", is_hit_effect = false},
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        {expression = "self:has_buff:ssptanghao_zidong2_plus_buff1", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"pf2_ssptanghao_zidong2_plus_buff;y","pf2_ssptanghao_zidong2_buff1"}, is_target = false},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"pf2_ssptanghao_zidong2_buff;y","pf2_ssptanghao_zidong2_buff1"}, is_target = false},
                        },
                    },
                },
            },
        },
    },
}

return ssptanghao_zidong2

