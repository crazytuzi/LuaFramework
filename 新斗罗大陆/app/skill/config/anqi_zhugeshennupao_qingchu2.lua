local anqi_zhugeshennupao_qingchu2 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "anqi_zhugeshennupao_fangyu2", is_target = false ,remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "anqi_zhugeshennupao_fangyu2", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_zhugeshennupao_qingchu2