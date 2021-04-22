local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {               
        {
            CLASS = "action.QSBAttackFinish",
        }, 
        {
            CLASS = "action.QSBPlayGodSkillAnimation"
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
                    OPTIONS = {buff_id = "pf_ssayin_sj1_buff1",pass_key = {"selectTarget"}},
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
                    OPTIONS = {buff_id = "pf_ssayin_sj1_jt3",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_ssayin_sj_buff",pass_key = {"selectTarget"}},
                },                            
            },
        },         
    },
}

return ssqianshitangsan_pugong1