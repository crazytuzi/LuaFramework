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
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "anqi_feitianshenzhua_diecen_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "anqi_feitianshenzhua_diecen_buff2",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "anqi_feitianshenzhua_diecen_buff3",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "anqi_feitianshenzhua_diecen_buff4",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {multiple_target_with_skill == true, buff_id = "anqi_feitianshenzhua_diecen_buff5",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff2",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff3",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff4",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff5",remove_all_same_buff_id = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong
