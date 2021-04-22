
local pf_ayin01_zhenji_zhiliao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "pf_ayin01_zhenji_huifu_buff"}
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_ayin01_zhenji_zhiliao