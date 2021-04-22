
local renmianmozhu_podun = {
 
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "wanquanmianyi_mozhu", multiple_target_with_skill = true ,remove_all_same_buff_id = true},
        },
        {
			CLASS = "action.QSBHitTarget",
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}


return renmianmozhu_podun