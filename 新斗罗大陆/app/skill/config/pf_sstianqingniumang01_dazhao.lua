-- 技能 牛天大招
-- 技能ID 543
-- 根据场上友方魂师数量加BUFF，然后触发技能打伤害
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_qiandaoliu_dazhao = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 99},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        {--竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 99},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_ssniutian_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                }, 
                {
                    CLASS = "action.QSBPlayAnimation",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 116},
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsGhost",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        --奥斯卡召唤的Ghost牛天
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "pf_sstianqingniumang01_dazhao_ghost_buff"},
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 549,skill_level = -1},	
                                },
                            },
                        },
                        --正常牛天
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBRemoveBuffByStatus",
                                    OPTIONS = {status = "ssniutian_dazhao"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {teammate = true, buff_id = "ssniutian_dazhao_teammate_buff"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 10},
                                }, 
                                {
                                    CLASS = "action.QSBAttackByBuffNum",
                                    OPTIONS = {trigger_skill_id = 549, buff_id = "ssniutian_dazhao_teammate_buff", target_type = "teammate"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 20},
                                }, 
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 1,
                                        {expression = "self:buff_num:ssniutian_dazhao_teammate_buff=0", select = 1},
                                        {expression = "self:buff_num:ssniutian_dazhao_teammate_buff=1", select = 2},
                                        {expression = "self:buff_num:ssniutian_dazhao_teammate_buff=2", select = 3},
                                        {expression = "self:buff_num:ssniutian_dazhao_teammate_buff>2", select = 4},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_dazhao_buff1;y"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_dazhao_buff2;y"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_dazhao_buff3;y"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_dazhao_buff4;y"},
                                        },
                                    },
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_sstianqingniumang01_attack11_1", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_sstianqingniumang01_attack11_1_1", is_hit_effect = false},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 86},
                },  
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 549},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = {
                                failed_select = 4,
                                {expression = "self:has_buff:pf_sstianqingniumang01_fumo_buff1_1", select = 1},
                                {expression = "self:has_buff:pf_sstianqingniumang01_fumo_buff1_2", select = 2},
                                {expression = "self:has_buff:pf_sstianqingniumang01_fumo_buff1_3", select = 3},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_fumo_buff2_1"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_fumo_buff2_2"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "pf_sstianqingniumang01_fumo_buff2_3"},
                                },
                            },
                        },   
                        {
                            CLASS = "action.QSBRemoveBuffByStatus",
                            OPTIONS = {status = "ssniutian_fumo1"},
                        },         
                    },
                },           
            },
        },
    },
}

return pf_qiandaoliu_dazhao