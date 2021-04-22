local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {   
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_ssayin03_sj1_jt1",is_target = false},
        },             
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                         
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 12 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                         
            },
        }, 
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 48 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 60 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 72 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                          
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 84 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                             
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 96 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 108 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 120 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                 
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 132 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        }, 
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 144 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 156 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 168 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        }, 
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 180 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                            
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 192 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                 
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 204 },
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj1_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin03_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },                                           
            },
        },                  
    },
}

return ssqianshitangsan_pugong1