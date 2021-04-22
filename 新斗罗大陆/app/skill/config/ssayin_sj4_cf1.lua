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
            OPTIONS = {buff_id = "ssayin_sj4_jt1",is_target = false},
        }, 
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },                
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },                 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },                 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },                 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },                 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },                
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },  
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
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
                    CLASS = "action.QSBPlayGodSkillAnimation"
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff1",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff2",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_buff4",pass_key = {"selectTarget"}},
                },               
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj_buff",pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5 ,pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 175,pass_key = {"selectTarget"}},
                },  
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_sj4_shanghai",pass_key = {"selectTarget"}},
                },                                 
            },
        },          
    },
}

return ssqianshitangsan_pugong1