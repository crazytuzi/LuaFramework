local tangchen_zidong2_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tangchen_zidong2_chufa"},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_die", is_target = false, remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_buff", is_target = false, remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_zhiliao", is_target = false, remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return tangchen_zidong2_chufa