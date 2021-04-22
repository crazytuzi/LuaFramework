local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {lowest_hp_teammate_and_self = true, buff_id = "ningfengzhi_zhenji_plus_buff"},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong