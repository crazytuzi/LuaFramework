local bosaixi_zhenji_beidong2_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "bosaixi_zhenji_beidong2_buff", is_target = false},
                },        
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "bosaixi_zhenji_beidong2", remove_all_same_buff_id = true, is_target = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "bosaixi_zhenji_beidong2_chufa", remove_all_same_buff_id = true, is_target = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 38},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "bosaixi_zhenji_beidong2_buff", remove_all_same_buff_id = true, is_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return bosaixi_zhenji_beidong2_chufa