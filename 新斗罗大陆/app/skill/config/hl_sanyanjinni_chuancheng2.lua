local hl_qingyufenghuang_chuancheng5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    { 
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
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
                    OPTIONS = {delay_frame = 6},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_sanyanjinni_attack12_1_1"},
                },   
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_sanyanjinni_attack12_1_2"},
                },             
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true}
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {flip_follow_y = true,target_teammate_lowest_hp_percent=true,justHero=true,ignore_hit=true,pass_key={"selectTarget"}, start_pos = {x = 110,y = 90}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"hl_sanyanjinni_chuancheng_buff_3"}},
                },
            },
        },
    },
}

return hl_qingyufenghuang_chuancheng5