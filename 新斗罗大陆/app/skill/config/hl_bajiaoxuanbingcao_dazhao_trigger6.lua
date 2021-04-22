local tangchen_xiuluoxue_shanghai3 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return tangchen_xiuluoxue_shanghai3