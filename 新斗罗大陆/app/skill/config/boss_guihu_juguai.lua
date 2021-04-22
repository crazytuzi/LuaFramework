local boss_guihu_juguai = {
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
         -------------------------------------- 播放攻击动画
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
				
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        --------------------------------------配合动画帧数进行拉人和伤害判定
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 130,y = 0} , duration = 0.1, flip_with_actor = true },
				},
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "zilong_housheng"},
                },
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},	
	},
}
return boss_guihu_juguai