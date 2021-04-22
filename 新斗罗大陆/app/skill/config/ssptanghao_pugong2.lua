-- 技能 普攻2
-- 技能ID 603
-- 打两下, HIT走真技\神技判定.
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local function HIT_WITH_ZHENJI_SHENJI_ZIDONG2(df) 
	local hit_node
	hit_node ={
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QSBDelayTime",OPTIONS = {delay_frame = df},
            },  
            --真技7效果:
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 3,
                    {expression = "self:ssptanghao_zj7&target:has_buff:ssptanghao_zhenji7_debuff", select = 1},
                    {expression = "self:ssptanghao_zj7", select = 2},
                }
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {    
                    {
                        CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", is_target = true},
                    }, 
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            {
                                CLASS = "action.QSBRemoveBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", remove_all_same_buff_id = true, enemy = true},
                            },
                            {
                                CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", is_target = true},
                            }, 
                        },
                    }, 
                },
            }, 
            --真技效果:
            {
                CLASS = "composite.QSBSequence",
                ARGS = 
                {
                    {
                        CLASS = "action.QSBArgsConditionSelector",
                        OPTIONS = {
                            failed_select = 4,
                            {expression = "self:ssptanghao_zj3", select = 3},
                            {expression = "self:ssptanghao_zj2", select = 2},
                            {expression = "self:ssptanghao_zj1", select = 1},
                        }
                    },
                    {
                        CLASS = "composite.QSBSelector",
                        ARGS = {             
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = 
                                {
                                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 1.45,ignore_absorb_percent = 0.3},},
                                    {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"ssptanghao_zhenji_debuff_1","ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                },
                            },
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = 
                                {
                                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 1.7,ignore_absorb_percent = 0.5},},
                                    {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"ssptanghao_zhenji_debuff_2","ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                },
                            },
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = 
                                {
                                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 2,ignore_absorb_percent = 0.7},},
                                    {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"ssptanghao_zhenji_debuff_3","ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                },
                            },
                            {CLASS = "action.QSBHitTarget",}, 
                        },
                    }, 
                    {
                        CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "ssptanghao_zhenji_count", is_target = false},
                    }, 
                },
            },
            --目标位面失衡:
            {
                CLASS = "composite.QSBSequence",
                ARGS = {
                    {
                        CLASS = "action.QSBArgsConditionSelector",
                        OPTIONS = {
                            failed_select = 2,
                            {expression = "self:ssptanghao_zd2&target:ssptanghao_sj", select = 1},
                        }
                    },
                    {
                        CLASS = "composite.QSBSelector",
                        ARGS = {
                            {CLASS = "action.QSBChangeRage",OPTIONS = {rage_value = 40},},
                        },
                    }, 
                    
                },
            }, 
        },
    }
	return hit_node
end

local ssptanghao_pugong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 23},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptanghao_attack02_1", is_hit_effect = false},
                },         
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptanghao_attack02_1_1", is_hit_effect = false},
                },         
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptanghao_attack01_3", is_hit_effect = true},
                },         
            },
        },
        HIT_WITH_ZHENJI_SHENJI_ZIDONG2(24),
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 44},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptanghao_attack01_3", is_hit_effect = true},
                },         
            },
        },
        HIT_WITH_ZHENJI_SHENJI_ZIDONG2(44),
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 68},
                },               
                {
                    CLASS = "action.QSBAttackFinish",
                },             
            },
        },
    },
}

return ssptanghao_pugong2