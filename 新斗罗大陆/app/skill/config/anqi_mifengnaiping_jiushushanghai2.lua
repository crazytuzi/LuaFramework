
local anqi_mifengnaiping_jiushushanghai2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBAverageTreatBySaveTreat",
            OPTIONS = {coefficient = 1, in_skill_range = true, buff_id = "anqi_mifengnaiping_chucun_buff2"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "mifengnaiping_attack_4", is_hit_effect = true, teammate_in_range = true},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "mifengnaiping_attack_3", is_hit_effect = true, enemy_in_range = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_mifengnaiping_jiushushanghai2

