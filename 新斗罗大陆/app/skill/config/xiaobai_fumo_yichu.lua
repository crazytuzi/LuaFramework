local xiaobai_fumo_yichu = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {           
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "fumo_xiaobai_buff1", is_target = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "fumo_xiaobai_buff2", is_target = false},
                },        
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "fumo_xiaobai_buff3", is_target = false},
                },        
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "fumo_xiaobai_jishu_buff", is_target = false},
                }, 
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "xiaobai_fumo_yichu_buff", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    }, 
}
return xiaobai_fumo_yichu