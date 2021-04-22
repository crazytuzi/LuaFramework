local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {   
        {
            CLASS = "action.QSBPlayGodSkillAnimation"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "sspbosaixi_sj3_jt1"},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj3_jt1",no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj3_jt2", no_cancel = true},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {           
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "qiandaoliu_zhenji_miansi", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "qiandaoliu_zhenji_miansi_ex", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "qiandaoliu_zhenji_suoxue", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "qiandaoliu_zhenji_suoxue_ex", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_miansi", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_miansi_ex", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_suoxue", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_suoxue_ex", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_miansi", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_miansi_ex", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_suoxue", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_suoxue_ex", enemy = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "cnxiaowu_wudi", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_cnxiaowu_wudi", enemy = true},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf_cnxiaowu03_wudi", enemy = true},
                },
            },
        },  
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBJumpLaser",
                    OPTIONS = {effect_id = "sspbosaixi_sj_05", first_offset = {x = 100, y = 45 },hit_dummy = "dummy_center", attack_dummy = "dummy_body2",sort_layer_with_pos = true, --层级取目标
                    hit_effect_id = "sspbosaixi_sj_06",effect_width = 1300/2 , jump_num = 20,move_time = 0.15,duration = 0.6,
                    apply_buffIds ={"sspbosaixi_sj3_debuff1","sspbosaixi_sj_jiance","sspbosaixi_sj3_debuff2","sspbosaixi_sj3_debuff3"}},
                },
            },
        },     
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspbosaixi_sj_01"},
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspbosaixi_sj_02"},
        },  
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspbosaixi_sj_03"},
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspbosaixi_sj_04"},
        },                                                            
    },
}

return ssqianshitangsan_pugong1