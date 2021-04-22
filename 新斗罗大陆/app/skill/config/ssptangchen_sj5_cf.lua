local ssmahongjun_dazhao =
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
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {check_choosetarget = true, set_black_board = {targetx = "selectTarget"}}
        },
        {
            CLASS = "composite.QSBSequence",                            
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true,  is_attacker = true,},
                },
                {
                    CLASS = "action.QSBAddRage",
                    OPTIONS = {type = "value",value = 125,pass_key = {"selectTarget"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",                            
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_sj1", is_hit_effect = true, get_black_board = {selectTarget = "targetx"}},--普攻受击
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",                            
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.25},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_sj5", is_hit_effect = true, get_black_board = {selectTarget = "targetx"}},--普攻受击
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "ssptangchen_sj5_xiuluo", no_cancel = true},
        },
        {
            CLASS = "composite.QSBSequence",                            
            ARGS = 
            {

                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj5_fengyin", no_cancel = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.25},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {get_black_board = {selectTarget = "targetx"}},
                },          
            },
        },                                    
    },
}

return ssmahongjun_dazhao