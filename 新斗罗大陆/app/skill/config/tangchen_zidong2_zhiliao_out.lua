local tangchen_zidong2_zhiliao_out = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_zhiliao_die", is_target = false, remove_all_same_buff_id = true},
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

return tangchen_zidong2_zhiliao_out