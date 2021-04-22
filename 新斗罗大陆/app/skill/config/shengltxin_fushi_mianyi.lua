local fushi_mianyi = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTION = {is_target = false, buff_id = "duyezhizhu_fushidebuff_mianyi"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTION = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai2"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return fushi_mianyi