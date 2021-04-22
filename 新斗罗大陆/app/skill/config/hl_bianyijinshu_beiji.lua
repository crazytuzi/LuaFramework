local hl_bianyijinshu_beiji = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "hl_bianyijinshu_attack02_3_1", is_hit_effect = false},
		},
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_attack02_3_2", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_attack02_3_3", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_bianyijinshu_beiji