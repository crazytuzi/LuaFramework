
local renmianmozhu_zibaoshanghai = {
 
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_frame = 10},
		},
		{
			CLASS = "action.QSBHitTarget",
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}


return renmianmozhu_zibaoshanghai