local zhuzhuqing_zhenji_dazhaox = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_jiance_x", is_target = false},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_chufa_x", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_zhenji_ceng", is_target = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zhuzhuqing_zhenji_dazhaox