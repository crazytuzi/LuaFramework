

local xunlian_terminal_gaishilongshe_dianming_chufa = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "xunlianguan_gaishilongshe_dianming", is_hit_effect = false},
        },
		{
			CLASS = "action.QSBHitTarget",
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return xunlian_terminal_gaishilongshe_dianming_chufa
