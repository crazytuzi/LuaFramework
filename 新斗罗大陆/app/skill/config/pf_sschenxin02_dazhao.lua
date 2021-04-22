-- 技能 ss剑道尘心大招
-- 技能ID 573
-- 持续施法 比剑 伤害
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--
--[[
涉及BUFF:
sschenxin_dazhao_buff 大招施法者标记
sschenxin_dazhao_lose_count 大招失败计数
sschenxin_dazhao_debuff 大招目标标记
sschenxin_dazhao_stun_debuff 大招控制效果
sschenxin_select_enemy_debuff 剑道尘心锁敌标记
sschenxin_dazhao_teammate_buff 剑道尘心队友计数
--
sschenxin_fumo_buff_1~3 大招施法者附魔等级检查
sschenxin_fumo_debuff_1~3 大招目标附魔易伤
sschenxin_zidong1_buff 是否学习自动1
sschenxin_zidong2_buff 是否学习自动2
sschenxin_zidong1_debuff 自动1目标易伤
sschenxin_zidong2_guanghuan_buff 自动2团队加强
]]


local function PER_SEC_BIJIAN(_ef,_ds)
    local per_sec_bijian= {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 3,
                    {expression = "target:has_buff:pf_sschenxin02_dazhao_debuff&self:has_buff:sschenxin_dazhao_lose_count", select = 1},
                    {expression = "self:has_buff:sschenxin_dazhao_buff", select = 2},
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
                                OPTIONS = {under_status = "sschenxin_dazhao2",change_all_node_target = true}
                            },
                            {
                                CLASS = "action.QSBArgsConditionSelector",
                                OPTIONS = {
                                    failed_select = 2,
                                    {expression = "self:random<(self:max_attack/(self:max_attack+target:max_attack)*0.33)", select = 1},
                                    {expression = "self:max_attack<target:max_attack", select = 2},
                                    {expression = "self:random<(self:max_attack/(self:max_attack+target:max_attack))", select = 1},
                                }
                            },
                            {
                                CLASS = "composite.QSBSelector",
                                ARGS = {
                                    {
                                        CLASS = "composite.QSBSequence",
                                        ARGS = 
                                        {
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = _ef, is_hit_effect = true},
                                            },
                                            {
                                                CLASS = "action.QSBHitTarget",
                                                OPTIONS = {damage_scale = _ds},
                                            },
                                        },
                                    },
                                    {
                                        CLASS = "composite.QSBSequence",
                                        ARGS = 
                                        {
                                            {
                                                CLASS = "action.QSBTriggerSkill",
                                                OPTIONS = {skill_id = 201574, wait_finish = true},
                                            },
                                            {
                                                CLASS = "action.QSBArgsConditionSelector",
                                                OPTIONS = {
                                                    failed_select = 2,
                                                    {expression = "self:has_buff:sschenxin_dazhao_buff", select = 1},
                                                }
                                            },
                                            {
                                                CLASS = "composite.QSBSelector",
                                                ARGS = {
                                                    BIJIAN_FINISH,
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                    BIJIAN_FINISH,
                    {
                        CLASS = "action.QSBAttackFinish",
                    },
                },
            },   
        },
    }
    return per_sec_bijian
end
local BIJIAN_FINISH ={
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_attacker = true, buff_id = "sschenxin_dazhao_buff"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {enemy = true, buff_id = "sschenxin_fumo_debuff_1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {enemy = true, buff_id = "sschenxin_fumo_debuff_2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {enemy = true, buff_id = "sschenxin_fumo_debuff_3"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_3", no_stand = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "pf_sschenxin02_dazhao_debuff",no_cancel = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "sschenxin_dazhao_stun_debuff",no_cancel = true},
                },
            },
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
------------------------------------------------------------------------
local sschenxin_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 28},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {
            CLASS = "action.QSBPlaySound",
            -- OPTIONS = {sound_id ="bosaixi_skill"},
        },
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 28},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_1",no_stand = true},
				},
                {
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_2", is_loop = true , is_keep_animation = true,no_stand = true},
				},
				{
					CLASS = "action.QSBActorKeepAnimation",
					OPTIONS = {is_keep_animation = true}
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_attacker = true, 
                    buff_id = {"sschenxin_dazhao_buff","sschenxin_dazhao_lose_count","sschenxin_dazhao_lose_count",
                    "sschenxin_dazhao_lose_count"}},
                },
                --
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
                        -- {
                        --     CLASS = "action.QSBTriggerSkill",
                        --     OPTIONS = {skill_id = 584, wait_finish = true},
                        -- },
                        --------====
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
                                    OPTIONS = {buff_id = {"pf_sschenxin02_dazhao_debuff","sschenxin_dazhao_stun_debuff",
                                    "sschenxin_select_enemy_debuff"}, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBLockTarget",
                                    OPTIONS = {is_lock_target = true, revertable = true},
                                },
                            },
                        },
                        ---======
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = {"pf_sschenxin02_dazhao_debuff","sschenxin_dazhao_stun_debuff",
                                    "sschenxin_select_enemy_debuff"}, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBLockTarget",
                                    OPTIONS = {is_lock_target = true, revertable = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 4,
                        {expression = "self:has_buff:sschenxin_fumo_buff_1", select = 1},
                        {expression = "self:has_buff:sschenxin_fumo_buff_2", select = 2},
                        {expression = "self:has_buff:sschenxin_fumo_buff_3", select = 3},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "sschenxin_fumo_debuff_1"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "sschenxin_fumo_debuff_2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "sschenxin_fumo_debuff_3"},
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_zidong1_buff", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "sschenxin_zidong1_debuff;y"},
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_zidong2_buff", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {teammate_and_self = true, buff_id = "sschenxin_zidong2_guanghuan_buff;y"},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_01",1),
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_02",1.1), 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_03",1.2), 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_02",1.3), 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 4,
                        {expression = "self:self_teammates_num=1", select = 4},
                        {expression = "self:self_teammates_num=2", select = 1},
                        {expression = "self:self_teammates_num=3", select = 2},
                        {expression = "self:self_teammates_num>3", select = 3},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_01",1), 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_01",1), 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.8},
                                },
                                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_02",1), 
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_01",1), 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.8},
                                },
                                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_02",1), 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.8},
                                },
                                PER_SEC_BIJIAN("pf_sschenxin02_attack11_3_03",1), 
                            },
                        },
                    },
                }, 
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_dazhao_buff", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        BIJIAN_FINISH,
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return sschenxin_dazhao