

local xunlian_terminal_gaishilongshe_biaoji = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = true, buff_id = "gaishilongshe_biaoji"},
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return xunlian_terminal_gaishilongshe_biaoji
