local shifa_tongyong = {
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
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "liuerlong_zhenji_diecen_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "liuerlong_zhenji_plus_diecen_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "liuerlong_zhenji_jishu_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "liuerlong_zhenji_plus_jishu_buff1",remove_all_same_buff_id = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong
