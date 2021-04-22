local zudui_taitan_biaoji = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {max_distance = true, change_all_node_target = true},
        },

		{
	        CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBRandomTrap",
            OPTIONS = {trapId = "zudui_taitan_jieyao",interval_time = 0.0,count = 1},
        },      
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_taitan_biaoji