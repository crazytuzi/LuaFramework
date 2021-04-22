-- 技能 凌天一击
-- 技能ID 546
-- 打一下. 目标位面失衡则额外回怒, HIT走真技\神技判定.
-- 真技强化后额外触发190384范围眩晕
-- 真技7强化后额外回怒翻倍
--[[
	魂师 昊天唐昊
	ID:1058
	psf 2020-7-28
]]--

local function HIT_ZIDONG1(ds,iap) 
    local hit_node
    hit_node ={
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            -----攻击及判断护盾
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 3,
                    {expression = "self:ssptanghao_zd1&target:get_absorb_value>0", select = 1},
                    {expression = "self:ssptanghao_zd1|target:get_absorb_value>0", select = 2},
                }
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {         
                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 2+ds,ignore_absorb_percent = iap},},
                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 1.5+ds,ignore_absorb_percent = iap},},
                    {CLASS = "action.QSBHitTarget",OPTIONS = {damage_scale = 1+ds,ignore_absorb_percent = iap},},
                },
            },
        },
    }
    return hit_node
end

local function HIT_WITH_ZHENJI_SHENJI_ZIDONG1(df) 
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
                CLASS = "action.QSBArgsIsUnderStatus",
                OPTIONS = {status = "ssptanghao_zj", is_attacker = true,}
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {    
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
                                            HIT_ZIDONG1(0.45,0.3),
                                            {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"pf03_ssptanghao_zhenji_debuff_1","pf03_ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                        },
                                    },
                                    {
                                        CLASS = "composite.QSBParallel",
                                        ARGS = 
                                        {
                                            HIT_ZIDONG1(0.7,0.5),
                                            {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"pf03_ssptanghao_zhenji_debuff_2","pf03_ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                        },
                                    },
                                    {
                                        CLASS = "composite.QSBParallel",
                                        ARGS = 
                                        {
                                            HIT_ZIDONG1(1,0.7),
                                            {CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = {"pf03_ssptanghao_zhenji_debuff_3","pf03_ssptanghao_zhenji_slow_debuff"}, is_target = true},}, 
                                        },
                                    },
                                },
                            }, 
                            {
                                CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "pf03_ssptanghao_zhenji_count", is_target = false},
                            }, 
                        },
                    },
                    HIT_ZIDONG1(0),
                },
            },
            
            --自动1强化:
            {
                CLASS = "action.QSBArgsIsUnderStatus",
                OPTIONS = {status = "ssptanghao_zd1", is_attacker = true,}
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {    
                    {
                        CLASS = "action.QSBTriggerSkill",	
                        OPTIONS = {skill_id = 590384, wait_finish = false},
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
                            {expression = "target:ssptanghao_sj", select = 1},
                        }
                    },
                    {
                        CLASS = "composite.QSBSelector",
                        ARGS = {
                            {CLASS = "action.QSBChangeRage",OPTIONS = {rage_value = 100},},
                        },
                    }, 
                    
                },
            },    
        },
    }
	return hit_node
end

local ssptanghao_zidong1 = 
{
    CLASS = "composite.QSBParallel",
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
                    OPTIONS = {delay_frame = 57},
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
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao03_attack13_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao03_attack13_1_1", is_hit_effect = false},
                        },
                    },
                },
            },
        },
        HIT_WITH_ZHENJI_SHENJI_ZIDONG1(38),
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 38},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao03_attack01_3", is_hit_effect = true},
                },
            },
        },
    },
}

return ssptanghao_zidong1

