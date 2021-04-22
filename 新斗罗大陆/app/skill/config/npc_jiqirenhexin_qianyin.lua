local boss_niumang_dazhao = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
    	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack02"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "nengliangqiu_xiyin" , is_hit_effect = false},
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "nengliangqiu_xiyin" , is_hit_effect = false},
                        },
                        {
        					CLASS = "action.QSBDragActor",
        					OPTIONS = {pos_type = "self" , pos = {x = 0,y = 0} , duration = 1.5, flip_with_actor = true },
        				},
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
			},
		},
	},
}
return boss_niumang_dazhao