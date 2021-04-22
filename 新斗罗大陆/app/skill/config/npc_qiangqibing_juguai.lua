local npc_qiangqibing_juguai = {
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 23},
                },
                {
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 100,y = 0} , duration = 0.75, flip_with_actor = true },
				},
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},	
	},
}
return npc_qiangqibing_juguai